local bufnr = vim.api.nvim_get_current_buf()

vim.keymap.set("n", "<leader>e", function()
	vim.cmd.RustLsp("renderDiagnostic", "current")
end, { buffer = bufnr, desc = "Rendered rustc diagnostic" })

vim.keymap.set("n", "]d", function()
	vim.cmd.RustLsp("renderDiagnostic", "cycle")
end, { buffer = bufnr, desc = "Go to next [D]iagnostic message" })

vim.keymap.set("n", "[d", function()
	vim.cmd.RustLsp("renderDiagnostic", "cycle_prev")
end, { buffer = bufnr, desc = "Go to previous [D]iagnostic message" })

vim.keymap.set("n", "<leader>x", function()
	vim.cmd.RustLsp("explainError")
end, { buffer = bufnr, desc = "rustc --explain" })

vim.keymap.set("n", "gra", function()
	vim.cmd.RustLsp("codeAction")
end, { buffer = bufnr, desc = "Code action (grouped)" })
