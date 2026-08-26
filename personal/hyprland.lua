local shared = require("shared")
shared.main()

hl.monitor({ output = "DP-2", mode = "5120x1440@239.76", position = "auto", scale = 1 })

for i = 1, 10 do
	local key = i % 10
	hl.bind(shared.mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(shared.mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
