{ pkgs, ... }:
{
  imports = [ ../shared/hyprland.nix ];
  wayland.windowManager.hyprland = {
    extraConfig = with pkgs; ''
      hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })

      local ws = {
        terminal = { id = 1, key = "T" },
        web = { id = 2, key = "W" },
        ai = { id = 3, key = "A" },
        password = { id = 4, key = "P" },
        messenger = { id = 5, key = "M" },
      }
      for name, config in pairs(ws) do
        hl.workspace_rule({ workspace = tostring(config.id), default_name = name, persistent = true })
        hl.bind(mod .. " + " .. config.key, hl.dsp.focus({ workspace = tostring(config.id) }))
        hl.bind(mod .. " + SHIFT + " .. config.key, hl.dsp.window.move({ workspace = tostring(config.id) }))
      end

      hl.window_rule({
        name      = "firefox-default",
        match     = { initial_class = "^(firefox-default)$" },
        workspace = ws.web.id .. " silent",
      })

      hl.on("hyprland.start", function()
        hl.exec_cmd("env MOZ_APP_REMOTINGNAME=firefox-default ${pkgs.firefox}/bin/firefox -P default --class firefox-default")
      end)

      hl.window_rule({
        name      = "firefox-ai",
        match     = { initial_class = "^(firefox-ai)$" },
        workspace = ws.ai.id .. " silent",
      })

      hl.on("hyprland.start", function()
        hl.exec_cmd("env MOZ_APP_REMOTINGNAME=firefox-ai ${pkgs.firefox}/bin/firefox -P ai")
      end)

      hl.window_rule({
        name      = "keepassxc",
        match     = { initial_class = "^(org\\.keepassxc\\.KeePassXC)$" },
        workspace = ws.password.id .. " silent",
      })

      hl.on("hyprland.start", function()
        hl.exec_cmd("${keepassxc}/bin/keepassxc")
      end)

      hl.window_rule({
        name      = "element-home",
        match     = { initial_class = "^(element)$" },
        workspace = ws.messenger.id .. " silent",
      })

      hl.on("hyprland.start", function()
        hl.exec_cmd("${pkgs.gtk3}/bin/gtk-launch element-desktop")
      end)

      hl.on("hyprland.start", function()
        hl.exec_cmd("${alacritty}/bin/alacritty", { workspace = ws.terminal.id })
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
