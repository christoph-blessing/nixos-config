{ lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../shared/configuration.nix
    ./mitmproxy.nix
  ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_13;
  boot.initrd = {
    kernelModules = [
      "vfat"
      "nls_cp437"
      "nls_iso8859-1"
      "usbhid"
    ];
    luks = {
      yubikeySupport = true;
      devices.cryptroot = {
        device = "/dev/disk/by-uuid/9beadd98-f8e3-4bdd-8c3b-15619ae38609";
        yubikey = {
          slot = 2;
          twoFactor = true;
          gracePeriod = 30;
          keyLength = 64;
          saltLength = 32;
          storage = {
            device = "/dev/disk/by-uuid/BC2B-6537";
            fsType = "vfat";
            path = "/crypt-storage/default";
          };
        };
      };
    };
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
      eduroam = {
        "802-1x" = {
          anonymous-identity = "eduroam@gwdg.de";
          ca-cert = "/run/secrets/network/eduroam-ca-cert.pem";
          domain-suffix-match = "eduroam.gwdg.de";
          eap = "peap;";
          identity = "$IDENTITY";
          password = "$PASSWORD";
          phase2-auth = "mschapv2";
        };
        connection = {
          id = "eduroam";
          type = "wifi";
          uuid = "af4e59e8-862d-4a8e-84e2-aa59816652e6";
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
          ssid = "eduroam";
        };
        wifi-security = {
          key-mgmt = "wpa-eap";
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
      "zoom"
      "ipu6-camera-bins-unstable"
      "ipu6-camera-bins"
      "ivsc-firmware-unstable"
      "ivsc-firmware"
    ];

  environment.systemPackages = with pkgs; [
    (zoom-us.overrideAttrs {
      version = "6.2.11.5069";
      src = pkgs.fetchurl {
        url = "https://zoom.us/client/6.2.11.5069/zoom_x86_64.pkg.tar.xz";
        hash = "sha256-k8T/lmfgAFxW1nwEyh61lagrlHP5geT2tA7e5j61+qw=";
      };
    })
    eduvpn-client
    solaar
    zip
    unzip
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
      ENV{SUBSYSTEM}=="bluetooth",\
      RUN+="${pkgs.bash}/bin/bash -c 'export DISPLAY=:0 XAUTHORITY=/home/chris/.Xauthority; ${pkgs.bluez}/bin/bluetoothctl devices Connected | ${pkgs.gnugrep}/bin/grep urchin && ${pkgs.xorg.xinput}/bin/xinput disable \"AT Translated Set 2 keyboard\"'"
    ACTION=="remove",\
      ENV{SUBSYSTEM}=="bluetooth",\
      RUN+="${pkgs.bash}/bin/bash -c 'export DISPLAY=:0 XAUTHORITY=/home/chris/.Xauthority; ${pkgs.bluez}/bin/bluetoothctl devices Connected | ${pkgs.gnugrep}/bin/grep urchin || ${pkgs.xorg.xinput}/bin/xinput enable \"AT Translated Set 2 keyboard\"'"
    ACTION=="add",\
      ENV{SUBSYSTEM}=="drm",\
      RUN+="${pkgs.autorandr}/bin/autorandr --batch --change"
    ACTION=="remove",\
      ENV{SUBSYSTEM}=="drm",\
      RUN+="${pkgs.autorandr}/bin/autorandr --batch --change"
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

  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    lidSwitchExternalPower = "suspend-then-hibernate";
  };

  hardware.logitech.wireless.enable = true;

  services.xserver = {
    deviceSection = ''
      Option "ModeValidation" "AllowNonEdidModes"
    '';
    xrandrHeads = [
      {
        output = "DP-1";
        monitorConfig = ''
          Modeline "5120x1440_60.00"  624.50  5120 5496 6048 6976  1440 1443 1453 1493 -hsync +vsync
        '';
      }
    ];
    xkb.extraLayouts = {
      mine = {
        description = "My custom xkb layout.";
        languages = [ "eng" ];
        symbolsFile = ./keyboard/xkb_symbols;
      };
    };
  };

  services.guix.enable = true;

  services.printing.enable = true;

  hardware.ipu6 = {
    enable = false;
    platform = "ipu6epmtl";
  };
}
