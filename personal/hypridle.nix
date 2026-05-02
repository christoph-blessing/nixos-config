{ pkgs, ... }:
{
  imports = [ ../shared/hypridle.nix ];
  services.hypridle.settings.listener = [
    {
      timeout = 300;
      on-timeout = "${pkgs.systemd}/bin/loginctl lock-session";
    }
  ];
}
