local bufnr = vim.api.nvim_get_current_buf()

vim.keymap.set("n", "<leader>e", function()
	vim.cmd.RustLsp("renderDiagnostic")
end, { buffer = bufnr, desc = "Rendered rustc diagnostic" })

vim.keymap.set("n", "<leader>x", function()
	vim.cmd.RustLsp("explainError")
end, { buffer = bufnr, desc = "rustc --explain" })
