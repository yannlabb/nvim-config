vim.pack.add({
	{ src = 'https://github.com/neovim/nvim-lspconfig' },
	{ src = 'https://github.com/ctrlpvim/ctrlp.vim',            name = 'ctrlp' },
	{ src = 'https://github.com/neogitorg/neogit',              name = 'neogit' },
	{ src = 'https://github.com/stevearc/oil.nvim',             name = 'oil' },
	{ src = 'https://github.com/nvim-telescope/telescope.nvim', name = 'telescope' },
	{ src = 'https://github.com/nvim-lua/plenary.nvim',         name = 'plenary' },
})
require("oil").setup(
	{ view_options = { show_hidden = true } }
)

vim.lsp.codelens.enable()
vim.lsp.linked_editing_range.enable()
vim.lsp.inlay_hint.enable(false)
vim.lsp.inline_completion.enable()
vim.lsp.on_type_formatting.enable()
vim.lsp.semantic_tokens.enable()
vim.lsp.enable('lua_ls')
vim.keymap.set("n", "<C-p>", "<cmd>CtrlPMRUFiles<cr>")
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { remap = true })
vim.opt.clipboard:append('unnamedplus')
vim.opt.exrc = true
vim.opt.secure = true
vim.opt.autocomplete = true
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>gg", "<cmd>Neogit cwd=%:p:h<cr>")
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>bf", function() vim.lsp.buf.format() end, { desc = "Format buffer using LSP" })
local group = vim.api.nvim_create_augroup("AutoWrite", { clear = true })
vim.api.nvim_create_autocmd({ "InsertLeave", "BufWritePre" }, {
	group = group,
	callback = function(args)
		if #vim.lsp.get_clients({ bufnr = args.buf }) > 0 then
			vim.lsp.buf.format()
			vim.cmd("write")
		end
	end
})

local group = vim.api.nvim_create_augroup("ConfigReload", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { ".nvim.lua", "init.lua" },
	group = group,
	callback = function(args)
		vim.cmd("silent source " .. vim.fn.fnameescape(args.file))
		vim.schedule(function() vim.notify("Lua file reloaded") end)
	end
})
