-- Loaded only by the `nvim-dev` nushell command: restarts this instance
-- whenever a file in the repo's lua/ dir changes, so config edits can be
-- tested without a rebuild.
local dir = vim.fs.joinpath(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)), "lua")
local timer = assert(vim.uv.new_timer())
local watcher = assert(vim.uv.new_fs_event())

watcher:start(dir, {}, function(err)
	if err then
		return
	end
	-- a single save fires several fs events
	timer:start(
		200,
		0,
		vim.schedule_wrap(function()
			vim.cmd("restart")
		end)
	)
end)
