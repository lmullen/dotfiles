 " Neovim configuration

" Plugins
" -------------------------------------------------------------------
call plug#begin('~/.local/share/nvim/plugged')
Plug 'ctrlpvim/ctrlp.vim'
Plug 'fatih/vim-go'
Plug 'icymind/NeoSolarized'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-vinegar'
call plug#end()

" General
" -------------------------------------------------------------------
filetype plugin indent on
set encoding=utf-8
set showmatch                               " matching parentheses
set smarttab
set shiftround
set mouse=a                                 " use mouse in console
set autoread
set autowrite
au FocusLost * :wa                          " save when losing focus (gVim)

" Display
" -------------------------------------------------------------------
syntax enable
set termguicolors
colorscheme NeoSolarized
set background=dark
set number
set display+=lastline                       " show partial last lines
set scrolloff=0
" Resize the splits if the vim windows is resized
autocmd VimResized * :wincmd =
set listchars=tab:▸\ ,eol:¬,trail:·,nbsp:·  " TextMate style space chars

" Status line
" -------------------------------------------------------------------
set laststatus=2                            " always show a status line
set statusline=""
set statusline+=%t                          " tail/filename
set statusline+=%m%r%h                      " modified/read only/help
set statusline+=\ [%Y]                      " line endings/type of file
set statusline+=%=                          " left/right separator
"display a warning if &paste is set
set statusline+=%#error#
set statusline+=%{&paste?'[paste]':''}
set statusline+=%*
" display a warning if the line endings aren't unix
set statusline+=%#warningmsg#
set statusline+=%{&ff!='unix'?'['.&ff.']':''}
set statusline+=%*
" display a warning if file encoding isnt utf-8
set statusline+=%#warningmsg#
set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.']':''}
set statusline+=%*
" progress through file
set statusline+=C:%02c,                       " cursor column
set statusline+=L:%03l/%03L                   " cursor line/total lines
set statusline+=\ %P                        " percent through file

" Functions 
" -------------------------------------------------------------------
source $HOME/.config/nvim/functions.vim

" Search 
" -------------------------------------------------------------------
set incsearch
set ignorecase
set smartcase

" Keyboard shortcuts
" -------------------------------------------------------------------
nmap E ge
" reselect visual after indent
vnoremap < <gv
vnoremap > >gv
" move between splits
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap j gj
nnoremap k gk
" Copying and pasting
imap <C-v> <C-r><C-o>+
imap <C-c> <CR><Esc>O

" Tab completion
" -------------------------------------------------------------------
if has('wildmenu')
  set wildmenu
  set wildignore+=*.aux,*.bak,*.bbl,*.blg,*.class,*.doc,*.docx,*.dvi,*.fdb_latexmk,*.fls,*.idx,*.ilg,*.ind,*.out,*.png,*.pyc,*.Rout,*.rtf,*.swp,*.synctex.gz,*.toc,*/.hg/*,*/.svn/*,*.mp3,*/_site/*,*/_site-preview/*,*/_site-deploy/*,*~,.DS_Store,*/public/*,*Session.vim*,*.jpeg,*.jpg,*.gif,*.svg,*.lof,*.zip,*.pdf,*.md.tex,*/node_modules/*,*/lib/*,*legal-codes-split/*
  set suffixes+=*.log,*.zip,*.pdf
endif

" Spell check 
" -------------------------------------------------------------------
set spelllang=en_us                         " US English
set spell                                   " spell check on
set spellsuggest=10                         " only suggest a few words

" Text formatting 
" -------------------------------------------------------------------
set wrap                                    " soft wrap long lines
set linebreak
set textwidth=80
set tabstop=2                               " a tab is two spaces
set softtabstop=2                           " soft tab is two spaces
set shiftwidth=2                            " # of spaces for autoindenting
set expandtab                               " insert spaces not tabs
set autoindent                              " always set autoindenting on
set copyindent                              " copy prev indentation
set shiftround                              " use shiftwidth when indenting
" Use Q to format paragraph
vnoremap Q gq
nnoremap Q gwap
set formatoptions=tqcwn                     " see :help fo-table

" Vimrc
" -------------------------------------------------------------------
command! -nargs=0 Evimrc e $MYVIMRC
command! -nargs=0 Svimrc source $MYVIMRC
command! -nargs=0 Efunctions e $HOME/.vim/functions.vim
set nobackup                                  " backups and swaps
set noswapfile
set backupdir=$HOME/.cache/vim/backup/
set directory=$HOME/.cache/vim/swap/

" Pandoc 
" -------------------------------------------------------------------
au BufNewFile,BufFilePRe,BufRead *.markdown,*.md,*.mkd,*.pd,*.pdc,*.pdk,*.pandoc,*.text,*.txt,*.Rmd   set filetype=markdown.pandoc
" Find the space before Pandoc footnotes
nnoremap <leader><space> /\v^$\n[\^1\]:<CR>:let @/ = ""<CR>
" Convert pandoc buffer to HTML and copy to system clipboard
autocmd FileType markdown nnoremap <buffer> <C-S-x> :write \| let @+ = system("pandoc -t html " . shellescape(expand("%:p")))<CR>
autocmd FileType markdown nnoremap ~ K
autocmd FileType markdown nnoremap K ~
let g:pandoc#syntax#conceal#use = 0

" CSVs
" -------------------------------------------------------------------
au BufNewFile,BufRead *.csv set filetype=CSV
autocmd FileType CSV set nowrap textwidth=0 wrapmargin=0

" Formating file
" -------------------------------------------------------------------
" Run equalprg on the entire file
nnoremap <silent> <leader>= mpgg=G`p

" Commentary.vim 
" -------------------------------------------------------------------
autocmd FileType apache set commentstring=#\ %s   "comments for Apache
autocmd FileType make set commentstring=#\ %s   "comments for Makefile
autocmd FileType r set commentstring=#\ %s        "comments for R
autocmd FileType pandoc set commentstring=<!--\ %s\ -->   "comments for pandoc
nmap <C-c> gcc
vmap <C-c> gcc

" Ctrl-P 
" -------------------------------------------------------------------
let g:ctrlp_open_new_file = 'r'             " open new files in same window
nnoremap <C-B> :CtrlPBuffer<CR>
let g:ctrlp_use_caching = 0
let g:ctrlp_clear_cache_on_exit = 1         
let g:ctrlp_cache_dir = $HOME.'/.cache/ctrlp'
let g:ctrlp_dotfiles = 0                    " ignore dotfiles and dotdirs
let g:ctrlp_custom_ignore = { 'dir': '\.git$\|\_site$' }

