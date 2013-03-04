" Vim filetype detection file
" Language: Pandoc Markdown
" Maintainer: Ethan Schoonover <es@ethanschoonover.com>
" URL: http://ethanschoonover.com/vim-syntax-pandoc
" Last Change: March 1, 2010
"
" Files in the ~/.vim/ftdetect directory are used after all default filetype 
" checks are complete, so we can override standard filetype associations here.
"
" If you are using the Pathogen vim plugin you can also keep this in the 
" ~/.vim/bundle/vim-syntax-pandoc/ftdetect directory.
"
" see help about "ftdetect" for more information:
"
" :help ftdetect

if !exists("after_autocmds_pandoc_loaded")
    let after_autocmds_pandoc_loaded = 1
    au! BufNewFile,BufRead *.{lhs,markdown,mdown,mkd,mkdn,md,pandoc,pdc} set filetype=pandoc
endif
