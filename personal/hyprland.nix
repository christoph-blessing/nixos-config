{ ... }:
{
  imports = [ ../shared/hyprland.nix ];
  wayland.windowManager.hyprland.settings.monitor = [
    "DP-2,5120x1440@239.76,auto,1"
  ];
}
