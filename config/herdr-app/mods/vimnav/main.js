// Key commands that need logic, hosted by a zero-size block in layouts/my-main.json
// (a mod only receives "vimnav.<command>" key commands while its block is in the layout).
//
//   vimnav.left|down|up|right  Vim-aware ctrl-h/j/k/l: Vim in the focused pane gets
//                              the key (its own mapping hands off at a split edge),
//                              anything else moves focus to the neighbouring pane.
//   vimnav.copy-id             Copy the focused terminal's address (for `hc send`).
import { View, div } from "gpui-kit";
import { appHome, exec, focused, nextCommand, notify, run } from "herdr";

// Bytes for ctrl-h/j/k/l.
const KEYS = { left: "0x08", down: "0x0a", up: "0x0b", right: "0x0c" };

// vim-key.py asks the core what's in front at key time (the app's panes().program
// can lag many seconds behind starting or quitting Vim) and, for Vim, types the key
// as raw input. `hc keys` would wait until the person stops typing (herdr-core #52).
async function navigate(direction) {
  const f = focused();
  if (!f) return;
  if (f.terminal) {
    const script = `${appHome()}/mods/vimnav/vim-key.py`;
    const r = await exec(script, [f.terminal, KEYS[direction]]);
    if (r.code !== 0) console.log(`vimnav.${direction}: ${r.stderr}`);
    if (r.stdout.trim() === "vim") return;
  }
  if (f.pane) run("pane.go", { direction });
}

async function copyId() {
  const terminal = focused()?.terminal;
  if (!terminal) return;
  await exec("sh", ["-c", 'printf "%s" "$1" | pbcopy', "sh", terminal]);
  notify({ title: `Copied ${terminal}`, level: "info", timeout: 2000 });
}

export default class Nav extends View {
  init(_props, cx) {
    cx.spawn(async () => {
      for (;;) {
        const command = await nextCommand();
        try {
          if (command in KEYS) await navigate(command);
          else if (command === "copy-id") await copyId();
        } catch (e) {
          console.log(`vimnav.${command}: ${e}`);
        }
      }
    });
  }

  render() {
    return div();
  }
}
