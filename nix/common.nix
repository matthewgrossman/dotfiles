{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.username = lib.mkDefault "mg";
  home.homeDirectory = lib.mkDefault (
    if pkgs.stdenv.hostPlatform.isDarwin then
      "/Users/${config.home.username}"
    else
      "/home/${config.home.username}"
  );
  home.stateVersion = lib.mkDefault "25.05";

  programs.home-manager.enable = true;

  # Don't auto-restart user services on switch so OpenCode can run `home-manager switch`
  # without killing its own running session; restart manually when ready.
  systemd.user.startServices = lib.mkIf pkgs.stdenv.hostPlatform.isLinux (lib.mkDefault "suggest");

  home.packages =
    with pkgs;
    [
      # Agent
      opencode

      # Shell and navigation
      atuin
      bat
      eza
      fd
      fzf
      neovim
      ranger
      tmux
      tree-sitter
      yazi
      zoxide
      zsh-autosuggestions
      zsh-syntax-highlighting

      # Git and GitHub
      delta
      gh
      git
      git-lfs
      lazygit

      # Languages and tooling
      go
      nodejs
      python3
      ruff
      rustup
      shellcheck
      uv

      # Data, networking, and system inspection
      btop
      gron
      htop
      iperf3
      jless
      jq
      ncdu
      nmap
      ripgrep
      rsync
      smartmontools
      tlrc
      tree
      unzip
      wakeonlan
      wget
      yq-go

      # Homelab / ops
      age
      ansible
      lazydocker
      rclone
      sops
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      lm_sensors
    ];
}
