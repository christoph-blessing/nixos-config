{ ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    extraConfig = ''
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
      hl.config({ general = { gaps_in = 0, gaps_out = 0, border_size = 2 } })
    '';
    settings = {
      # monitor = [
      #   ",preferred,auto,auto"
      # ];
      # windowrule = [
      #   "suppress_event maximize, match:class .*"
      #   "no_initial_focus on,match:class ^$,match:title ^$,match:xwayland 1,match:float 1,match:fullscreen 0,match:pin 0"
      #   "move onscreen cursor, match:title ^(menu window)$, match:class ^(zoom)$"
      # ];
    };
  };
}
