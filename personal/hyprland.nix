{ ... }:
{
  imports = [ ../shared/hyprland.nix ];
  wayland.windowManager.hyprland.extraConfig = ''
    hl.monitor({ output = "DP-2", mode = "5120x1440@239.76", position = "auto", scale = 1 })
  '';
}
