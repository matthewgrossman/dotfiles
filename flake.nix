{
  description = "Personal cross-platform Home Manager modules (macOS & Linux)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }:
    {
      homeManagerModules = {
        common = ./nix/common.nix;
        default = ./nix/common.nix;
      };

      # Standalone macOS (Apple Silicon) Home Manager config; override username if needed.
      homeConfigurations.mac = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [ ./nix/common.nix ];
      };
    };
}
