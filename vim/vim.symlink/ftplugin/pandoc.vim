" Correct text width
setlocal textwidth=72

" filter text through pandoc to clean markdown, using reference links and atx headers
setlocal equalprg=pandoc\ -t\ markdown\ --reference-links\ --atx-headers\ --standalone

" add all tags in the style {word} in current document to quickfix list
nnoremap <leader>{ :vimgrep /{\w\+}/ %<CR>:copen<CR>
