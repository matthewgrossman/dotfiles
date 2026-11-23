{
  lib,
  pkgs,
  ...
}:
{
  home.sessionPath = [ "$HOME/.opencode/bin" ];

  # Bootstrap OpenCode via its official self-updating installer when not yet present.
  # Upgrades are managed directly via `opencode upgrade`.
  home.activation.installOpenCode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -x "$HOME/.opencode/bin/opencode" ]; then
      run env PATH="${
        lib.makeBinPath [
          pkgs.bash
          pkgs.coreutils
          pkgs.curl
          pkgs.gnutar
          pkgs.gzip
          pkgs.unzip
        ]
      }:$PATH" \
        ${lib.getExe pkgs.bash} -c '${lib.getExe pkgs.curl} -fsSL https://opencode.ai/v2/install | ${lib.getExe pkgs.bash} -s -- --no-modify-path'
    fi
  '';
}
