vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"

vim.o.wrap = false -- do not wrap lines at end of file
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.swapfile = false -- if exited no copy of file
vim.g.mapleader = " "  -- leader bind to space
vim.o.winborder = "rounded"

-- keybindings mode, binding, command
vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set('n', '<leader>q', ':quit<CR>')
vim.keymap.set({ 'n', 'x', 'v' }, '<leader>sh', ':split ')
vim.keymap.set({ 'n', 'x', 'v' }, '<leader>sv', ':vsplit ')
vim.keymap.set("n", "K", vim.lsp.buf.hover)

vim.keymap.set({ 'n', 'v', 'x' }, '<leader>y', '"+y')
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>p', '"+p')

vim.pack.add({
	{ src = "https://github.com/vague2k/vague.nvim" },        -- fresh theme
	{ src = "https://github.com/stevearc/oil.nvim" },         -- file system editor - edit like a buffer
	{ src = "https://github.com/neovim/nvim-lspconfig" },     -- configs for lsps
	{ src = "https://github.com/echasnovski/mini.pick" },     -- file picker with fuzzy finding: alternative - telescope
	{ src = "https://github.com/chomosuke/typst-preview.nvim" }, -- preview for typst language
	{ src = "https://github.com/mason-org/mason.nvim" },      -- lsp manager nvim
	{ src = "https://github.com/hrsh7th/nvim-cmp" },          -- completions ui to interact with lsps
	{ src = "https://github.com/hrsh7th/cmp-nvim-lsp" },      -- connects cmp with nvim-lsp manager
	{ src = "https://github.com/L3MON4D3/LuaSnip" },          -- shows code snippets
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },                -- 
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
})
-- omni complete -> look further into ctrl+x
-- ctrl+x to trigger, then ctrl+o - move with ctrl+n, ctrl+p
-- ctrl+w and d to trigger hover mode

-- tell nvim to use autocomplete from lsp
vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client:supports_method('textDocument/completion') then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end
	end,
})
vim.cmd("set completeopt+=noselect")

-- close window when go to reference
vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	callback = function()
		vim.keymap.set("n", "<CR>", "<CR>:cclose<CR>", { buffer = true, silent = true })
	end,
})

-- require("hover").setup()
require("mason").setup()
require("mini.pick").setup()
require("oil").setup()
-- vim.keymap.set('n', 'gr', vim.lsp.buf.references)
local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", builtin.find_files)
vim.keymap.set("n", "<leader>fg", builtin.live_grep)
vim.keymap.set("n", "<leader>fb", builtin.buffers)
vim.keymap.set("n", "<leader>fh", builtin.help_tags)
vim.keymap.set("n", "gr", builtin.lsp_references)
vim.keymap.set("n", "gd", builtin.lsp_definitions)
-- lsp commands
vim.keymap.set('n', '<leader>f', ":Pick files<CR>")
vim.keymap.set('n', '<leader>h', ":Pick help<CR>")
vim.keymap.set('n', '<leader>e', ":Oil<CR>")

-- add functionality of lsps to nvim-cmp if it is available
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if ok then
	capabilities = cmp_lsp.default_capabilities(capabilities)
end
local cmp = require("cmp")

cmp.setup({
	mapping = cmp.mapping.preset.insert({
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		["<Tab>"] = cmp.mapping.select_next_item(),
		["<S-Tab>"] = cmp.mapping.select_prev_item(),
	}),
	sources = {
		{ name = "nvim_lsp" },
	},
})

vim.lsp.config.pyright = {
	cmd = { "pyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = { ".git", "pyproject.toml", "setup.py" },
	capabilities = capabilities,
}
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.lsp.start({
			name = "pyright",
			cmd = { "pyright-langserver", "--stdio" },
			root_dir = vim.fn.getcwd(),
		})
	end,
})

vim.lsp.enable({ "lua_ls", "clangd", "pyright", "ts_ls" })
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)

vim.lsp.config("ts_ls", {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_markers = { "package.json", "tsconfig.json", "jsconfig.json" },
})

vim.cmd("colorscheme vague")
vim.cmd(":hi statusline guibg=NONE") --no bg for status line
