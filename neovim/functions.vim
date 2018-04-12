" convert smart typographical symbols to Markdown standards
nnoremap _md :silent! call CleanMarkdown()<CR>
function! CleanMarkdown()
  :%s/—/---/ge 
  :%s/–/--/ge
  :%s/…/.../ge
  :%s/’/'/ge
  :%s/“/"/ge
  :%s/‘/'/ge
  :%s/”/"/ge
  :%s///ge
  :%s/``/"/ge
  :%s/''/"/ge
  " The space replaced below is a non-breaking space commonly used before the 
  " colon in a title in library catalogs. It breaks pdfLaTeX.
  :%s/ :/:/ge
endfunction

" put an en dash between number ranges
nnoremap _en :call EnDashRange()<CR>
function! EnDashRange()
  :%s/\v(\d)-(\d)/\1--\2/ge
endfunction

command! -nargs=0 BG call ToggleBackground()
function! ToggleBackground()
  if &background == "dark"
    set background=light
  else
    set background=dark
  endif
endfunction

command! -nargs=0 DeleteEveryBuffer call DeleteEveryBuffer()
function! DeleteEveryBuffer()
  :1,10000bd
endfunction

command! -nargs=0 DeleteCurrentBuffer call DeleteCurrentBuffer()
function! DeleteCurrentBuffer()
  :bp|bd #
endfunction

" Open the current file in the browser with the file system
command! -nargs=0 OpenInChromeWithFileSystem call OpenInChromeWithFileSystem()
function! OpenInChromeWithFileSystem()
  silent !google-chrome "%:p"
endfunction
"
" Open the current note file in the browser with localhost
command! -nargs=0 OpenInChromeWithLocalhost call OpenInChromeWithLocalhost()
function! OpenInChromeWithLocalhost()
  silent !google-chrome "http://localhost:4000/%"
endfunction

" Navigate to a Pandoc footnote 
command! -nargs=* Fn call GoToFootnote(<f-args>)
function! GoToFootnote(footnote, ...)
  let definition = ''
  if a:0 > 0
    let definition = a:1
  endif
  call search('\[\^' . a:footnote . '\]' . definition)
endfunction

command! -nargs=0 AbbreviateMonths call AbbreviateMonths()
function! AbbreviateMonths()
  :%s/January/Jan./g
  :%s/February/Feb./g
  :%s/March/Mar./g
  :%s/April/Apr./g
  " :%s/May/May/g
  " :%s/June/June/g
  " :%s/July/July/g
  :%s/August/Aug./g
  :%s/September/Sept./g
  :%s/October/Oct./g
  :%s/November/Nov./g
  :%s/December/Dec./g
endfunction

" For `test.md`, open the file `test.md.pdf` in the operating system
command! -nargs=0 PDF call PDF()
function! PDF()
  :silent exec "!open ".expand("%:p").".pdf"
endfunction

