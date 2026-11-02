import { access } from "node:fs/promises";
import { SessionManager, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { destinations, parseDestination, requireHerdr, run, spork, type SporkOptions } from "../../spork/core.ts";

export default function (pi: ExtensionAPI) {
  pi.registerCommand("spork", {
    description: "Fork into a Herdr tab, worktree, or split",
    handler: async (input, ctx) => {
      try {
        requireHerdr();
        const destination = parseDestination(input);
        if (!destination && ctx.mode !== "tui") throw new Error("Use /spork tab|worktree|right|down outside the terminal UI.");
        let options: SporkOptions;
        if (destination) options = { destination, seed: "" };
        else {
          const selected = await ctx.ui.select("Open fork in", destinations.map(({ title }) => title));
          if (selected === undefined) return;
          const choice = destinations.find(({ title }) => title === selected);
          if (!choice) throw new Error("Unknown fork destination.");
          const seed = await ctx.ui.editor("Seed prompt (optional; submit empty to leave the fork idle)");
          if (seed === undefined) return;
          options = { destination: choice.value, seed: seed.trim() };
        }
        if (!ctx.isIdle()) throw new Error("Wait for the conversation to finish.");
        const source = ctx.sessionManager.getSessionFile();
        const leaf = ctx.sessionManager.getLeafId();
        if (!source || !leaf || !ctx.sessionManager.getBranch().some((entry) => entry.type === "message")) {
          throw new Error("Send a message before forking an empty conversation.");
        }
        await access(source).catch(() => { throw new Error("Save the conversation before forking it."); });
        const sourceDir = ctx.sessionManager.getSessionDir();
        const usesDefaultDir = sourceDir === SessionManager.create(ctx.cwd).getSessionDir();
        const model = ctx.model;
        const thinking = pi.getThinkingLevel();
        const { pane } = await spork(options, {
          kind: "pi",
          cwd: ctx.cwd,
          source,
          fork: async (cwd) => {
            const targetDir = usesDefaultDir ? SessionManager.create(cwd).getSessionDir() : sourceDir;
            // A separate manager preserves the original runtime and selects its actual active branch.
            const manager = SessionManager.open(source, targetDir, cwd);
            const fork = manager.createBranchedSession(leaf);
            if (!fork) throw new Error("Pi did not create a persisted fork.");
            await access(fork);
            return fork;
          },
          prepareLaunch: async (fork) => [
            "--session", fork, "--thinking", thinking,
            ...(model ? ["--provider", model.provider, "--model", model.id] : []),
          ],
          sendSeed: async (_fork, pane, text) => { await run("herdr", ["agent", "prompt", pane, text]); },
        });
        ctx.ui.notify(`Fork opened in ${pane}`, "info");
      } catch (error) {
        ctx.ui.notify(error instanceof Error ? error.message : String(error), "error");
      }
    },
  });
}
