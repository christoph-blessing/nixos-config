{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-guix.url = "github:NixOS/nixpkgs?ref=00d80d13810dbfea8ab4ed1009b09100cca86ba8";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-guix,
      home-manager,
      sops-nix,
      pre-commit-hooks,
    }:
    {
      nixosConfigurations.nixe = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./personal/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.chris = import ./personal/home.nix;
          }
          sops-nix.nixosModules.sops
        ];
      };
      nixosConfigurations.nixe-work = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          (
            { ... }:
            {
              nixpkgs.overlays = [ (final: prev: { guix = nixpkgs-guix.legacyPackages.${prev.system}.guix; }) ];
            }
          )
          ./work/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.chris = import ./work/home.nix;
            home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];
          }
          sops-nix.nixosModules.sops
        ];
      };
      checks."x86_64-linux".pre-commit-check = pre-commit-hooks.lib."x86_64-linux".run {
        src = ./.;
        hooks = {
          nixfmt = {
            enable = true;
            package = nixpkgs.legacyPackages."x86_64-linux".nixfmt-rfc-style;
          };
        };
      };
      devShells."x86_64-linux".default = nixpkgs.legacyPackages."x86_64-linux".mkShell {
        inherit (self.checks."x86_64-linux".pre-commit-check) shellHook;
        buildInputs = self.checks."x86_64-linux".pre-commit-check.enabledPackages;
      };
    };
}
