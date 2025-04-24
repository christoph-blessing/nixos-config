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
    nixpkgs-firefox.url = "github:nixos/nixpkgs/4bfec1603835ba0cf0197f66e8240dcc178b69d5";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      sops-nix,
      pre-commit-hooks,
      pymodoro,
      nixpkgs-firefox,
    }:
    let
      system = "x86_64-linux";
      pkgsFirefox = import nixpkgs-firefox { inherit system; };
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
                  firefox = pkgsFirefox.firefox;
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
