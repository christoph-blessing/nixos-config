{ ... }:
{
  imports = [ ../shared/hyprland.nix ];
  xdg.configFile."hypr/hyprland.lua".source = ./hyprland.lua;
}
