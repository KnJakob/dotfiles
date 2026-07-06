local vim = vim

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
vim.keymap.set('n', '<leader>Q', ':quitall<CR>')
vim.keymap.set('n', '<leader>b', ':bw!')
vim.keymap.set({ 'n', 'x', 'v' }, '<leader>sh', ':split ')
vim.keymap.set({ 'n', 'x', 'v' }, '<leader>sv', ':vsplit ')
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end)
vim.keymap.set("n", "<leader>r", function()
	vim.diagnostic.show()
end)

vim.keymap.set({ 'n', 'v', 'x' }, '<leader>y', '"+y')
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>p', '"+p')

-- Terminal in nvim ?!?!
vim.api.nvim_create_autocmd("TermOpen", {
	group = vim.api.nvim_create_augroup("custom-term-open", { clear = true }),
	callback = function()
		vim.opt.number = false
		vim.opt.relativenumber = false
	end,
})
vim.keymap.set('t', '<C-w>e', "<C-\\><C-n>", { silent = true })
vim.keymap.set({ 'n', 't' }, "<leader>tt", ":Floaterminal<CR>")

local job_id = 0
vim.keymap.set("n", "<leader>to", function() --small terminal
	vim.cmd.vnew()
	vim.cmd.term()
	vim.cmd.wincmd("J")
	vim.api.nvim_win_set_height(0, 5)

	job_id = vim.bo.channel
end)

local current_command = ""
-- repeat command in small terminal
vim.keymap.set("n", "<space>tr", function()
	if current_command == "" then
		current_command = vim.fn.input("Command: ")
	end

	vim.fn.chansend(job_id, { current_command .. "\r\n" })
end)
-- set command in small terminal
vim.keymap.set("n", "<space>te", function()
	current_command = vim.fn.input("Command: ")

	vim.fn.chansend(job_id, { current_command .. "\r\n" })
end)

vim.pack.add({
	{ src = "https://github.com/vague2k/vague.nvim" },         -- fresh theme
	{ src = "https://github.com/rebelot/kanagawa.nvim" },      -- another theme
	{ src = "https://github.com/loctvl842/monokai-pro.nvim" }, -- another theme
	{ src = "https://github.com/stevearc/oil.nvim" },          -- file system editor - edit like a buffer
	{ src = "https://github.com/neovim/nvim-lspconfig" },      -- configs for lsps
	{ src = "https://github.com/echasnovski/mini.pick" },      -- file picker with fuzzy finding: alternative - telescope
	{ src = "https://github.com/chomosuke/typst-preview.nvim" }, -- preview for typst language
	{ src = "https://github.com/mason-org/mason.nvim" },       -- lsp manager nvim
	{ src = "https://github.com/hrsh7th/nvim-cmp" },           -- completions ui to interact with lsps
	{ src = "https://github.com/hrsh7th/cmp-nvim-lsp" },       -- connects cmp with nvim-lsp manager
	{ src = "https://github.com/L3MON4D3/LuaSnip" },           -- shows code snippets
	{ src = "https://github.com/nvim-telescope/telescope.nvim" }, --
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/github/copilot.vim.git" },
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

-- show selected lines/characters in the statusline while in visual mode
function _G.char_and_line_count()
	local mode = vim.fn.mode()
	if mode:find("[vV\22]") then
		local ln_beg = vim.fn.line("v")
		local ln_end = vim.fn.line(".")
		local lines = math.abs(ln_end - ln_beg) + 1
		local chars = vim.fn.wordcount().visual_chars or 0

		return chars .. " Chars / " .. lines .. " Lines"
	end

	return ""
end

-- require("hover").setup()
require("mason").setup()
vim.api.nvim_create_user_command("LspInstallAll", function()
	vim.cmd(
		"MasonInstall lua-language-server clangd ty typescript-language-server dockerfile-language-server yaml-language-server bash-language-server")
end, { desc = "Install configured LSP servers with Mason" })

require("mini.pick").setup()
require("oil").setup()
require("nvim-treesitter").setup {                                    -- Directory to install parsers and queries to (prepended to `runtimepath` to have priority)
	install_dir = vim.fn.stdpath('data') .. '/site',
	ensure_installed = { "lua", "vim", "vimdoc", "javascript", "html" }, -- Example parsers
	sync_install = false,
	highlight = { enable = true },
	indent = { enable = true },
}
vim.api.nvim_create_autocmd('FileType', {
	pattern = { 'python' },
	callback = function() vim.treesitter.start() end,
})

-- vim.keymap.set('n', 'gr', vim.lsp.buf.references)
local builtin = require("telescope.builtin")

vim.keymap.set('n', '<leader>ff', function()
	builtin.find_files({
		-- show hidden files, but exclude git related
		find_command = { 'rg', '--files', '--hidden', '--glob', '!**/.git/*' },
	})
end, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep)
vim.keymap.set("n", "<leader>fb", builtin.buffers)
vim.keymap.set("n", "<leader>fh", builtin.help_tags)
vim.keymap.set("n", "gr", builtin.lsp_references)
vim.keymap.set("n", "gd", builtin.lsp_definitions)
vim.keymap.set("n", "gs", builtin.git_status)
vim.keymap.set("n", "gcm", builtin.git_commits) -- show all commits
vim.keymap.set("n", "gcb", builtin.git_bcommits) -- show commits for this buffer
vim.keymap.set("n", "gb", builtin.git_branches)

-- open fuzzy finder when opened without a file
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if #vim.api.nvim_list_uis() > 0 and vim.fn.argc() == 0 and vim.api.nvim_buf_get_name(0) == "" and vim.bo.buftype == "" then
			vim.schedule(function()
				builtin.find_files({
					find_command = { 'rg', '--files', '--hidden', '--glob', '!**/.git/*' },
				})
			end)
		end
	end,
})

-- lsp commands
-- vim.keymap.set('n', '<leader>f', ":Pick files<CR>")
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
	}),
	sources = {
		{ name = "nvim_lsp" },
	},
})

vim.diagnostic.config({
	underline = true,
	signs = true,
	virtual_text = { prefix = "●" },
	virtual_lines = false,
	update_in_insert = true,
	severity_sort = true,
})

vim.lsp.config("ty", {
	cmd = { "ty", "server" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
	capabilities = capabilities,
})

vim.lsp.config("dockerls", {
	cmd = { "docker-langserver", "--stdio" },
	filetypes = { "dockerfile" },
	root_markers = { "Dockerfile", ".git" },
	capabilities = capabilities,
})

vim.lsp.config("ts_ls", {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_markers = { "package.json", "tsconfig.json", "jsconfig.json" },
})

vim.lsp.config("yamlls", {
	cmd = { "yaml-language-server", "--stdio" },
	filetypes = { "yaml" },
	root_markers = { ".git", "package.json" },
	settings = {
		yaml = {
			validate = true,
			schemaValidation = true,
		},
	},
})
vim.lsp.config("bashls", {
	cmd = { "bash-language-server", "--stdio" },
	filetypes = { "sh", "bash", "zsh" },
	root_markers = { ".git", "package.json" },
})

vim.lsp.enable({ "lua_ls", "clangd", "ty", "dockerls", "ts_ls", "bashls", "yamlls", "tinymist" })
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)

vim.cmd("colorscheme vague")
-- vim.cmd("colorscheme kanagawa-dragon") -- also wave and lotus
vim.cmd("colorscheme monokai-pro-octagon") -- ristretto, spectrum, classic
-- statusline: filename on the left, visual selection count centered, position right
vim.o.statusline = " %f %m%r %=%{v:lua.char_and_line_count()}%= %l:%c  %P "
vim.cmd(":hi statusline guibg=NONE") --no bg for status line
