local M = {}

function M.setup(options)
	vim.cmd.hi("Comment gui=none")
	vim.g.mapleader = " "
	vim.g.maplocalleader = " "
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
	vim.o.timeoutlen = 300
	vim.o.splitright = true
	vim.o.splitbelow = true
	vim.o.list = true
	vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
	vim.o.inccommand = "split"
	vim.o.cursorline = true
	vim.o.scrolloff = 10
	vim.o.confirm = true

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

	vim.keymap.set("n", "h", "<Nop>")
	vim.keymap.set("n", "l", "<Nop>")
	vim.keymap.set("n", "j", "<Nop>")
	vim.keymap.set("n", "k", "<Nop>")

	vim.keymap.set("v", "h", "<Nop>")
	vim.keymap.set("v", "l", "<Nop>")
	vim.keymap.set("v", "j", "<Nop>")
	vim.keymap.set("v", "k", "<Nop>")

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
