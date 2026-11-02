import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { randomUUID } from "node:crypto";
import { appendFile, mkdir, stat } from "node:fs/promises";
import { homedir } from "node:os";
import { dirname, join, relative } from "node:path";
import { setTimeout as delay } from "node:timers/promises";

export const destinations = [
  { title: "New tab", value: "tab" },
  { title: "Worktree", value: "worktree" },
  { title: "Right", value: "right" },
  { title: "Below", value: "down" },
] as const;
export type Destination = typeof destinations[number]["value"];
export type SporkOptions = { destination: Destination; seed: string; title?: string };

export interface AgentAdapter {
  kind: string;
  cwd: string;
  source?: string;
  fork(directory: string): Promise<string>;
  prepareLaunch(fork: string, directory: string): Promise<string[]>;
  sendSeed(fork: string, pane: string, text: string): Promise<void>;
}

const exec = promisify(execFile);
export const run = async (command: string, args: string[]) => (await exec(command, args, { timeout: 45_000 })).stdout;

function herdrFailure(error: unknown): { code: string; message: string } | undefined {
  if (!error || typeof error !== "object" || !("stderr" in error) || typeof error.stderr !== "string") return;
  try {
    const failure = JSON.parse(error.stderr).error;
    if (typeof failure?.code === "string" && typeof failure.message === "string") return failure;
  } catch { /* Non-Herdr failures retain their original message. */ }
}

export function parseDestination(input?: string): Destination | undefined {
  const value = input?.trim();
  if (!value) return;
  if (!destinations.some((option) => option.value === value)) throw new Error("Usage: /spork [tab|worktree|right|down]");
  return value as Destination;
}

export function requireHerdr() {
  if (process.env.HERDR_ENV !== "1" || !process.env.HERDR_PANE_ID) throw new Error("Herdr is required for now.");
}

export async function defaultBranch(root: string): Promise<string> {
  const heads = (await run("git", ["-C", root, "for-each-ref", "--format=%(refname) %(symref)", "refs/remotes"]))
    .trim().split("\n").map((line) => line.split(" "))
    .filter(([ref, target]) => ref.endsWith("/HEAD") && target);
  const remote = heads.find(([ref]) => ref === "refs/remotes/origin/HEAD") ?? (heads.length === 1 ? heads[0] : undefined);
  if (!remote && heads.length > 1) throw new Error("Remote default branches are ambiguous. Set origin/HEAD before creating a worktree.");
  const exists = async (ref: string) => run("git", ["-C", root, "rev-parse", "--verify", `${ref}^{commit}`]).then(() => true, () => false);
  if (remote) {
    const local = remote[1].replace(/^refs\/remotes\/[^/]+\//, "refs/heads/");
    if (await exists(local)) return local;
    if (await exists(remote[1])) return remote[1];
    throw new Error("The repository's recorded default branch is unavailable locally.");
  }
  for (const name of ["main", "master"]) {
    const ref = `refs/heads/${name}`;
    if (await exists(ref)) return ref;
  }
  throw new Error("Cannot determine the default branch. Set a remote HEAD or create a local main/master branch.");
}

/** Own topology, launch ordering, and failure recovery; adapters own conversations. */
export async function spork(options: SporkOptions, agent: AgentAdapter) {
  let recovery = "";
  let stage = "Creating destination";
  let cwd = agent.cwd;
  let pane: string | undefined;
  let fork: string | undefined;
  let targetWorkspace: string | undefined;
  let targetTab: string | undefined;
  let launchAttempts = 0;
  const startedAt = new Date().toISOString();
  const attempts: { time: string; code?: string; message: string }[] = [];
  try {
    requireHerdr();
    const caller = process.env.HERDR_PANE_ID!;
    const workspace = process.env.HERDR_WORKSPACE_ID;
    if (options.destination === "tab" && !workspace) throw new Error("Herdr workspace context is missing.");
    const name = `spork-${randomUUID().slice(0, 8)}`;
    const label = options.title?.trim();
    let created;
    if (options.destination === "worktree") {
      const root = (await run("git", ["-C", cwd, "rev-parse", "--show-toplevel"])).trim();
      // Git lists the main checkout first; -z preserves paths without quoting.
      // Herdr rejects creation from a linked checkout, even though Git allows it.
      const first = (await run("git", ["-C", root, "worktree", "list", "--porcelain", "-z"])).split("\0")[0];
      if (!first.startsWith("worktree ")) throw new Error("Cannot determine the repository's parent checkout.");
      const parent = first.slice("worktree ".length);
      const base = await defaultBranch(root);
      created = JSON.parse(await run("herdr", [
        "worktree", "create", "--cwd", parent, "--branch", `spork/${name.slice(6)}`,
        "--base", base, "--focus",
        ...(label ? ["--label", label] : []),
      ]));
      targetWorkspace = created.result?.workspace?.workspace_id;
      recovery = `Kept workspace ${created.result?.workspace?.workspace_id ?? "(inspect Herdr)"}.`;
      const path = created.result?.worktree?.path;
      if (!path) throw new Error("No worktree path returned; inspect Herdr before retrying.");
      recovery += ` Worktree: ${path}.`;
      cwd = join(path, relative(root, cwd));
      if (!(await stat(cwd).catch(() => undefined))?.isDirectory()) {
        throw new Error(`The conversation's subdirectory does not exist on the default branch (${base}).`);
      }
    } else created = JSON.parse(await run("herdr", options.destination === "tab"
      ? ["tab", "create", "--workspace", workspace!, "--cwd", cwd, "--focus", ...(label ? ["--label", label] : [])]
      : ["pane", "split", "--pane", caller, "--direction", options.destination, "--cwd", cwd, "--focus"]));
    targetWorkspace ??= created.result?.tab?.workspace_id ?? created.result?.pane?.workspace_id ?? created.result?.root_pane?.workspace_id ?? workspace;
    targetTab = created.result?.tab?.tab_id ?? created.result?.pane?.tab_id ?? created.result?.root_pane?.tab_id;
    pane = (created.result?.root_pane ?? created.result?.pane)?.pane_id;
    if (!pane) throw new Error("No pane ID returned; inspect Herdr before retrying.");
    recovery += ` Kept pane ${pane}.`;
    stage = "Forking conversation";
    fork = await agent.fork(cwd);
    recovery += ` Fork: ${fork}.`;
    stage = "Preparing fork";
    const args = await agent.prepareLaunch(fork, cwd);
    stage = "Starting fork";
    for (let attempt = 0; ; attempt++) {
      try {
        launchAttempts++;
        await run("herdr", ["agent", "start", name, "--kind", agent.kind, "--pane", pane, "--", ...args]);
        break;
      } catch (error) {
        const failure = herdrFailure(error);
        attempts.push({ time: new Date().toISOString(), code: failure?.code, message: failure?.message ?? String(error) });
        // A fresh shell may still be initializing. Only retry an explicit
        // pre-launch rejection; timeouts/input failures may have launched it.
        if (failure?.code !== "agent_pane_busy" || attempt >= 10) throw error;
        await delay(300);
      }
    }
    if (options.seed.trim()) {
      stage = "Sending seed (do not automatically retry if delivery is uncertain)";
      await agent.sendSeed(fork, pane, options.seed);
    }
    return { pane, fork, cwd };
  } catch (error) {
    const failure = herdrFailure(error);
    const redact = (text: unknown) => {
      if (typeof text !== "string" || !options.seed) return text;
      return text.replaceAll(options.seed, "[seed redacted]")
        .replaceAll(JSON.stringify(options.seed).slice(1, -1), "[seed redacted]");
    };
    const reason = redact(failure ? `${failure.code}: ${failure.message}` : error instanceof Error ? error.message : String(error));
    let message = `${stage}: ${reason} ${recovery}`.trim();
    const logPath = join(process.env.XDG_STATE_HOME || join(homedir(), ".local", "state"), "spork", "failures.jsonl");
    let logStatus = `Failure log: ${logPath}`;
    // Best-effort snapshot, bounded independently so diagnosis can't hang recovery.
    const processInfo = pane ? await exec("herdr", ["pane", "process-info", "--pane", pane], { timeout: 2_000 })
      .then(({ stdout }) => JSON.parse(stdout), (snapshotError) => ({ error: String(snapshotError) }))
      .catch((snapshotError) => ({ error: String(snapshotError) })) : undefined;
    const details = error instanceof Error ? error as Error & { code?: string | number; signal?: string; killed?: boolean; stdout?: string; stderr?: string } : undefined;
    try {
      await mkdir(dirname(logPath), { recursive: true, mode: 0o700 });
      await appendFile(logPath, JSON.stringify({
        time: new Date().toISOString(), startedAt, stage, agent: agent.kind,
        destination: options.destination, source: agent.source, sourceCwd: agent.cwd,
        sourcePane: process.env.HERDR_PANE_ID, sourceWorkspace: process.env.HERDR_WORKSPACE_ID, sourceTab: process.env.HERDR_TAB_ID,
        targetWorkspace, targetTab, pane, fork, cwd, launchAttempts, seedProvided: Boolean(options.seed.trim()),
        attempts: attempts.map((attempt) => ({ ...attempt, message: redact(attempt.message) })),
        error: { name: details?.name, code: failure?.code ?? details?.code, message: reason,
          stdout: redact(details?.stdout), stderr: redact(details?.stderr), stack: redact(details?.stack),
          signal: details?.signal, killed: details?.killed },
        processInfo: processInfo && JSON.parse(JSON.stringify(processInfo, (_key, value) => redact(value))),
      }) + "\n", { mode: 0o600 });
    } catch (logError) {
      logStatus = `Could not write failure log ${logPath}: ${logError instanceof Error ? logError.message : logError}`;
    }
    message += ` ${logStatus}.`;
    // Destination creation changes focus, so a source-only toast is easy to miss.
    if (recovery) await run("herdr", ["notification", "show", "Spork failed", "--body", `${logStatus}. ${stage}: ${reason}`]).catch(() => {});
    throw new Error(message, { cause: error });
  }
}
