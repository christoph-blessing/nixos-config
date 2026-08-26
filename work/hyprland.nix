{ pkgs, ... }:
{
  imports = [ ../shared/hyprland.nix ];
  wayland.windowManager.hyprland = {
    extraConfig = with pkgs; ''
      hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })

      local ws = { terminal = 1, web = 2, ai = 3, password = 4, messenger = 5 }
      for name, id in pairs(ws) do
        hl.workspace_rule({ workspace = tostring(id), default_name = name, persistent = true })
      end

      hl.window_rule({
        name      = "firefox-default",
        match     = { initial_class = "^(firefox-default)$" },
        workspace = ws.web .. " silent",
      })

      hl.on("hyprland.start", function()
        hl.exec_cmd("env MOZ_APP_REMOTINGNAME=firefox-default ${pkgs.firefox}/bin/firefox -P default --class firefox-default")
      end)

      hl.window_rule({
        name      = "firefox-ai",
        match     = { initial_class = "^(firefox-ai)$" },
        workspace = ws.ai .. " silent",
      })

      hl.on("hyprland.start", function()
        hl.exec_cmd("env MOZ_APP_REMOTINGNAME=firefox-ai ${pkgs.firefox}/bin/firefox -P ai")
      end)

      hl.window_rule({
        name      = "keepassxc",
        match     = { initial_class = "^(org\\.keepassxc\\.KeePassXC)$" },
        workspace = ws.password .. " silent",
      })

      hl.on("hyprland.start", function()
        hl.exec_cmd("${keepassxc}/bin/keepassxc")
      end)

      hl.window_rule({
        name      = "element-home",
        match     = { initial_class = "^(element)$" },
        workspace = ws.messenger .. " silent",
      })

      hl.on("hyprland.start", function()
        hl.exec_cmd("${pkgs.gtk3}/bin/gtk-launch element-desktop")
      end)

      hl.on("hyprland.start", function()
        hl.exec_cmd("${alacritty}/bin/alacritty",             { workspace = ws.terminal })
        hl.exec_cmd("${zellij}/bin/zellij kill-all-sessions --yes")
      end)

      hl.bind("switch:on:Lid Switch", function()
        for _, m in ipairs(hl.get_monitors()) do
          if m.name:match("^DP%-") then return end
        end
        hl.exec_cmd("${pkgs.systemd}/bin/loginctl lock-session")
      end, { locked = true })
    '';
  };
}
