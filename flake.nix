{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-libgit2.url = "github:NixOS/nixpkgs?ref=a6c20a73872c4af66ec5489b7241030a155b24c3";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
    pymodoro = {
      url = "github:christoph-blessing/pymodoro";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-libgit2,
      home-manager,
      sops-nix,
      pre-commit-hooks,
      pymodoro,
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.nixe = nixpkgs.lib.nixosSystem {
        inherit system;
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
        inherit system;
        modules = [
          (
            { ... }:
            let
              libgit2 = nixpkgs-libgit2.legacyPackages."${system}".libgit2;
            in
            {
              nixpkgs.overlays = [ (final: prev: { guile-git = prev.guile-git.override { inherit libgit2; }; }) ];
            }
          )
          ./work/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.chris = import ./work/home.nix;
            home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];
            home-manager.extraSpecialArgs = {
              inherit pymodoro;
            };
          }
          sops-nix.nixosModules.sops
        ];
      };
      checks.system.pre-commit-check = pre-commit-hooks.lib.system.run {
        src = ./.;
        hooks = {
          nixfmt = {
            enable = true;
            package = nixpkgs.legacyPackages.system.nixfmt-rfc-style;
          };
        };
      };
      devShells.system.default = nixpkgs.legacyPackages.system.mkShell {
        inherit (self.checks.system.pre-commit-check) shellHook;
        buildInputs = self.checks.system.pre-commit-check.enabledPackages;
      };
    };
}
