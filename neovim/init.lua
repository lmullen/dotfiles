-- Load Lazy plugin manager and install if necessary
require("lazy-manager")

-- Setup lazy.nvim
require("lazy").setup({
	{ 'projekt0n/github-nvim-theme', name = "github-theme", lazy = false },
	{ 'tpope/vim-vinegar' },
	{ 'numToStr/Comment.nvim' },
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			local configs = require("nvim-treesitter.configs")
			configs.setup({
				ensure_installed = {
					"bash",
					"c",
					"diff",
					"dockerfile",
					"fish",
					"go",
					"html",
					"javascript",
					"latex",
					"lua",
					"query",
					"r",
					"typescript",
					"vim",
					"vimdoc",
				},
				sync_install = false,
				highlight = { enable = true },
				indent = { enable = true },
			})
		end
	},

	-- automatically check for plugin updates
	checker = { enabled = true }
})

-- Display settings
vim.cmd('colorscheme github_light_default')
vim.opt.number = true
vim.opt.display:append('lastline') -- show partial last lines
vim.opt.scrolloff = 0

-- Statusline
vim.opt.laststatus = 2                -- always show a status line
vim.opt.statusline = ""
vim.opt.statusline:append("%t")       -- tail/filename
vim.opt.statusline:append("%m%r%h")   -- modified/read only/help
vim.opt.statusline:append(" [%Y]")    -- line endings/type of file
vim.opt.statusline:append("%=")       -- left/right separator
vim.opt.statusline:append("%#error#") -- display a warning if &paste is set
vim.opt.statusline:append([[%{&paste?'[paste]':''}]])
vim.opt.statusline:append("%*")
vim.opt.statusline:append("%#warningmsg#") -- display a warning if the line endings aren't unix
vim.opt.statusline:append([[%{&ff!='unix'?'['.&ff.']':''}]])
vim.opt.statusline:append("%*")
vim.opt.statusline:append("%#warningmsg#") -- display a warning if file encoding isn't utf-8
vim.opt.statusline:append([[%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.']':''}]])
vim.opt.statusline:append("%*")
vim.opt.statusline:append("C:%02c,")     -- cursor column
vim.opt.statusline:append("L:%03l/%03L") -- cursor line/total lines
vim.opt.statusline:append(" %P")         -- percent through file

-- TextMate style space chars
vim.opt.listchars = {
	tab = '▸ ',
	eol = '¬',
	trail = '·',
	nbsp = '·'
}

-- Text formatting
vim.opt.wrap = true -- soft wrap long lines
vim.opt.linebreak = true
vim.opt.textwidth = 80
vim.opt.tabstop = 2       -- a tab is two spaces
vim.opt.softtabstop = 2   -- soft tab is two spaces
vim.opt.shiftwidth = 2    -- # of spaces for autoindenting
vim.opt.expandtab = true  -- insert spaces not tabs
vim.opt.autoindent = true -- always set autoindenting on
vim.opt.copyindent = true -- copy prev indentation
vim.opt.shiftround = true -- use shiftwidth when indenting

-- Keyboard shortcuts
vim.keymap.set('n', 'j', 'gj', { noremap = true })
vim.keymap.set('n', 'k', 'gk', { noremap = true })
vim.keymap.set('n', 'E', 'ge', { noremap = true })
-- reselect visual after indent
vim.keymap.set('v', '<', '<gv', { noremap = true })
vim.keymap.set('v', '>', '>gv', { noremap = true })
-- Copying and pasting
vim.keymap.set('i', '<C-v>', '<C-r><C-o>+', { noremap = true })
vim.keymap.set('i', '<C-c>', '<CR><Esc>O', { noremap = true })
-- move between splits
-- vim.keymap.set('n', '<C-h>', '<C-w>h', { noremap = true })
-- vim.keymap.set('n', '<C-j>', '<C-w>j', { noremap = true })
-- vim.keymap.set('n', '<C-k>', '<C-w>k', { noremap = true })
-- vim.keymap.set('n', '<C-l>', '<C-w>l', { noremap = true })

-- Tab completion
vim.opt.wildmenu = true
vim.opt.wildignore:append({
	'*.Rout',
	'*.aux',
	'*.bak',
	'*.bbl',
	'*.blg',
	'*.class',
	'*.doc',
	'*.docx',
	'*.dvi',
	'*.fdb_latexmk',
	'*.fls',
	'*.gif',
	'*.idx',
	'*.ilg',
	'*.ind',
	'*.jpeg',
	'*.jpg',
	'*.lof',
	'*.md.tex',
	'*.mp3',
	'*.out',
	'*.pdf',
	'*.png',
	'*.pyc',
	'*.rtf',
	'*.svg',
	'*.swp',
	'*.synctex.gz',
	'*.toc',
	'*.zip',
	'*/.hg/*',
	'*/.svn/*',
	'*/_site-deploy/*',
	'*/_site-preview/*',
	'*/_site/*',
	'*/lib/*',
	'*/node_modules/*',
	'*/public/*',
	'*Session.vim*',
	'*~',
	'.DS_Store',
})
vim.opt.suffixes:append({ '*.log', '*.zip', '*.pdf' })

-- Auto-save when losing focus
vim.api.nvim_create_autocmd("FocusLost", {
	pattern = "*",
	callback = function() vim.cmd("silent! wa") end
})

-- Backup/swap settings
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.backupdir = vim.fn.expand('$HOME/.cache/vim/backup/')
vim.opt.directory = vim.fn.expand('$HOME/.cache/vim/swap/')
