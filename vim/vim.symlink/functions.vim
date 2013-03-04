" convert smart typographical symbols to Markdown standards
nnoremap _md :silent! call CleanMarkdown()<CR>
function! CleanMarkdown()
  :%s/—/---/ge 
  :%s/–/--/ge
  :%s/…/.../ge
  :%s/\’/'/ge
  :%s/\“/"/ge
  :%s/\‘/'/ge
  :%s/\”/"/ge
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
nnoremap _wc :call CommitToWiki()<CR>
function! CommitToWiki()
  :lcd ~/acad/research/wikidata
  :!git --git-dir=/Users/lmullen/acad/research/wikidata/.git --no-pager add *.page && git --git-dir=/Users/lmullen/acad/research/wikidata/.git commit -a -m "Automatic commit from Vim" 
endfunction

" Make the BibTeX bibliography
nnoremap _bib :call MakeBib()<CR>
function! MakeBib()
  :!cd ~/bib && make
endfunction
