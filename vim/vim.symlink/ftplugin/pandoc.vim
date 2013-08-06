" Correct text width
setlocal textwidth=72

" filter text through pandoc to clean markdown, using reference links and atx headers
setlocal equalprg=pandoc\ -t\ markdown\ --reference-links\ --atx-headers\ --standalone

" drop a mark p, go to the beginning of the document, find the first 
" line that begins with a word or a header (to avoid Pandoc title block, 
" filter the text through Pandoc to the end of the document, return the 
" cursor to the mark, and clear the search highlighting
" nnoremap <silent> <leader>= mpgg/\v^(\w\|\#)<CR>=G`p :let @/ = ""<CR>
"
" same thing as above, except filter the entire buffer, don't clear 
" search
nnoremap <silent> <leader>= mpgg=G`p

" add all tags in the style {word} in current document to quickfix list
nnoremap <leader>{ :vimgrep /{\w\+}/ %<CR>:copen<CR>
