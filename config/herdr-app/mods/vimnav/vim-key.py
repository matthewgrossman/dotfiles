#!/usr/bin/env python3
"""vim-key.py TERMINAL BYTE: if Vim is in front of TERMINAL, type BYTE into it.

Prints "vim" if it typed the byte, "other" if not. The byte goes in as raw DATA on
a framed terminal.attach, the way a person's typing does, so it doesn't wait for
the person to stop typing the way `hc keys` does (herdr-core #52).
"""
import json
import re
import struct
import subprocess
import sys

# vi, vim, nvim, view, gvim and their diff variants, as vim-herdr-navigation.sh.
VIM = re.compile(r"^g?(view|l?n?vim?x?)(diff)?$")
DATA, CLOSE = 0, 2

terminal, byte = sys.argv[1], bytes([int(sys.argv[2], 0)])
core = subprocess.Popen(["hc", "connect"], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
out, inp = core.stdin, core.stdout


def read_exact(n):
    buf = b""
    while len(buf) < n:
        chunk = inp.read(n - len(buf))
        if not chunk:
            sys.exit("hc connect closed")
        buf += chunk
    return buf


def send(channel, kind, payload=b""):
    out.write(struct.pack("<IBI", channel, kind, len(payload)) + payload)
    out.flush()


def frame():
    channel, kind, length = struct.unpack("<IBI", read_exact(9))
    return channel, kind, read_exact(length)


def call(id, method, params):
    send(0, DATA, json.dumps({"jsonrpc": "2.0", "id": id, "method": method, "params": params}).encode())
    while True:
        channel, kind, payload = frame()
        if channel == 0 and kind == DATA:
            reply = json.loads(payload)
            if reply.get("id") == id:
                if "error" in reply:
                    sys.exit(f"{method}: {reply['error']}")
                return reply["result"]


out.write(b'{"jsonrpc":"2.0","id":1,"method":"hello","params":{"generation":1,"framed":true}}\n')
out.flush()
inp.readline()

t = call(2, "terminal.get", {"terminal": terminal})
name = ((t.get("foreground") or {}).get("name") or "").lower()
if not VIM.match(name):
    print("other")
    sys.exit(0)

# Attach at the terminal's own size: typing makes this viewer the one that sets it.
channel = call(3, "terminal.attach", {"terminal": terminal, "cols": t["cols"], "rows": t["rows"]})["channel"]
send(channel, DATA, byte)
send(channel, CLOSE)
while frame()[:2] != (channel, CLOSE):
    pass
print("vim")
