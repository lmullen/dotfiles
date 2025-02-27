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
    colorscheme github_light_default
  else
    set background=dark
    colorscheme github_dark_default
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

