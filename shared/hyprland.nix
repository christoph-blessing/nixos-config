{ ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
  };

  xdg.configFile."hypr/shared.lua".source = ./hyprland.lua;
}
