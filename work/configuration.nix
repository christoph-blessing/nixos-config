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
}
