import { Plugin } from "@opencode/plugin/tui";
import { destinations, parseDestination, requireHerdr, run, spork } from "../../spork/core.ts";

export default Plugin.define({
  id: "spork",
  setup(ctx) {
    return ctx.ui.slot({
      append: "app", // Command registration needs the mounted keymap provider.
      render() {
        ctx.keymap.layer(() => ({
          mode: "global",
          commands: [{
            id: "spork.fork", title: "Fork into a tab, worktree, or split", palette: true,
            slash: { name: "spork", arguments: true },
            async run(input) {
              try {
                const route = ctx.ui.router.current();
                if (route.type !== "session") throw new Error("Open a conversation first.");
                requireHerdr();
                let direction = parseDestination(input);
                let title = "";
                let seed = "";
                if (!direction) {
                  direction = await ctx.ui.dialog.select({
                    title: "Open fork in",
                    current: destinations[0].value,
                    options: destinations.map(({ title, value }) => ({ title, value })),
                  });
                  if (direction == null) return;
                  if (direction === "tab" || direction === "worktree") {
                    const name = await ctx.ui.dialog.prompt({
                      title: direction === "tab" ? "Tab title (optional)" : "Worktree workspace title (optional)",
                      placeholder: "Leave empty to keep the automatic label",
                    });
                    if (name == null) return;
                    title = name.trim();
                  }
                  const text = await ctx.ui.dialog.prompt({
                    title: "Seed prompt (optional)",
                    value: "You are now in a forked agent conversation.",
                  });
                  if (text == null) return;
                  seed = text.trim();
                }
                const connected = await ctx.client.server.info();
                const local = JSON.parse(await run("opencode", ["api", "get", "/api/info"]));
                if (connected.pid !== local.pid || connected.paths.tmp !== local.paths.tmp
                  || JSON.stringify(connected.urls) !== JSON.stringify(local.urls)) {
                  throw new Error("Use the default local OpenCode service.");
                }
                if (ctx.data.session.status(route.sessionID) === "running") throw new Error("Wait for the session to finish.");
                if (!(await ctx.client.session.context({ sessionID: route.sessionID })).length) throw new Error("Send a message before forking an empty conversation.");
                const source = await ctx.client.session.get({ sessionID: route.sessionID });
                const { pane } = await spork({ destination: direction, seed, title }, {
                  kind: "opencode",
                  cwd: source.location.directory,
                  source: route.sessionID,
                  fork: async () => (await ctx.client.session.fork({ sessionID: route.sessionID })).id,
                  prepareLaunch: async (fork, cwd) => {
                    if (cwd !== source.location.directory) {
                      await ctx.client.session.move({ sessionID: fork, directory: cwd });
                      await ctx.client.session.wait({ sessionID: fork });
                      const moved = await ctx.client.session.get({ sessionID: fork });
                      if (moved.location.directory !== cwd) throw new Error("Fork did not move to the worktree; not starting OpenCode.");
                    }
                    return [cwd, "--session", fork];
                  },
                  sendSeed: async (fork, _pane, text) => { await ctx.client.session.prompt({ sessionID: fork, text }); },
                });
                ctx.ui.toast.show({ message: `Fork opened in ${pane}`, variant: "success" });
              } catch (error) {
                ctx.ui.toast.show({ message: error instanceof Error ? error.message : String(error), variant: "error" });
              }
            },
          }],
        }));
        return null;
      },
    });
  },
});
