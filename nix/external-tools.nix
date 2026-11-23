{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.externalTools;
  installerPath = lib.makeBinPath [
    pkgs.bash
    pkgs.coreutils
    pkgs.curl
    pkgs.gnutar
    pkgs.gzip
    pkgs.unzip
  ];
in
{
  options.externalTools = {
    opencode.enable = lib.mkEnableOption "OpenCode via its official self-updating installer";
    pi.enable = lib.mkEnableOption "pi via its official installer";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.opencode.enable {
      home.sessionPath = [ "$HOME/.opencode/bin" ];

      # Bootstrap OpenCode via its official self-updating installer when not yet present.
      # Upgrades are managed directly via `opencode upgrade`.
      home.activation.installOpenCode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -x "$HOME/.opencode/bin/opencode" ]; then
          run env PATH="${installerPath}:$PATH" \
            ${lib.getExe pkgs.bash} -c '${lib.getExe pkgs.curl} -fsSL https://opencode.ai/v2/install | ${lib.getExe pkgs.bash} -s -- --no-modify-path'
        fi
      '';
    })

    (lib.mkIf cfg.pi.enable {
      home.sessionPath = [ "$HOME/.pi/agent/bin" ];

      # Bootstrap pi via its official installer when not yet present.
      home.activation.installPi = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -x "$HOME/.pi/agent/bin/pi" ] && [ ! -x "$HOME/bin/pi" ]; then
          run env PATH="${installerPath}:$PATH" \
            ${lib.getExe pkgs.bash} -c '${lib.getExe pkgs.curl} -fsSL https://pi.dev/install.sh | ${lib.getExe pkgs.bash}'
        fi
      '';
    })
  ];
}
