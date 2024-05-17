{
  config,
  lib,
  pkgs,
  ...
}:

let
  ivsc-firmware =
    with pkgs;
    stdenv.mkDerivation rec {
      pname = "ivsc-firmware";
      version = "main";

      src = pkgs.fetchFromGitHub {
        owner = "intel";
        repo = "ivsc-firmware";
        rev = "10c214fea5560060d387fbd2fb8a1af329cb6232";
        sha256 = "sha256-kEoA0yeGXuuB+jlMIhNm+SBljH+Ru7zt3PzGb+EPBPw=";
      };

      installPhase = ''
        mkdir -p $out/lib/firmware/vsc/soc_a1_prod

        cp firmware/ivsc_pkg_ovti01a0_0.bin $out/lib/firmware/vsc/soc_a1_prod/ivsc_pkg_ovti01a0_0_a1_prod.bin
        cp firmware/ivsc_skucfg_ovti01a0_0_1.bin $out/lib/firmware/vsc/soc_a1_prod/ivsc_skucfg_ovti01a0_0_1_a1_prod.bin
        cp firmware/ivsc_fw.bin $out/lib/firmware/vsc/soc_a1_prod/ivsc_fw_a1_prod.bin
      '';
    };
in
{
  imports = [
    ./hardware-configuration.nix
    ../shared/configuration.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_6_1;

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
    zoom-us
    eduvpn-client
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
      ENV{SUBSYSTEM}=="input",\
      ENV{PRODUCT}=="5/1d50/615e/1",\
      RUN+="${pkgs.bash}/bin/bash -c 'export DISPLAY=:0 XAUTHORITY=/home/chris/.Xauthority; ${pkgs.xorg.xinput}/bin/xinput disable \"AT Translated Set 2 keyboard\"'"
    ACTION=="remove",\
      ENV{SUBSYSTEM}=="input",\
      ENV{PRODUCT}=="5/1d50/615e/1",\
      RUN+="${pkgs.bash}/bin/bash -c 'export DISPLAY=:0 XAUTHORITY=/home/chris/.Xauthority; ${pkgs.xorg.xinput}/bin/xinput enable \"AT Translated Set 2 keyboard\"'"
    ACTION=="add",\
      ENV{SUBSYSTEM}=="drm",\
      RUN+="${pkgs.autorandr}/bin/autorandr --batch --change"
    ACTION=="remove",\
      ENV{SUBSYSTEM}=="drm",\
      RUN+="${pkgs.autorandr}/bin/autorandr --batch --change"

    SUBSYSTEM!="video4linux", GOTO="hide_cam_end"
    ATTR{name}!="Dummy video device (0x0000)", GOTO="hide_cam_end"
    ACTION=="add", RUN+="${pkgs.coreutils}/bin/mkdir -p /dev/not-for-user"
    ACTION=="add", RUN+="${pkgs.coreutils}/bin/mv -f $env{DEVNAME} /dev/not-for-user/"
    ACTION=="remove", RUN+="${pkgs.coreutils}/bin/rm -f /dev/not-for-user/$name"
    ACTION=="remove", RUN+="${pkgs.coreutils}/bin/rm -f /dev/not-for-user/$env{ID_SERIAL}"
    LABEL="hide_cam_end"
  '';

  hardware.ipu6 = {
    enable = true;
    platform = "ipu6ep";
  };
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = [ ivsc-firmware ];
}
