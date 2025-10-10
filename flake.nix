{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
    nixpkgs-xss-lock.url = "github:NixOS/nixpkgs?rev=7ab46aaa4588426e5cc1797921854c6021ca5486";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      sops-nix,
      pre-commit-hooks,
      pymodoro,
      nixpkgs-xss-lock,
    }:
    let
      system = "x86_64-linux";
      pkgsXssLock = import nixpkgs-xss-lock { inherit system; };
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
            {
              nixpkgs.overlays = [
                (self: super: {
                  xss-lock = pkgsXssLock.xss-lock;
                })
              ];
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
      checks.${system}.pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          nixfmt-rfc-style.enable = true;
        };
      };
      devShells.${system}.default = nixpkgs.legacyPackages.${system}.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
      };
    };
}
