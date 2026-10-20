import { afterEach, beforeEach, expect, mock, spyOn, test } from "bun:test";

mock.module("@opencode/plugin/tui", () => ({ Plugin: { define: (plugin: unknown) => plugin } }));
const commands: string[][] = [];
let linked = false;
mock.module("node:child_process", () => {
  const execFile = Object.assign(() => {}, {
    [Symbol.for("nodejs.util.promisify.custom")]: async (_file: string, args: string[]) => {
      commands.push(args);
      const result = args[0] === "pane"
        ? { pane: { workspace_id: "w1", tab_id: "w1:t2" } }
        : args[0] === "workspace"
          ? { workspace: { label: "fix-login", worktree: { repo_name: "app", is_linked_worktree: linked } } }
          : { tab: { label: "review" } };
      return { stdout: JSON.stringify({ result }), stderr: "" };
    },
  });
  return { execFile };
});
const { default: plugin } = await import("./tui.ts");
let poll: () => void;
let cleanup: (() => void) | undefined;
let route: any;
let session: any;
const update = mock(async (_input: unknown) => {});
const toast = mock(() => {});
const ctx = {
  ui: { router: { current: () => route }, toast: { show: toast } },
  data: { session: { get: () => session } },
  client: { session: { update } },
};
const originalEnv = { ...process.env };
const flush = () => new Promise<void>((resolve) => setImmediate(resolve));

beforeEach(() => {
  commands.length = 0;
  linked = false;
  update.mockClear();
  toast.mockClear();
  process.env.HERDR_ENV = "1";
  process.env.HERDR_PANE_ID = "w1:p1";
  route = { type: "session", sessionID: "ses_new" };
  session = { time: { created: Date.now() }, title: "AI title" };
  spyOn(globalThis, "setInterval").mockImplementation(((callback: () => void) => { poll = callback; return 123; }) as any);
  spyOn(globalThis, "clearInterval").mockImplementation(() => {});
});
afterEach(() => {
  cleanup?.();
  cleanup = undefined;
  mock.restore();
  process.env = { ...originalEnv };
});
function start() { cleanup = (plugin as any).setup(ctx); }

test("names the current new session using the client's pane", async () => {
  start();
  await flush();
  expect(update).toHaveBeenCalledWith({ sessionID: "ses_new", title: "app:main:review" });
  expect(commands[0]).toEqual(["pane", "current", "--current"]);
  poll();
  await flush();
  expect(update).toHaveBeenCalledTimes(1);
});

test("handles /new and linked workspace names", async () => {
  start();
  await flush();
  linked = true;
  route = { type: "session", sessionID: "ses_second" };
  poll();
  await flush();
  expect(update).toHaveBeenLastCalledWith({ sessionID: "ses_second", title: "app:fix-login:review" });
});

test("does not name resumed sessions, forks, or subagents", async () => {
  for (const extra of [{ time: { created: 1 } }, { parentID: "ses_parent" }, { fork: {} }]) {
    session = { time: { created: Date.now() }, title: "Existing", ...extra };
    start();
    await flush();
    cleanup?.();
  }
  expect(update).not.toHaveBeenCalled();
  expect(commands).toHaveLength(0);
});

test("waits for initial title, then leaves manual renames alone", async () => {
  session.title = undefined;
  start();
  await flush();
  expect(update).not.toHaveBeenCalled();
  session.title = "Generated title";
  poll();
  await flush();
  session.title = "Manually renamed";
  poll();
  await flush();
  expect(update).toHaveBeenCalledTimes(1);
});

test("ignores other clients' sessions when not on a session route", async () => {
  route = { type: "home" };
  start();
  await flush();
  expect(update).not.toHaveBeenCalled();
});

test("does nothing outside Herdr", async () => {
  delete process.env.HERDR_ENV;
  start();
  await flush();
  expect(cleanup).toBeUndefined();
  expect(commands).toHaveLength(0);
});

test("does not update after disposal", async () => {
  start();
  cleanup?.();
  await flush();
  expect(update).not.toHaveBeenCalled();
});
