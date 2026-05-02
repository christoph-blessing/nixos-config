{ pkgs, lib, ... }:
{
  imports = [ ../shared/hyprland.nix ];
  wayland.windowManager.hyprland.settings = {
    monitor = [
      "eDP-1,preferred,auto,1"
    ];
    workspace = [
      "1,defaultName:terminal"
      "2,defaultName:web"
      "3,defaultName:ai"
      "4,defaultName:password"
      "5,defaultName:messenger"
    ];
    exec-once = with pkgs; [
      "[workspace 1] ${alacritty}/bin/alacritty"
      "[workspace 2 silent] ${firefox}/bin/firefox -P default"
      "[workspace 3 silent] ${firefox}/bin/firefox -P ai"
      "[workspace 4 silent] ${keepassxc}/bin/keepassxc"
      "[workspace 5 silent] ${gtk3}/bin/gtk-launch element-desktop"
      "${zellij}/bin/zellij kill-all-sessions --yes"
      "${hypridle}/bin/hypridle"
    ];
    bindl =
      let
        lidctl = pkgs.writeShellScriptBin "lidctl" ''
          PATH=${
            lib.makeBinPath [
              pkgs.hyprland
              pkgs.ripgrep
              pkgs.systemd
            ]
          }

          hyprctl monitors | rg -q ' DP-'
          external_display_connected=$?

          if [ "$external_display_connected" -eq 1 ]; then
            loginctl lock-session
          fi
        '';
      in
      [
        ",switch:Lid Switch,exec,${lidctl}/bin/lidctl"
      ];
  };
}
