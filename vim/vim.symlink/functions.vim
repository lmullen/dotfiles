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
  :%s/``/"/ge
  :%s/''/"/ge
endfunction

" put an en dash between number ranges
nnoremap _en :call EnDashRange()<CR>
function! EnDashRange()
  :%s/\v(\d)-(\d)/\1--\2/ge
endfunction

function! CleanJSRFootnotes()
  :%s/\v\^\[\[(\d+)\]\]\(\#ftnt\d+\)\^/[^\1]/ge
  :%s/\v\[\[(\d+)\]\]\(\#ftnt_ref\d+\)/[^\1]: /ge
endfunction

nnoremap _jsr :call CleanJSR()<CR>
function! CleanJSR()
  " replace non-breaking spaces with regular spaces
  :%s/ / /ge
  :%s/^\s\+//e
  " remove problems with * , in footnotes
  :%s/\V* ,/*,/ge
  " remove problems with *( in footnotes and titles
  :%s/\V*(/* (/ge
  call CleanJSRFootnotes()
  call CleanMarkdown()
  call EnDashRange()
endfunction

function! CleanT2()
  :%s/\v\’/'/ge
  :%s/\v\“/``/ge
  :%s/\v\‘/`/ge
  :%s/\v\”/''/ge
  :%s/\v```/``\\,`/ge
  :%s/\v'''/'\\,''/ge
  :%s/\v(\d)-(\d)/\1--\2/ge
  :%s/\v\—/---/ge
  :%s/\v\–/--/ge
  :%s/\v\•/\\item/ge
  :%s/\v\…/\\dots/ge
endfunction

function! Patristics()
  :%s/\vDecember/Dec./ge
  :%s/\vJanuary/Jan./ge
  :%s/\vFebruary/Feb./ge
  :%s/\vMarch/Mar./ge
  :%s/\vApril/Apr./ge
  :%s/\vAugust/Aug./ge
  :%s/\vSeptember/Sept./ge
  :%s/\vOctober/Oct./ge
  :%s/\vNovember/Nov./ge
  " :%s/\V<td class="hd">\n<p style='height:16px;'>.<\/p>\n<\/td>\n// 
  " :%s/\V dir='ltr' class='s\d'//
  " :%s/\V<td><\/td>\n//
  " :%s/\V class='s2'//
  " :%s/\v\&lt\;/</ge
  " :%s/\v\&gt\;/>/ge
endfunction

" Commit all changes in research wiki
command! -nargs=0 Wiki call CommitToWiki()
nnoremap _wc :call CommitToWiki()<CR>
function! CommitToWiki()
  :silent !cd ~/acad/research && rake wiki
  :redraw!
endfunction

" Make the BibTeX bibliography
command! -nargs=0 Bib call MakeBib()
nnoremap _bib :call MakeBib()<CR>
function! MakeBib()
  :silent !cd ~/acad/research && rake bib
  :redraw!
endfunction

" Find related Pandoc footnote numbers
" -------------------------------------------------------------------
" Vim's * key searches for the next instance of the word under the 
" cursor; Vim decides what counts as the boundary of a word with the 
" iskeyword option. This function toggles the special characters of a 
" Pandoc footnote in the form [^1] to allow you to jump between 
" footnotes with the * key.
nnoremap _fn :call ToggleFootnoteJumping()<CR>
function! ToggleFootnoteJumping()
  if exists("g:FootnoteJumping") 
    if g:FootnoteJumping == 1
      set iskeyword-=[
      set iskeyword-=]
      set iskeyword-=^
      let g:FootnoteJumping = 0
    else
      set iskeyword+=[
      set iskeyword+=]
      set iskeyword+=^
      let g:FootnoteJumping = 1
    endif
  else 
    set iskeyword+=[
    set iskeyword+=]
    set iskeyword+=^
    let g:FootnoteJumping = 1
  endif
endfunction

command! -nargs=0 BG call ToggleBackground()
nnoremap <leader>bg :call ToggleBackground()<cr>
function! ToggleBackground()
  if &background == "dark"
    set background=light
    :AirlineTheme tomorrow
  else
    set background=dark
    :AirlineTheme solarized
  endif
endfunction

" Add Omeka's tags
command! -nargs=0 Omeka call OmekaSetup()
function! OmekaSetup()
  set tags+=~/dev/Omeka/.git/tags
endfunction

" Open the current note file in the browser
command! -nargs=0 Wo call OpenCurrentNoteInWiki()
function! OpenCurrentNoteInWiki()
 silent !open "http://mullen-mac.local:5001/%:r"
endfunction


" Copy the current filename without extension
command! -nargs=0 FN call CopyFilename()
function! CopyFilename()
 let @* = expand("%:r") 
endfunction

command! -nargs=0 Aeql call AlignOnEqualSign()
function! AlignOnEqualSign()
  :Tabularize /=
endfunction

command! -nargs=0 Ahash call AlignOnHash()
function! AlignOnHash()
  :Tabularize /#
endfunction

command! -nargs=0 Ar call AlignOnRAssign()
function! AlignOnRAssign()
  :Tabularize /<-
endfunction

command! -nargs=0 ToggleHJKL call ToggleHJKL() 
function! ToggleHJKL()
  if exists("g:ToggleHJKL") 
    if g:ToggleHJKL == 1
      map h h
      map j j
      map k k
      map l l
    else
      map h <nop>
      map j <nop>
      map k <nop>
      map l <nop>
      let g:ToggleHJKL = 1
    endif
  else 
    map h <nop>
    map j <nop>
    map k <nop>
    map l <nop>
    let g:ToggleHJKL = 1
  endif
endfunction

command! -nargs=0 Todo call Todo()
function! Todo()
  :cd ~/todo/
  :source Session.vim
endfunction
