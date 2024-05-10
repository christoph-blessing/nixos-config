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

  networking.hostName = "nixe-work";

  sops.secrets = {
    wireless_env = { };
  };

  networking.networkmanager = {
    enable = true;
    ensureProfiles.environmentFiles = [ "/run/secrets/wireless_env" ];
    ensureProfiles.profiles = {
      Home = {
        connection = {
          id = "Home";
          timestamp = "1715162203";
          type = "wifi";
          uuid = "5a7ed94b-4912-476b-8eb9-e1a3c994ace0";
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
          id = "Eduroam";
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
      Parents = {
        connection = {
          id = "Parents";
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
  ];

  virtualisation.docker.enable = true;

  users.users.chris.extraGroups = [
    "docker"
    "networkmanager"
  ];

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
  '';
}
