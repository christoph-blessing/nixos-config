{ pkgs, lib, ... }:
{
  imports = [ ../shared/hypridle.nix ];
  services.hypridle.settings.listener =
    let
      displayctl = pkgs.writeShellScriptBin "displayctl" ''
        PATH=${
          lib.makeBinPath [
            pkgs.coreutils
            pkgs.hyprland
            pkgs.brightnessctl
          ]
        }

        should_be_plugged_in=$1
        action=$2

        if [ $(${pkgs.coreutils}/bin/cat /sys/class/power_supply/AC/online) -eq "$should_be_plugged_in" ]; then
          if [ "$action" = "timeout" ]; then
            hyprctl dispatch dpms off
          else
            hyprctl dispatch dpms on && brightnessctl -r
          fi
        fi
      '';
    in
    [
      {
        timeout = 270;
        on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10";
        on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -r";
      }
      {
        timeout = 300;
        on-timeout = "${pkgs.systemd}/bin/loginctl lock-session";
      }
      {
        timeout = 330;
        on-timeout = "${displayctl}/bin/displayctl 0 timeout";
        on-resume = "${displayctl}/bin/displayctl 0 resume";
      }
      {
        timeout = 600;
        on-timeout = "${displayctl}/bin/displayctl 1 timeout";
        on-resume = "${displayctl}/bin/displayctl 1 resume";
      }
    ];
}
