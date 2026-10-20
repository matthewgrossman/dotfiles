import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { Plugin } from "@opencode/plugin/tui";

const exec = promisify(execFile);
async function herdr(...args: string[]) {
  const { stdout } = await exec("herdr", args, { timeout: 5_000 });
  return JSON.parse(stdout).result;
}

export default Plugin.define({
  id: "herdr-title",
  setup(ctx) {
    if (process.env.HERDR_ENV !== "1" || !process.env.HERDR_PANE_ID) return;
    const handled = new Set<string>();
    let disposed = false;

    async function nameCurrentSession() {
      const route = ctx.ui.router.current();
      if (route.type !== "session" || handled.has(route.sessionID)) return;
      const session = ctx.data.session.get(route.sessionID);
      // Wait for OpenCode's initial title so an in-flight AI title cannot
      // overwrite ours. Only touch sessions created since this client started.
      if (!session || session.time.created < performance.timeOrigin || session.parentID || session.fork || !session.title) return;
      handled.add(route.sessionID);
      try {
        const { pane } = await herdr("pane", "current", "--current");
        const [{ workspace }, { tab }] = await Promise.all([
          herdr("workspace", "get", pane.workspace_id),
          herdr("tab", "get", pane.tab_id),
        ]);
        const project = workspace.worktree?.repo_name ?? workspace.label;
        const worktree = workspace.worktree?.is_linked_worktree ? workspace.label : "main";
        const title = [project, worktree, tab.label].map((part: string) => part.trim().replace(/[\r\n\t]/g, " ")).join(":");
        if (!disposed) await ctx.client.session.update({ sessionID: route.sessionID, title });
      } catch (error) {
        if (!disposed) ctx.ui.toast.show({ message: `Herdr session naming failed: ${error}`, variant: "error" });
      }
    }

    // Routes/cache hydrate asynchronously; also handles /new without subscribing
    // to creation events from unrelated clients on the shared server.
    const timer = setInterval(() => void nameCurrentSession(), 250);
    void nameCurrentSession();
    return () => { disposed = true; clearInterval(timer); };
  },
});
