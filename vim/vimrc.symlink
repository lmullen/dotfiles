" Vim configuration for
" Lincoln Mullen | lincoln@lincolnmullen.com | http://lincolnmullen.com

" Pathogen
" -------------------------------------------------------------------
runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()

" General 
" -------------------------------------------------------------------
set nocompatible
set encoding=utf-8
set showmode
set showcmd
set hidden
set ruler
set backspace=indent,eol,start              " allow backspacing in insert mode
set showmatch                               " matching parentheses
set smarttab
set history=1000                            " remember commands and searches
set undolevels=100                          " use many levels of undo
set noerrorbells                            " don't beep
set mouse=a                                 " use mouse in console
" set clipboard=unnamedplus                   " use system clipboard
filetype plugin indent on                   " detect filetypes
set nrformats-=octal
set shiftround
set ttimeout
set ttimeoutlen=50
set autoread
set fileformats+=mac
set tabpagemax=50

" Display
" -------------------------------------------------------------------
set t_Co=16                                 " color terminal
syntax enable                               " syntax highlighting
set background=dark
colorscheme solarized
set display+=lastline                       " show partial last lines
set nolist                                  " don't display space chars
set listchars=tab:▸\ ,eol:¬,trail:·,nbsp:·  " TextMate style space chars
set scrolloff=5                             " cursor 5 lines from top or bottom
" set cursorline                              " highlight current line
set number

" Status line
" -------------------------------------------------------------------
set laststatus=2                            " always show a status line
set statusline=""
set statusline+=%t                          " tail/filename
set statusline+=%m%r%h                      " modified/read only/help
set statusline+=\ [%{&ff}/%Y]               " line endings/type of file
set statusline+=\ %{fugitive#statusline()}  " Git status
set statusline+=\ [L\:%l\/%L,\%p%%\ C\:%c]  " line/total lines percentage/column

" Viminfo 
" -------------------------------------------------------------------
set viminfo='300,f1,<300,:500,/500,n~/.viminfo

" Functions 
" -------------------------------------------------------------------
source $HOME/.vim/functions.vim

" Search 
" -------------------------------------------------------------------
set incsearch                               " show search matches as you type
set ignorecase
set smartcase                               " smart about case sensitivity
" set hlsearch                                " highlight search terms
" clear search highlighting
nmap <silent> <leader>/ :nohlsearch<CR>
" use very magic mode explicitly
cnoremap s/ s/\v
cnoremap %s/ %s/\v
nnoremap / /\v
vnoremap / /\v

" Folding
" -------------------------------------------------------------------
set foldenable
set foldcolumn=1                            " show where the folds are
nnoremap <space> za

" Keyboard shortcuts
" -------------------------------------------------------------------
nnoremap ~ K
nnoremap K ~
nmap E ge
nnoremap <leader>cd :cd %:p:h<CR>:pwd<CR>
nnoremap <leader>lcd :lcd %:p:h<CR>:pwd<CR>
" reselect visual after indent
vnoremap < <gv
vnoremap > >gv
" move between splits
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
" disable arrow keys
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
" move by display not logical lines
nnoremap j gj
nnoremap k gk
" paired keymappings
" nnoremap [q :cprev<CR>
" nnoremap ]q :cnext<CR>
" nnoremap [Q :cfirst<CR>
" nnoremap ]Q :clast<CR>
" nnoremap [l :lprev<CR>
" nnoremap ]l :lnext<CR>
" nnoremap [L :lfirst<CR>
" nnoremap ]L :llast<CR>
" nnoremap [b :bprev<CR>
" nnoremap ]b :bnext<CR>
" nnoremap ]t :tnext<CR>
" nnoremap [t <C-T>
" nnoremap [a :prev<CR>
" nnoremap ]a :next<CR>
" nnoremap [A :first<CR>
" nnoremap ]A :last<CR>
nnoremap [<space> O<ESC>j
nnoremap ]<space> o<ESC>k
nnoremap ]n /\V[^\d\+]<CR>
nnoremap [n ?\V[^\d\+]<CR>

" Tab completion
" -------------------------------------------------------------------
if has('wildmenu')
  set wildmenu
  set wildignore+=*.aux,*.bak,*.bbl,*.blg,*.class,*.doc,*.docx,*.dvi,*.fdb_latexmk,*.fls,*.idx,*.ilg,*.ind,*.log,*.out,*.pdf,*.png,*.pyc,*.Rout,*.rtf,*.swp,*.synctex.gz,*.toc,*.zip,*/.hg/*,*/.svn/*,*.mp3,*/_site/*,*~,.DS_Store,*/public/*,*Session.vim*
endif

" Word count
" -------------------------------------------------------------------
nmap <silent> <leader>wc g<C-G>
nmap <silent> <leader>lwc :w<CR> :!detex % \| wc -w<CR>

" Spell check 
" -------------------------------------------------------------------
set spelllang=en_us                         " US English
set spell                                   " spell check on
set spellsuggest=10                         " only suggest 10 words

" Abbreviations 
" -------------------------------------------------------------------
source $HOME/.vim/abbreviations.vim         " load abbreviations list
command! -nargs=0 Abbr sp $HOME/.vim/abbreviations.vim

" Text formatting 
" -------------------------------------------------------------------
set wrap                                    " soft wrap long lines
set textwidth=78
set tabstop=2                               " a tab is four spaces
set softtabstop=2                           " soft tab is four spaces
set shiftwidth=2                            " # of spaces for autoindenting
set expandtab                               " insert spaces not tabs
set autoindent                              " always set autoindenting on
set copyindent                              " copy prev indentation
set shiftround                              " use shiftwidth when indenting
" Use Q to format paragraph
vmap Q gq
nmap Q gwap
set formatoptions=tqcwn                     " see :help fo-table

" Vimrc
" -------------------------------------------------------------------
command! -nargs=0 Evimrc e $MYVIMRC
command! -nargs=0 Svimrc source $MYVIMRC
command! -nargs=0 Efunctions e $HOME/.vim/functions.vim
set backup                                  " backups and swaps
set backupdir=$HOME/.cache/vim/backup/
set directory=$HOME/.cache/vim/swap/
autocmd FileType vim setlocal nowrap

" Pandoc 
" -------------------------------------------------------------------
au BufNewFile,BufRead *.markdown,*.md,*.mkd,*.pd,*.pdc,*.pdk,*.pandoc,*.text,*.txt,*.page   set filetype=pandoc
" Find the space before Pandoc footnotes
nnoremap <leader><space> /\v^$\n[\^1\]:<CR>:let @/ = ""<CR>

" BibTeX key completion 
" -------------------------------------------------------------------
" set dictionary+=$HOME/acad/research/bib/citekeys.txt
" set complete+=k

" Formating file
" -------------------------------------------------------------------
" Run equalprg on the entire file
nnoremap <silent> <leader>= mpgg=G`p
" Run equalprg from the part of the file marked P to the end
" map <leader>p mc'p=G'c

" Ctrl-P 
" -------------------------------------------------------------------
let g:ctrlp_open_new_file = 'r'             " open new files in same window
nmap <C-B> :CtrlPBuffer<CR>
let g:ctrlp_use_caching = 0
let g:ctrlp_clear_cache_on_exit = 1         
let g:ctrlp_cache_dir = $HOME.'/.cache/ctrlp'
let g:ctrlp_dotfiles = 0                    " ignore dotfiles and dotdirs
let g:ctrlp_custom_ignore = {
  \ 'dir': '\.git$\|\_site$'
  \ }

" Commentary.vim 
" -------------------------------------------------------------------
autocmd FileType apache set commentstring=#\ %s   "comments for Apache
autocmd FileType r set commentstring=#\ %s        "comments for R
autocmd FileType pandoc set commentstring=<!--\ %s\ -->   "comments for pandoc
map <C-c> gcc
map <C-\> gcc

" Airline 
" -------------------------------------------------------------------
let g:airline_theme='solarized'
let g:airline_enable_syntastic=1
let g:airline_detect_modified=1
let g:airline_enable_tagbar=1

" UltiSnips
" -------------------------------------------------------------------
let g:UltiSnipsEditSplit = 'horizontal'
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
let g:UltiSnipsSnippetDirectories=["UltiSnips", "snippets"]

" Tagbar 
" -------------------------------------------------------------------
nnoremap <F8> :TagbarToggle<CR>

" Gundo
" -------------------------------------------------------------------
nnoremap <F7> :GundoToggle<CR>

" Syntastic 
" -------------------------------------------------------------------
let g:syntastic_always_populate_loc_list=1
let g:syntastic_javascript_checkers=['jshint']

" Vim-R 
" -------------------------------------------------------------------
let vimrplugin_screenplugin = 0
let maplocalleader = "\\"
let vimrplugin_assign = 0
let vimrplugin_rnowebchurch = 0
let vimrplugin_r_args = "--no-restore-data --no-save --quiet"
let g:vimrplugin_insert_mode_cmds = 0

" Temporary
" -------------------------------------------------------------------
au FocusLost * :wa                          " save when losing focus (gVim)
set autoread

" " Bubble single lines
" nmap <C-Up> ddkP
" nmap <C-Down> ddp
" " Bubble multiple lines
" vmap <C-Up> xkP`[V`]
" vmap <C-Down> xp`[V`]

" Ctrl-v for pasting
"
imap <C-v> <C-r><C-o>+
imap <C-c> <CR><Esc>O

let g:syntastic_error_symbol='✗'
let g:syntastic_warning_symbol='⚠'
