{ config, lib, pkgs, ... }:

{
  imports = [ 
    ./hardware-configuration.nix 
    ../shared/configuration.nix
  ];

  networking.hostName = "nixe";
  
  services.xserver = {
    videoDrivers = [ "nvidia" ];
    resolutions = [
      {
        x = 5120;
        y = 1440;
      }
    ];
  };

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-x11"
      "nvidia-settings"
      "steam"
      "steam-original"
      "steam-run"
      "teamspeak-client"
    ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  boot.kernelParams = [ "nvidia-drm.modeset=1" ];
  programs.gamescope = {
    enable = true;
    capSysNice = false;
  };
}
