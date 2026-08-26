local M = {}
M.mod = "SUPER"

function M.main()
	local terminal = "alacritty"
	local menu = "wofi --show drun"

	hl.bind(M.mod .. " + Q", hl.dsp.exec_cmd(terminal))
	hl.bind(M.mod .. " + R", hl.dsp.exec_cmd(menu))
	hl.bind(M.mod .. " + L", hl.dsp.exec_cmd("hyprlock"))
	hl.bind(M.mod .. " + G", hl.dsp.exec_cmd("grimblast copy area"))
	hl.bind(M.mod .. " + C", hl.dsp.window.close())
	hl.bind(M.mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
	hl.bind(M.mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
	hl.bind(M.mod .. " + Tab", hl.dsp.focus({ workspace = "previous" }))

	for _, dir in ipairs({ "left", "right", "up", "down" }) do
		hl.bind(M.mod .. " + " .. dir, hl.dsp.focus({ direction = dir }))
		hl.bind(M.mod .. " + SHIFT + " .. dir, hl.dsp.window.swap({ direction = dir }))
	end

	hl.animation({ leaf = "global", enabled = false })
	hl.config({ general = { gaps_in = 0, gaps_out = 0, border_size = 2 }, input = { kb_options = "compose:menu" } })

	hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })
	hl.window_rule({
		match = { class = "^(zoom)$", title = "^(menu window)$" },
		move = "onscreen cursor",
	})
end

return M
