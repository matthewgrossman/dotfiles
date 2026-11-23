{
  pkgs,
  ...
}:
{
  # Determinate Nix manages the Nix daemon and /etc/nix/nix.conf.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;

  system.primaryUser = "mg";
  system.stateVersion = 6;

  users.users.mg = {
    name = "mg";
    home = "/Users/mg";
  };

  programs.zsh.enable = true;

  # Expose zsh plugins installed via Home Manager under /etc/profiles/per-user/$USER/share.
  environment.pathsToLink = [
    "/share/zsh-autosuggestions"
    "/share/zsh-syntax-highlighting"
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.symbols-only
  ];

  # GUI apps and Mac App Store apps (from mac/Brewfile)
  homebrew = {
    enable = true;
    taps = [
      "penso/tap"
    ];
    casks = [
      # Unblocks other logins
      "google-drive"
      "keepassxc"

      # System / privileged apps
      "docker-desktop"
      "tailscale-app"
      "zoom"

      # Essentials
      "alfred"
      "betterdisplay"
      "penso/tap/herdr-gpui"
      "zed"
      "firefox"
      "firefox@developer-edition"
      "google-chrome"
      "zen"
      "hammerspoon"
      "signal"
      "slack"
      "spotify"
      "todoist-app"
      "uhk-agent"
      "wezterm"

      # Other apps
      "balenaetcher"
      "chromedriver"
      "discord"
      "gcloud-cli"
      "ollama-app"
      "sonos"
      "visual-studio-code"
      "vlc"
    ];
    masApps = {
      Amphetamine = 937984704;
    };
  };

  # Declarative macOS defaults (from mac/mac_defaults.sh + mac/setup.sh)
  system.defaults = {
    NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      AppleShowAllExtensions = true;
      "com.apple.mouse.tapBehavior" = 1;
    };

    dock = {
      autohide = true;
      mru-spaces = false;
      showAppExposeGestureEnabled = true;
    };

    finder = {
      FXPreferredViewStyle = "Nlsv";
      ShowPathbar = true;
      AppleShowAllFiles = true;
      FXEnableExtensionChangeWarning = false;
    };

    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };

    CustomUserPreferences = {
      "com.apple.ActivityMonitor" = {
        UpdatePeriod = 1;
      };
      "org.hammerspoon.Hammerspoon" = {
        MJConfigFile = "/Users/mg/.config/hammerspoon/init.lua";
      };
    };
  };

  # Keep the Mac awake on AC power (mirrors `sudo pmset -c sleep 0`).
  system.activationScripts.postActivation.text = ''
    pmset -c sleep 0
  '';

  # Self-updating tools installed outside nixpkgs (defined in nix/external-tools.nix).
  home-manager.users.mg.externalTools = {
    opencode.enable = true;
    pi.enable = true;
  };

  # macOS-specific CLI tools (migrated from mac/Brewfile; shared tools live in common.nix).
  home-manager.users.mg.home.packages = with pkgs; [
    blueutil
    bun
    fswatch
    git-filter-repo
    glab
    graphviz
    imagemagick
    iproute2mac
    k9s
    kubernetes-helm
    lua-language-server
    m1ddc
    mise
    mkcert
    moreutils
    mosh
    ninja
    pandoc
    ty
    universal-ctags
    watch
    wireguard-tools
    yarn
    zellij
  ];
}
