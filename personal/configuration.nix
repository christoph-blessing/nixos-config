{
  lib,
  pkgs,
  ...
}:

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

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-x11"
      "nvidia-settings"
      "steam"
      "steam-original"
      "steam-run"
      "steam-unwrapped"
      "teamspeak3"
    ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    os-prober
    protonup-qt
  ];

  boot.initrd.systemd.enable = true;

  boot.kernelParams = [ "nvidia-drm.modeset=1" ];
  programs.gamescope = {
    enable = true;
    capSysNice = false;
  };

  hardware.nvidia.open = true;

  services.udev.extraRules = ''
    # HW.1, Nano
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="1b7c|2b7c|3b7c|4b7c", TAG+="uaccess", TAG+="udev-acl"

    # Blue, NanoS, Aramis, HW.2, Nano X, NanoSP, Stax, Ledger Test,
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2c97", TAG+="uaccess", TAG+="udev-acl"

    # Same, but with hidraw-based library (instead of libusb)
    KERNEL=="hidraw*", ATTRS{idVendor}=="2c97", MODE="0666"
  '';

  services.monero.enable = true;
}
