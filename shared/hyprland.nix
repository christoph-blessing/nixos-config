{ ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    extraConfig = ''
      hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

      local mod = "SUPER"
      local terminal = "alacritty"
      local menu = "wofi --show drun"

      hl.bind(mod .. " + Q", hl.dsp.exec_cmd(terminal))
      hl.bind(mod .. " + R", hl.dsp.exec_cmd(menu))
      hl.bind(mod .. " + L", hl.dsp.exec_cmd("hyprlock"))
      hl.bind(mod .. " + G", hl.dsp.exec_cmd("grimblast copy area"))
      hl.bind(mod .. " + C", hl.dsp.window.close())
      hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
      hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
      hl.bind(mod .. " + Tab", hl.dsp.focus({ workspace = "previous" }))

      for _, dir in ipairs({ "left", "right", "up", "down" }) do
        hl.bind(mod .. " + " .. dir,  hl.dsp.focus({ direction = dir }))
        hl.bind(mod .. " + SHIFT + " .. dir, hl.dsp.window.swap({ direction = dir }))
      end

      for i = 1, 10 do
        local key = i % 10
        hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
        hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
      end

      hl.animation({ leaf = "global", enabled = false })
      hl.config({ general = { gaps_in = 0, gaps_out = 0, border_size = 2 }, input = { kb_options = "compose:menu" } })

      hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })
      hl.window_rule({
        match = { class = "^(zoom)$", title = "^(menu window)$" },
        move  = "onscreen cursor",
      })
    '';
  };
}
