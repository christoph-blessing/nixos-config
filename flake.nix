{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager }: {
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
      ];
    };
    nixosConfigurations.nixe-work = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./work/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.chris = import ./work/home.nix;
        }
      ];
    };
  };
}
