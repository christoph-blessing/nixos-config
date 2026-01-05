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
  };

  outputs =
    {
      self,
      nixpkgs,
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
            {
              nixpkgs.overlays = [
                (final: prev: {
                  goimapnotify = prev.goimapnotify.overrideAttrs (old: {
                    src = prev.fetchFromGitLab {
                      owner = "shackra";
                      repo = "goimapnotify";
                      tag = "2.5.4";
                      hash = "sha256-6hsepgXdG+BSSKTVics2459qUxYPIHKNqm2yq8UJXks=";
                    };
                  });
                })
                (final: prev: {
                  vimPlugins = prev.vimPlugins // {
                    nvim-treesitter-textobjects = prev.vimPlugins.nvim-treesitter-textobjects.overrideAttrs (old: {
                      src = prev.fetchFromGitHub {
                        owner = "nvim-treesitter";
                        repo = "nvim-treesitter-textobjects";
                        rev = "28a3494c075ef0f353314f627546537e43c09592";
                        hash = "sha256-5VeIAW09my+4fqXbzVG7RnLXrjpXAk/g2vd7RbhNws8=";
                      };
                    });
                  };
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
