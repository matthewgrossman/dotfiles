{
  description = "Personal cross-platform Nix configuration (nix-darwin + Home Manager)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nix-darwin,
      home-manager,
      ...
    }:
    {
      homeManagerModules = {
        common = ./nix/common.nix;
        mac = ./nix/mac.nix;
        opencode = ./nix/opencode.nix;
        default = ./nix/common.nix;
      };

      # Apple Silicon macOS (nix-darwin + embedded Home Manager)
      darwinConfigurations.mac = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./nix/darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mg = {
              imports = [
                ./nix/common.nix
                ./nix/mac.nix
              ];
            };
          }
        ];
      };
    };
}
