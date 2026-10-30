local M = {}
M.mod = "SUPER"

function M.main()
	hl.exec_cmd(
		"systemctl --user import-environment WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP && systemctl --user start hyprland-session.target"
	)

	local terminal = "alacritty"
	local menu = "wofi --show drun"

	hl.bind(M.mod .. " + Q", hl.dsp.exec_cmd(terminal))
	hl.bind(M.mod .. " + R", hl.dsp.exec_cmd(menu))
	hl.bind(M.mod .. " + L", hl.dsp.exec_cmd("hyprlock"))
	hl.bind(M.mod .. " + G", hl.dsp.exec_cmd("grimblast copy area"))
	hl.bind(M.mod .. " + C", hl.dsp.window.close())
	hl.bind(M.mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
	hl.bind(M.mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))

	for _, dir in ipairs({ "left", "right", "up", "down" }) do
		hl.bind(M.mod .. " + " .. dir, hl.dsp.focus({ direction = dir }))
		hl.bind(M.mod .. " + SHIFT + " .. dir, hl.dsp.window.swap({ direction = dir }))
	end

	hl.animation({ leaf = "global", enabled = false })
	hl.config({
		general = { gaps_in = 0, gaps_out = 0, border_size = 2 },
		input = { kb_options = "compose:menu" },
		misc = { focus_on_activate = true },
	})

	hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

	hl.window_rule({
		match = { class = "^(zoom)$", title = "^(menu window)$" },
		move = "onscreen cursor",
	})
	hl.window_rule({
		name = "zoom-annotate-toolbar",
		match = { class = "^(zoom)$", initial_title = "^(annotate_toolbar)$" },
		float = true,
		no_initial_focus = true,
		no_anim = true,
		move = "onscreen cursor",
	})
	hl.window_rule({
		name = "zoom-no-blur",
		match = { class = "^(zoom)$" },
		no_blur = true,
		no_shadow = true,
	})
	-- Zoom's screen share toolbar is an override-redirect X11 window typed as a tooltip, which Hyprland
	-- passes pointer input through. Retype it, and keep it on the active workspace because Hyprland only
	-- hit-tests windows on visible workspaces.
	local zoom_share_toolbar = "as_toolbar"
	local function is_zoom_share_toolbar(window)
		return window.class == "zoom" and window.initial_title == zoom_share_toolbar
	end
	hl.on("window.open", function(window)
		if is_zoom_share_toolbar(window) then
			hl.exec_cmd(
				"xprop -name "
					.. zoom_share_toolbar
					.. " -f _NET_WM_WINDOW_TYPE 32a -set _NET_WM_WINDOW_TYPE _NET_WM_WINDOW_TYPE_NORMAL"
			)
		end
	end)
	hl.on("workspace.active", function(workspace)
		for _, window in ipairs(hl.get_windows()) do
			if is_zoom_share_toolbar(window) then
				hl.dispatch(hl.dsp.window.move({ workspace = tostring(workspace.id), follow = false, window = window }))
			end
		end
	end)
	hl.window_rule({
		name = "zoom-no-focus-on-activate",
		match = { class = "^(zoom)$" },
		focus_on_activate = false,
	})
end

return M
