{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../shared/configuration.nix
    ];

  networking.hostName = "nixe-work";

  sops.secrets = {
      wireless_env = { };
    };

  networking.wireless = {
    enable = true;
    userControlled.enable = true;
    environmentFile = "/run/secrets/wireless_env";
    networks.s2blHXGXbwQeTARZ.psk = "@PSK@";
    networks.eduroam = {
      auth = ''
        key_mgmt=WPA-EAP
        eap=PEAP
        ca_cert="/etc/ssl/certs/T-TeleSec_GlobalRoot_Class_2_pem"
        identity="@IDENTITY@"
        altsubject_match="DNS:eduroam.gwdg.de"
        phase2="auth=MSCHAPV2"
        password="@PASSWORD@"
        anonymous_identity="eduroam@gwdg.de"
      '';
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

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "zoom"
  ];

  environment.systemPackages = with pkgs; [
    zoom-us
  ];

  virtualisation.docker.enable = true;
  users.users.chris.extraGroups = [ "docker" ];

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
