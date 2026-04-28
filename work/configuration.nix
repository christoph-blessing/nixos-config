{ lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../shared/configuration.nix
    ./mitmproxy.nix
  ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_18;
  boot.initrd = {
    kernelModules = [
      "vfat"
      "nls_cp437"
      "nls_iso8859-1"
      "usbhid"
    ];
    luks.devices.cryptroot.device = "/dev/disk/by-uuid/9beadd98-f8e3-4bdd-8c3b-15619ae38609";
  };

  swapDevices = [ { label = "swap"; } ];

  networking.hostName = "nixe-work";

  sops.secrets = {
    "network/network-manager.env" = { };
    "network/eduroam-ca-cert.pem" = { };
  };

  networking.networkmanager = {
    enable = true;
    ensureProfiles.environmentFiles = [ "/run/secrets/network/network-manager.env" ];
    ensureProfiles.profiles = {
      home = {
        connection = {
          id = "home";
          timestamp = "1715162203";
          type = "wifi";
          uuid = "fc58d037-7cfb-478f-b7de-d17ed3311180";
        };
        ipv4 = {
          method = "auto";
        };
        ipv6 = {
          addr-gen-mode = "default";
          method = "auto";
        };
        proxy = { };
        wifi = {
          mode = "infrastructure";
          ssid = "s2blHXGXbwQeTARZ";
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "$HOME_PSK";
        };
      };
      parents5g = {
        connection = {
          id = "parents5g";
          type = "wifi";
          uuid = "c238bd94-39ef-4c1e-8cac-51a3b79c10a4";
        };
        ipv4 = {
          method = "auto";
        };
        ipv6 = {
          addr-gen-mode = "default";
          method = "auto";
        };
        proxy = { };
        wifi = {
          mode = "infrastructure";
          ssid = "TP-Link_A71B_5G";
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "$PARENTS_PSK";
        };
      };
      parents = {
        connection = {
          id = "parents";
          type = "wifi";
          uuid = "474d6afa-5fcd-4664-80e0-19398cc6cf75";
        };
        ipv4 = {
          method = "auto";
        };
        ipv6 = {
          addr-gen-mode = "default";
          method = "auto";
        };
        proxy = { };
        wifi = {
          mode = "infrastructure";
          ssid = "TP-Link_A71B";
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "$PARENTS_PSK";
        };
      };
      phone = {
        connection = {
          id = "phone";
          interface-name = "wlp0s20f3";
          type = "wifi";
          uuid = "4000425f-5029-442f-bc37-a769ef6be700";
        };
        ipv4 = {
          method = "auto";
        };
        ipv6 = {
          addr-gen-mode = "default";
          method = "auto";
        };
        proxy = { };
        wifi = {
          mode = "infrastructure";
          ssid = "Chris Pixel 6";
        };
        wifi-security = {
          auth-alg = "open";
          key-mgmt = "wpa-psk";
          psk = "$PHONE_PSK";
        };
      };
    };
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "claude-code"
      "zoom"
      "ipu6-camera-bins-unstable"
      "ipu6-camera-bins"
      "ivsc-firmware-unstable"
      "ivsc-firmware"
    ];

  environment.systemPackages = with pkgs; [
    zoom-us
    eduvpn-client
    solaar
    zip
    unzip
    nitrokey-app2
    libreoffice
    tree
    qrencode
    claude-code
  ];

  virtualisation.docker.enable = true;

  users.users.chris.extraGroups = [
    "docker"
    "networkmanager"
    "video"
  ];

  services.libinput.touchpad = {
    naturalScrolling = true;
    disableWhileTyping = true;
  };

  services.udev.extraRules = ''
    ACTION=="add",\
      ENV{SUBSYSTEM}=="backlight",\
      KERNEL=="intel_backlight",\
      RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/intel_backlight/brightness"
    ACTION=="add",\
      ENV{SUBSYSTEM}=="backlight",\
      KERNEL=="intel_backlight",\
      RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/intel_backlight/brightness"
  '';

  services.fwupd.enable = true;

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
  };

  hardware.logitech.wireless.enable = true;

  services.guix.enable = true;

  services.printing.enable = true;

  hardware.ipu6 = {
    enable = true;
    platform = "ipu6epmtl";
  };

  hardware.nitrokey.enable = true;

  programs.nix-ld.enable = true;

  networking.firewall.checkReversePath = "loose";

  networking.hosts = {
    "127.0.0.1" = [ "keycloak" ];
  };

  xdg.mime.defaultApplications = {
    "x-scheme-handler/element" = [ "element-desktop.desktop" ];
    "x-scheme-handler/io.element.desktop" = [ "element-desktop.desktop" ];
  };

}
