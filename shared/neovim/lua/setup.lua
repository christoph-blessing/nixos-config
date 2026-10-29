local M = {}

function M.setup(options)
	vim.cmd.hi("Comment gui=none")
	vim.g.mapleader = " "
	vim.g.maplocalleader = ","
	vim.g.have_nerd_font = true
	vim.o.number = true
	vim.o.relativenumber = true
	vim.o.mouse = "a"
	vim.o.showmode = false

	vim.schedule(function()
		vim.opt.clipboard = "unnamedplus"
	end)

	vim.o.breakindent = true
	vim.o.undofile = true
	vim.o.ignorecase = true
	vim.o.smartcase = true
	vim.o.signcolumn = "yes"
	vim.o.updatetime = 250
	vim.o.timeoutlen = 500
	vim.o.splitright = true
	vim.o.splitbelow = true
	vim.o.list = true
	vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
	vim.o.inccommand = "split"
	vim.o.cursorline = true
	vim.o.scrolloff = 10
	vim.o.confirm = true
	vim.o.backupcopy = "yes"
	vim.o.winborder = "rounded"

	vim.wo.foldmethod = "expr"
	vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
	vim.wo.foldlevel = 99

	vim.opt.hlsearch = true
	vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

	vim.keymap.set("n", "]d", function()
		vim.diagnostic.jump({ count = 1, float = true })
	end, { desc = "Go to next [D]iagnostic message" })
	vim.keymap.set("n", "[d", function()
		vim.diagnostic.jump({ count = -1, float = true })
	end, { desc = "Go to previous [D]iagnostic message" })
	vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
	vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

	vim.keymap.set("n", "<C-left>", "<C-w><C-h>", { desc = "Move focus to the left window" })
	vim.keymap.set("n", "<C-right>", "<C-w><C-l>", { desc = "Move focus to the right window" })
	vim.keymap.set("n", "<C-down>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
	vim.keymap.set("n", "<C-up>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

	vim.api.nvim_create_autocmd("TextYankPost", {
		desc = "Highlight when yanking (copying) text",
		group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
		callback = function()
			vim.highlight.on_yank()
		end,
	})

	vim.api.nvim_create_user_command("CopyPathLine", function(opts)
		local path = vim.api.nvim_buf_get_name(0)
		if path == "" then
			vim.notify("buffer has no file", vim.log.levels.WARN)
			return
		end
		local position = tostring(opts.line1)
		if opts.range > 0 then
			position = position .. "-" .. opts.line2
		end
		vim.fn.setreg("+", path .. ":" .. position)
	end, { range = true, desc = "Copy path:line to clipboard" })
	vim.keymap.set({ "n", "x" }, "<leader>p", ":CopyPathLine<cr>", { desc = "Copy path:line", silent = true })

	vim.api.nvim_create_autocmd("BufReadCmd", {
		pattern = "jar://*",
		callback = function(args)
			local jar, entry = args.file:sub(#"jar://" + 1):match("^(.*)!/(.*)$")
			local res = vim.system({ "unzip", "-p", jar, entry }, { text = true }):wait()
			local lines = vim.split(res.stdout or "", "\r?\n")
			if lines[#lines] == "" then
				table.remove(lines)
			end

			local buf = args.buf
			vim.bo[buf].modifiable = true
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
			vim.bo[buf].buftype = "nofile"
			vim.bo[buf].swapfile = false
			vim.bo[buf].modifiable = false
			vim.bo[buf].readonly = true
			vim.bo[buf].filetype = vim.filetype.match({ filename = entry, buf = buf }) or ""
		end,
	})

	require("lazy").setup({
		spec = {
			{ import = "plugins" },
		},
		performance = {
			reset_packpath = false,
			rtp = {
				reset = false,
			},
		},
		dev = {
			path = options.lazy_dev_path,
			patterns = { "" },
		},
		install = {
			missing = false,
		},
	})
end

return M
