{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../shared/configuration.nix
  ];

  nixpkgs.overlays = [
    (final: prev: { himalaya = prev.himalaya.override { buildFeatures = [ "notmuch" ]; }; })
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.luks.devices.cryptroot.device = "/dev/disk/by-uuid/9beadd98-f8e3-4bdd-8c3b-15619ae38609";

  networking.hostName = "nixe-work";

  sops.secrets = {
    wireless_env = { };
  };

  networking.networkmanager = {
    enable = true;
    ensureProfiles.environmentFiles = [ "/run/secrets/wireless_env" ];
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
          ca-cert = "/etc/ssl/certs/T-TeleSec_GlobalRoot_Class_2_pem";
          eap = "peap;";
          identity = "$IDENTITY";
          password = "$PASSWORD";
          phase2-auth = "mschapv2";
        };
        connection = {
          id = "eduroam";
          timestamp = "1715177091";
          type = "wifi";
          uuid = "499c369b-f09e-43bc-8aca-adb236e9a0de";
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

  sound.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "zoom" ];

  environment.systemPackages = with pkgs; [
    zoom-us
    eduvpn-client
    solaar
  ];

  virtualisation.docker.enable = true;

  users.users.chris.extraGroups = [
    "docker"
    "networkmanager"
  ];

  services.libinput.touchpad = {
    naturalScrolling = true;
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
  };
}
