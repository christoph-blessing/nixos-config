{ pkgs, ... }:
{
  imports = [ ../shared/hyprland.nix ];
  xdg.configFile."hypr/hyprland.lua".source = ./hyprland.lua;
  xdg.configFile."hypr/paths.lua".text = with pkgs; ''
    local M = {}

    M.firefox = "${firefox}/bin/firefox"
    M.keepassxc = "${keepassxc}/bin/keepassxc"
    M.gtk_launch = "${pkgs.gtk3}/bin/gtk-launch"
    M.alacritty = "${alacritty}/bin/alacritty"
    M.zellij = "${zellij}/bin/zellij"
    M.loginctl = "${pkgs.systemd}/bin/loginctl"

    return M
  '';
}
