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
vim.opt.autocomplete = false
vim.opt.complete = 'o,.,w,b,u,t'
vim.cmd [[set completeopt+=menuone,noselect,popup]]
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>gg", "<cmd>Neogit cwd=%:p:h<cr>")
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>bf", function() vim.lsp.buf.format() end, { desc = "Format buffer using LSP" })

vim.api.nvim_create_autocmd({ "InsertLeave", }, {
	group = vim.api.nvim_create_augroup("AutoWrite", { clear = true }),
	callback = function(args)
		vim.cmd("write")
	end
})


vim.api.nvim_create_autocmd({ "BufWritePre", "InsertLeave" }, {
	group = vim.api.nvim_create_augroup("AutoFormat", { clear = true }),
	callback = function(args)
		if #vim.lsp.get_clients({ bufnr = args.buf }) > 0 then
			vim.lsp.buf.format()
		end
	end
})

vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = { ".nvim.lua", "init.lua" },
	group = vim.api.nvim_create_augroup("ConfigReload", { clear = true }),
	callback = function(args)
		vim.cmd("silent source " .. vim.fn.fnameescape(args.file))
		vim.schedule(function() vim.notify("Lua file reloaded") end)
	end
})


vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	group = vim.api.nvim_create_augroup("ProjectNvimLua", { clear = true }),
	callback = function(args)
		local file = args.file
		if file == "" then
			return
		end

		local root = vim.fs.root(file, ".git")
		if not root then
			return
		end

		local project_config = vim.fs.joinpath(root, ".nvim.lua")

		if vim.fn.filereadable(project_config) == 1 then
			-- avoid re-sourcing repeatedly for every buffer
			if vim.g._last_project_nvim_lua ~= project_config then
				vim.g._last_project_nvim_lua = project_config

				vim.cmd("source " .. vim.fn.fnameescape(project_config))
				vim.notify("Loaded " .. project_config)
			end
		end
	end,
})
