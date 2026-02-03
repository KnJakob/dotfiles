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


vim.pack.add({
	{ src = "https://github.com/vague2k/vague.nvim" }, -- fresh theme
	{ src = "https://github.com/stevearc/oil.nvim" },  -- file system editor - edit like a buffer
	{ src = "https://github.com/neovim/nvim-lspconfig" }, -- configs for lsps
	{ src = "https://github.com/echasnovski/mini.pick" }, -- file picker with fuzzy finding: alternative - telescope
	{ src = "https://github.com/chomosuke/typst-preview.nvim" }, -- preview for typst language
	{ src = "https://github.com/mason-org/mason.nvim" }, -- lsp manager nvim
})
-- omni complete -> look further into ctrl+x

require("mason").setup()
require("mini.pick").setup()
require("oil").setup()

vim.keymap.set('n', '<leader>f', ":Pick files<CR>")
vim.keymap.set('n', '<leader>h', ":Pick help<CR>")
vim.keymap.set('n', '<leader>e', ":Oil<CR>")
vim.lsp.enable({ "emmylua_ls", "clangd" })
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)

vim.cmd("colorscheme vague")
vim.cmd(":hi statusline guibg=NONE") --no bg for status line
