" Vim syntax file
" Language:     Pandoc Markdown
" Maintainer:   Ethan Schoonover <es@ethanschoonover.com>
" URL:          http://ethanschoonover.com/vim-syntax-pandoc
" Filenames:    *.markdown,*.mdown,*.mkd,*.mkdn,*.md,*.pandoc
" Last Change:  March 1, 2010

"----------------------------------------------------------------------
" Front matter                                                          {{{
"----------------------------------------------------------------------

if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

syntax spell toplevel
syn case ignore
scriptencoding utf-8

"---------------------------------------------------------------------- }}}
" Folding                                                               {{{
"----------------------------------------------------------------------
" set this option string in .vimrc to determine which items are folded
"
"   h headers
"   l lists
"   d definitions
"
"   default is "h"
"

if !exists("g:pandoc_folding")
    let b:pandoc_folding = 1
elseif g:pandoc_folding && !has("folding")
    let b:pandoc_folding = 0
    echomsg "Ignoring g:pandoc_folding=".g:pandoc_folding.
            \"; need to re-compile vim for +fold support"
else
    let b:pandoc_folding = g:pandoc_folding
endif


" found the basis for this on the vim mailing list
" http://vim.1045645.n5.nabble.com/markdown-folds-td3331979.html
" still slows things down but not as bad as my syntax method and we can now 
" turn folding to manual and back again with no significant performance hit.
if b:pandoc_folding
setl foldmethod=expr
"setl foldcolumn=6
autocmd InsertEnter * if !exists('w:last_fdm') | let w:last_fdm=&foldmethod | setlocal foldmethod=manual | endif
autocmd InsertLeave * if exists('w:last_fdm') | let &l:foldmethod=w:last_fdm | unlet w:last_fdm | endif
else
setl foldmethod=manual
endif
setl foldexpr=Foldexpr_pandoc(v:lnum) 
func! Foldexpr_pandoc(lnum) 
    let     l1 =    getline(a:lnum) 
    if      l1 =~   '^\s*$'         | return '='  | endif                       " skip empty lines
    let     l0 =    getline(a:lnum-1)                                           " non-empty line, check next line
    if      l0 !~   '^\s*$'         | return '='  | endif                       " make sure we have a blank line preceding
    let     l2 =    getline(a:lnum+1)                                           " non-empty line, blank above, check next line
    if      l2 =~   '^=\+\s*$'      | return '>1'                               " heading one, setext style, skip table end rows
    elseif  l2 =~   '^----\+\s*$'   | return '>2'                               " heading two, setext style, skip table end rows
    elseif  l1 =~   '^#[^.]'        | return '>'.matchend(l1, '^#\+')           " heading, atx style, but not a list item
    else                            | return  '='                               " don't change current fold level
    endif 
endfunc 
" folding can slow down speed of insert mode, so turn off fold changes while 
" inserting text


"---------------------------------------------------------------------- }}}
" Conceal                                                               {{{
"----------------------------------------------------------------------
" set this option string in .vimrc to determine which items to conceal
"
"   c citations
"   d definitions
"   e escaped characters
"   f footnotes
"   h headers (setext underscore style only)
"   H headers (atx hash & setext underscore style)
"   l links
"   q smart quotes & typography
"   r rules
"   s styles
"   t tables
"   u sUb/sUperscript

if !exists("g:pandoc_conceal")
    let s:pandoc_conceal= "dehlqrst"
else
    let s:pandoc_conceal= g:pandoc_conceal
endif



"---------------------------------------------------------------------- }}}
" Style Options                                                         {{{
"----------------------------------------------------------------------
" set this option string in .vimrc to change the default styling
"
"   z zebra striping in tables (skips blanks lines, so fill them in!)

if !exists("g:pandoc_styles")
    let s:pandoc_styles = ""
else
    let s:pandoc_styles = g:pandoc_styles
endif


"---------------------------------------------------------------------- }}}
" Syntax Imports & LHS                                                  {{{
"----------------------------------------------------------------------

let s:pandoc_embed = ["html","haskell","tex"]

if exists("g:pandoc_embed")
    let s:pandoc_embed += g:pandoc_embed
endif
for embed_item in s:pandoc_embed
    let embed_item = tolower(embed_item)
    exe "syn include @pandocEmbedded".embed_item." syntax/".embed_item.".vim"
    unlet b:current_syntax
endfor

" setting g:pandoc_lhs to 1 in vimrc or using a format line such as:
" format: markdown+lhs
" within the first 10 lines of the file will set lhs mode

if !exists("b:pandoc_lhs") && exists("g:pandoc_lhs")
    let b:pandoc_lhs = g:pandoc_lhs
else
    let s:currentline=line(".")
    let s:currentcolumn=col(".")
    call cursor(1,1)
    if search('^\%(%%\)\=.*format.*+lhs','W',10) != 0
        let b:pandoc_lhs = 1
    else
        let b:pandoc_lhs = 0
    endif
    call cursor (s:currentline, s:currentcolumn)
endif



" dynamic embed
" exe 'syn region  pandocCodeBlock_'.embed_item.' matchgroup=pandocCodeBlockDelim start=/\%(^\_s\+\_^\|\%^\)\@<=\%(\z(\s*\~\{3,}\)\s*{\s*.'.embed_item.'.*\_$\)/ end=/^\z1\%(.*\)$/ keepend containedin=@pandocBlockElements contains=@pandocEmbedded'.embed_item

"---------------------------------------------------------------------- }}}
" Syntax Sync Settings                                                  {{{
"----------------------------------------------------------------------
" After other syntax imports to reset what sync settings they've used

syn sync minlines=10
syn sync maxlines=50
syn sync linebreaks=15

"---------------------------------------------------------------------- }}}
" Clusters                                                              {{{
"----------------------------------------------------------------------

syn cluster pandocBlockElements     contains=
                                    \ pandocBlockQuote,
                                    \ pandocCodeBlock,
                                    \ pandocComment,
                                    \ pandocFootnoteBlock,
                                    \ pandocFrontMatter,
                                    \ pandocHeading,
                                    \ pandocHTMLComment,
                                    \ pandocList,
                                    \ pandocListBlock,
                                    \ pandocParagraph,
                                    \ pandocVerbatimBlock,
                                    \ pandocTeXBlock
syn cluster pandocEmbeddedCode      contains=
                                    \ pandocHaskell,
                                    \ pandocLatex
syn cluster pandocInlineElements    contains=
                                    \ pandocCitation,
                                    \ pandocCitationInline,
                                    \ pandocCitationID,
                                    \ pandocEscapePair,
                                    \ pandocFootnoteInline,
                                    \ pandocFootnoteLink,
                                    \ pandocInlineHTML,
                                    \ pandocInlineHTMLComment,
                                    \ pandocInlineComment,
                                    \ pandocImageLink,
                                    \ pandocImageCaption,
                                    \ pandocImageURL,
                                    \ pandocImageRef,
                                    \ pandocLineBreak,
                                    \ pandocLink,
                                    \ pandocLinkLabel,
                                    \ pandocLinkText,
                                    \ pandocLinkURL,
                                    \ pandocLinkDefinition,
                                    \ pandocListReference,
                                    \ pandocInlineMath,
                                    \ pandocInlineTeX
syn cluster pandocImageElements     contains=
                                    \ pandocImage
syn cluster pandocSmartType         contains=
                                    \ pandocQuote,
                                    \ pandocEnDash,
                                    \ pandocEmDash,
                                    \ pandocEllipsis
syn cluster metadataElements          contains=
                                    \ pandocMetadata,
                                    \ pandocMetadataKey

"---------------------------------------------------------------------- }}}
" Pandoc Block Elements                                                 {{{
"----------------------------------------------------------------------
syn region  pandocNormalBlock       start="\%(^\s*\_s\|\%^\)\@<=.*\S" end="^\s*\_$"               keepend contains=@pandocEmbeddedCode,@pandocInlineElements,@pandocStyles,@pandocSmartType,@spell
syn region  pandocTitleBlock        start="^%" skip="^  \S.*$" end="\%(\_^\s*\_$\_s[^%]\)\@=" keepend contains=@pandocInlineElements,@pandocStyles,pandocTitleBlockTitle,@pandocSmartType,pandocComment,@spell
syn region  pandocTitleBlockTitle   start="\%(\%^\|\_^\s*\_s\_^\)\@<=%%\@!" end="$" keepend oneline contained contains=@pandocInlineElements,@pandocStyles,@pandocSmartType,@spell

"----------------------------------------------------------------------
" Pandoc Comment Match & Option Setting
"----------------------------------------------------------------------
" TODO: Possible that this should be set as part of the inline cluster to 
" ensure that it gets picked up by block level elements, though this is 
" dependent upon the actual implementation of comments
syn match   pandocComment           "^%%.*$"
set comments=:%%,:>

"----------------------------------------------------------------------
" Pandoc Verbatim Block (indented)
"----------------------------------------------------------------------
" following works but a normal block with indented first line gets treated as 
" a vblock on the first line and the rest of the block is no longer normal
"syn region  pandocVerbatimBlock     start="\%(^\_s\+\_^\|\%^\)\@<=\%( \{4,}\|\t\+\)\S*.*$"  end="\n\ze\%( \{0,3}\S\)"    keepend
syn region  pandocVerbatimBlock     start="\%(^\_s\+\_^\|\%^\)\@<=\( \{4,}\|\t\+\)\S*.*\_s\_^\%(\1\|\s*$\)"  end="\n\ze\%( \{0,3}\S\)\@="    keepend
syn region  pandocVerbatimBlockDeep start="\%(^\_s\+\_^\|\%^\)\@<=\%( \{8,}\|\t\+\)\S*.*$"  end="\n\ze\%( \{0,7}\S\)"    keepend contained

"----------------------------------------------------------------------
" Pandoc Code Block (delimited)
"----------------------------------------------------------------------
syn region  pandocCodeBlock         matchgroup=pandocCodeBlockDelim start="\%(^\_s\+\_^\|\%^\)\@<=\%(\z(\s*\~\{3,}\).*\_$\)" end="^\z1\(.*\)$" keepend
for embed_item in s:pandoc_embed
let embed_item = tolower(embed_item)
exe 'syn region  pandocCodeBlock_'.embed_item.' matchgroup=pandocCodeBlockDelim start=/\%(^\_s\+\_^\|\%^\)\@<=\%(\z(\s*\~\{3,}\)\s*{\s*.'.embed_item.'.*\_$\)/ end=/^\z1\%(.*\)$/ keepend transparent containedin=@pandocBlockElements contains=@pandocEmbedded'.embed_item
endfor

"----------------------------------------------------------------------
" Pandoc Block Quote (with leader)
"----------------------------------------------------------------------
if !b:pandoc_lhs
syn region  pandocBlockQuote        start="\%(^\s*\n\)\@<=\z( \{0,3}\|\t\)> .*$"     end="\%(\_^\s*\_$\_^ \{0,3}>\@!\)\@=" keepend contains=@pandocBlockQuoteLeaders 
syn cluster pandocBlockQuoteLeaders contains=pandocBlockQuoteLeader1,pandocBlockQuoteLeader2,pandocBlockQuoteLeader3,pandocBlockQuoteLeader4,pandocBlockQuoteLeader5,pandocBlockQuoteLeader6
syn region  pandocBlockQuoteLeader6 matchgroup=pandocBlockQuoteLeader6 start=">" end="$" contained
syn region  pandocBlockQuoteLeader5 matchgroup=pandocBlockQuoteLeader5 start=">" end="$" contained contains=pandocBlockQuoteLeader6
syn region  pandocBlockQuoteLeader4 matchgroup=pandocBlockQuoteLeader4 start=">" end="$" contained contains=pandocBlockQuoteLeader5
syn region  pandocBlockQuoteLeader3 matchgroup=pandocBlockQuoteLeader3 start=">" end="$" contained contains=pandocBlockQuoteLeader4
syn region  pandocBlockQuoteLeader2 matchgroup=pandocBlockQuoteLeader2 start=">" end="$" contained contains=pandocBlockQuoteLeader3
syn region  pandocBlockQuoteLeader1 matchgroup=pandocBlockQuoteLeader1 start=">" end="$" contained contains=pandocBlockQuoteLeader2
endif

"----------------------------------------------------------------------
" Pandoc Definition Block
"----------------------------------------------------------------------
syn cluster pandocDefinitionCluster contains=@pandocImageElements,@pandocInlineElements,@pandocStylesDefinition,pandocDefinitionIndctr,pandocVerbatimBlockDeep,pandocDefinitionIndctr
syn region  pandocDefinitionBlock   matchgroup=pandocDefinitionTerm start="^[^~:].*\%(\n\{1,2} \{0,2}[~:] \)\@=" end="\%(^\s\{0,3}[^~: ]\)\@=" keepend contains=@pandocDefinitionCluster
if s:pandoc_conceal =~ "d"
syn match   pandocDefinitionIndctr  "\%1c." contained conceal cchar=⫶
endif

"---------------------------------------------------------------------- }}}
" Pandoc Lists                                                          {{{
"----------------------------------------------------------------------
" following list line works pretty well and allows lazy lists, but is too permissive with them and allows a blank line followed by a non list paragraph
" at the same level as the list if the list *starts* indented (like in a definition)
"syn region pandocList matchgroup=pandocListDelim start="\%(\_^\z( *\)\%([*+-]\|#\.\|(\=[[:alnum:]]\+[.)]\) \)\%(\s*\S\)\@=" end="\%(\_^\z1\%([*+-]\|#\.\|(\=[[:alnum:]]\+[.)]\) \s*\S\)\@="
"contained contains=@pandocStyles,@pandocInlineElements,@pandocImageElements,pandocList,pandocCodeBlock transparent keepend fold
"TODO: list nesting works but not for lazy list items...
syn region  pandocListBlock         start="\%(^ \{0,3}\%([*+-]\|#\.\|(\=[[:alnum:]]\+[.)]\|(@[[:alnum:]\-_]*)\) \s*\S\)\@=" end="\%(^\s*\_$\_s\{-}\_^ \{0,3}\S\|\_^<!--\)\@=" keepend transparent contains=pandocList
syn cluster pandocListCluster       contains=@pandocStyles,@pandocInlineElements,@pandocImageElements,pandocList,pandocCodeBlock
"exe 'syn region  pandocList              matchgroup=pandocListMarker start="\%(\_^\z( *\)\%([*+-]\|#\.\|(\=[[:alnum:]]\+[.)]\|(@[[:alnum:]\-_]*)\) \)\%(\s*\S\)\@=" end="\%(\_^\z1\S\)\@=" keepend transparent '.s:pandoc_folding_list.' contained contains=@pandocListCluster'
syn region  pandocList              matchgroup=pandocListMarker start="\%(\_^\z(\s*\)\%([*+-]\|#\.\|(\=[[:alnum:]]\+[.)]\|(@[[:alnum:]\-_]*)\) \)\%(\s*\S\)\@=" end="\%(\_^\z1\S\)\@=" keepend transparent contained contains=@pandocListCluster
syn match   pandocListReference     "(@[[:alnum:]\-_]*)" contained

"---------------------------------------------------------------------- }}}
" Pandoc Tables                                                         {{{
"----------------------------------------------------------------------
" TODO: ideally there should be @pandocInlineElements added to this table 
" cluster, but a variant (pandocInlineElementsTable) that doesn't collapse.
" This should be a refactoring of the exe statements for each syntax item that 
" instead calls a function with parameters such as suffix/parameter that 
" generates all inline cluster elements, all styles, etc.
syn cluster pandocTableCluster      contains=@pandocStylesTable,pandocTableStructure,pandocTableTopRow,pandocTableEndRow,pandocTableZebraLight,pandocTableZebraDark
"syn region  pandocTable             start="\%(\%(^\s*\n\|\%^\)[\-+|= ]\+\s*\_$\)"                       end="\(^[\-+|= ]\+\s*\_$\_s\_^\s*\_$\)" keepend contains=@pandocTableCluster
"syn region  pandocTable             start="\%(^\s*\n\|\%^\)\@<=\s*\S.*\_$\(\_s\_^[\-+|=][\-+|= ]\+\s*\_$\)\@=" end="\(\_$\_s\_^\s*\_$\)\@="            keepend contains=@pandocTableCluster
syn region  pandocTable             start="\%(\%(^\s*\n\|\%^\)\@<=\s*[\-+|=]\{3,}[\-+|= ]*\_$\)"                       end="\(^[\-+|= ]\+\s*\_$\_s\_^\s*\_$\)" keepend contains=@pandocTableCluster
syn region  pandocTable             start="\%(^\s*\n\|\%^\)\@<=\s*\S.*\_$\(\_s\_^[\-+|=][\-+|= ]\+\s*\_$\)\@=" end="\(\_$\_s\_^\s*\_$\)\@="            keepend contains=@pandocTableCluster
if s:pandoc_conceal =~ "t"
syn match   pandocTableStructure    "|"                  contained conceal cchar=│
syn match   pandocTableStructure    "--\@="              contained conceal cchar=─
syn match   pandocTableStructure    "-\@<=-"             contained conceal cchar=─
syn match   pandocTableStructure    "=\@<=="             contained conceal cchar=━
syn match   pandocTableStructure    "==\@="              contained conceal cchar=━
syn match   pandocTableStructure    "-\@<=+-\@="         contained conceal cchar=┼
syn match   pandocTableStructure    "=\@<=+=\@="         contained conceal cchar=┿
syn match   pandocTableStructure    "-\@<=+\%(\s*$\)"    contained conceal cchar=┤
syn match   pandocTableStructure    "=\@<=+\%(\s*$\)"    contained conceal cchar=┥
syn match   pandocTableStructure    "\%(^\s*\)\@<=+-\@=" contained conceal cchar=├
syn match   pandocTableStructure    "\%(^\s*\)\@<=+=\@=" contained conceal cchar=┝
syn match   pandocTableStructureTop "-\@<=+-\@="         contained conceal cchar=┬
syn match   pandocTableStructureTop "=\@<=+=\@="         contained conceal cchar=┯
syn match   pandocTableStructureTop "-\@<=+\_s\@="       contained conceal cchar=┐
syn match   pandocTableStructureTop "=\@<=+\_s\@="       contained conceal cchar=┑
syn match   pandocTableStructureTop "\%(^\s*\)\@<=+-\@=" contained conceal cchar=┌
syn match   pandocTableStructureTop "\%(^\s*\)\@<=+=\@=" contained conceal cchar=┍
syn match   pandocTableStructureEnd "-\@<=+-\@="         contained conceal cchar=┴
syn match   pandocTableStructureEnd "=\@<=+=\@="         contained conceal cchar=┷
syn match   pandocTableStructureEnd "-\@<=+\_s\@="       contained conceal cchar=┘
syn match   pandocTableStructureEnd "=\@<=+\_s\@="       contained conceal cchar=┙
syn match   pandocTableStructureEnd "\%(^\s*\)\@<=+-\@=" contained conceal cchar=└
syn match   pandocTableStructureEnd "\%(^\s*\)\@<=+=\@=" contained conceal cchar=┕
syn match   pandocTableTopRow       "\%(^\s*\n\|\%^\)\@<=[\-+|= ]*$" transparent contained contains=pandocTableStructure,pandocTableStructureTop
syn match   pandocTableEndRow       "^[\-+|= ]*\_$\%(\n\s*$\)\@="  transparent contained contains=pandocTableStructure,pandocTableStructureEnd
else
syn match   pandocTableStructure    "\%(|\|[\-=+]\{2,}\)" contained
endif
syn region  pandocTableCaption      matchgroup=pandocTable start="\%(^\s*\_s\|\%^\)\@<=\s*\ctable:" end="\(^\s*\_$\)\@=" contains=@pandocInlineElements,@pandocStyles
if s:pandoc_styles =~ "z"
syn match   pandocTableZebraLight   "^.*\_$\_s"          contained nextgroup=pandocTableZebraDark
syn match   pandocTableZebraDark    "^.*\_$\_s"          contained nextgroup=pandocTableZebraLight
endif

"---------------------------------------------------------------------- }}}
" Pandoc Headings                                                       {{{
"----------------------------------------------------------------------
if s:pandoc_conceal =~ "\CH"
syn region  pandocHeading           start="\%(^\s*\n\|\%^\)\@<=#\{1,6}[#.]\@!" end="#*\s*$" keepend oneline contains=@pandocInlineElements,@pandocStylesHeading,pandocHeadingMarkerChar
syn match   pandocHeadingMarkerChar "\%(\_^#\{-}#\@!\|#.*\_$\)" contained conceal 
syn match   pandocHeadingMarkerChar "^#\{1}#\@!" contained conceal cchar=1
syn match   pandocHeadingMarkerChar "^#\{2}#\@!" contained conceal cchar=2
syn match   pandocHeadingMarkerChar "^#\{3}#\@!" contained conceal cchar=3
syn match   pandocHeadingMarkerChar "^#\{4}#\@!" contained conceal cchar=4
syn match   pandocHeadingMarkerChar "^#\{5}#\@!" contained conceal cchar=5
syn match   pandocHeadingMarkerChar "^#\{6}#\@!" contained conceal cchar=6
else
syn region  pandocHeading           matchgroup=pandocHeadingMarker start="\%(^\s*\n\|\%^\)\@<=#\{1,6}[#.]\@!" end="#*\s*$" keepend oneline contains=@pandocInlineElements,@pandocStylesHeading,pandocHeadingMarkerChar,@spell
endif
syn region  pandocHeading           start="\%(^\s*\n\|\%^\)\@<=\%(\S.*\n[\-=]\+\s*$\)\@="   end="^[\-=]\+\s*$" keepend contains=@pandocInlineElements,@pandocStylesHeading,pandocHeadingMarker
syn match   pandocHeadingMarker     "^[\-=]\+\s*$" contained contains=pandocHeadingMarkerChar
if s:pandoc_conceal =~ "[hH]"
syn match   pandocHeadingMarkerChar "-" contained conceal cchar=━
syn match   pandocHeadingMarkerChar "=" contained conceal cchar=═
endif

"---------------------------------------------------------------------- }}}
" Pandoc Links, Images, Footnotes, Citations                            {{{
"----------------------------------------------------------------------
if s:pandoc_conceal =~ "l"
    let s:pandoc_conceal_links = "conceal"
    let s:pandoc_conceal_links_ends = "concealends"
else
    let s:pandoc_conceal_links = ""
    let s:pandoc_conceal_links_ends = ""
endif
" following link label pattern works fine but highlights to the end of the 
" paragraph if one is adding a link in by manually entering first one then 
" another bracket
"exe 'syn region  pandocLinkLabel        matchgroup=pandocLinkDelim  start="[\^!]\@<!\[" end="\]" '.s:pandoc_conceal_links_ends.' contained'
exe 'syn region  pandocLinkLabel        matchgroup=pandocLinkDelim  start="[\^!]\@<!\[\%(\%(\_[^\[]\(\_^\s*\_$\)\@!\)\{-}\\\@<!\]\)\@=" end="\]" '.s:pandoc_conceal_links_ends.' contained'
exe 'syn region  pandocLinkDefinitionID matchgroup=pandocLinkDelim  start="[\^!]\@<!\[" end="\]" '.s:pandoc_conceal_links_ends.' contained'
exe 'syn region  pandocLinkText         matchgroup=pandocLinkDelim  start="[\^!]\@<!\[\%(.\{-}\_s\=.\{-}\]\%(\s\{-}\_s\=\s\{-}\[[^\]]\|(\)\)\@=" end="\]" '.s:pandoc_conceal_links_ends.' contained contains=@pandocStyles'
syn region  pandocLinkURL               matchgroup=pandocLinkDelim  start="\]\@<=(" end=")" contained contains=pandocLinkTitle
syn region  pandocLinkTitle             matchgroup=pandocLinkTitleDelim  start="[( ]\zs\z(["']\)" end="\z1\ze[ )]" contained
" following works but it appears from one of the pandoc test files that 2/3 
" line link definitions are acceptable, even without indentation
"syn region  pandocLinkDefinition        start="\%(^ \{0,3}\[[^\^\]][^\[\]]\{-}\]\):" end="\%(\n \{0,3}\[.\{-}\]:\|\n\S\)\@=" contains=pandocLinkDefinitionID,pandocLinkTitle,pandocURL keepend
syn region  pandocLinkDefinition        start="\%(^ \{0,3}\[[^\^\]][^\[\]]\{-}\]\):" end="\%(\_^\s*\[\|\_^\s*\_$\)\@=" contains=pandocLinkDefinitionID,pandocLinkTitle,pandocURL keepend
exe 'syn region  pandocImageCaption     matchgroup=pandocLinkDelim  start="\!\[" end="\]" '.s:pandoc_conceal_links_ends.' contained'
exe 'syn region  pandocImageCaption     matchgroup=pandocLinkDelim  start="\!\[\%(.\{-}\_s\=.\{-}\]\%(\s\{-}\_s\=\s\{-}\[[^\]]\|(\)\)\@=" end="\]" '.s:pandoc_conceal_links_ends.' contained'

if s:pandoc_conceal =~ "f"
    let s:pandoc_conceal_footnotes = "conceal"
    let s:pandoc_conceal_footnotes_ends = "concealends"
else
    let s:pandoc_conceal_footnotes = ""
    let s:pandoc_conceal_footnotes_ends = ""
endif
exe 'syn region  pandocFootnoteLink     matchgroup=pandocLinkDelim  start="\[\^\@=" end="\]" '.s:pandoc_conceal_footnotes_ends.' contained'
exe 'syn region  pandocFootnoteDefLink  matchgroup=pandocLinkDelim  start="^\[\^\@=" end="\]" '.s:pandoc_conceal_footnotes_ends.' contained'
syn region  pandocFootnoteInline        matchgroup=pandocLinkDelim  start="\^\[" end="\]" keepend contained contains=@pandocStyles,@pandocInlineElements,@spell
syn region  pandocFootnote              start="\%(^\[\^.\{-}\]\):" end="\%(\n \{0,3}\[.\{-}\]:\|\n\S\)\@=" keepend contains=@pandocStyles,@pandocInlineElements,pandocVerbatimBlockDeep,pandocFootnoteDefLink,@spell
syn region  pandocFootnote              start="\%(^\[\^.\{-}\]\):" end="\_^\s*\_$\%(\_s\S\)\@=" keepend contains=@pandocStyles,@pandocInlineElements,pandocVerbatimBlockDeep,pandocFootnoteDefLink,@spell
exe 'syn match   pandocFootnoteIndctr   "\%1v." contained '.s:pandoc_conceal_footnotes.' cchar=⫶'

if s:pandoc_conceal =~ "c"
    let s:pandoc_conceal_citations = "conceal"
    let s:pandoc_conceal_citations_ends = "concealends"
else
    let s:pandoc_conceal_citations = ""
    let s:pandoc_conceal_citations_ends = ""
endif
exe 'syn region  pandocCitation         matchgroup=pandocCitationDelim  start="\[\%(@\|[^\]]\{-}\W@\)\@=" end="\]" '.s:pandoc_conceal_citations_ends.' contained contains=pandocCitationID'
syn region  pandocCitationID            matchgroup=pandocCitationDelim  start="\%(\W\|\_^\)\@<=-\=@\%(\S\+\_W\)\@=" end="\_W\@=" contained
syn region  pandocCitationInline        start="\%(\W\|\_^\)\@<=@\S*\%(\_s\{1,2}\[.*\]\)\@=" end="\]" keepend contained contains=pandocCitationID,pandocCitationRef
exe 'syn region  pandocCitationRef      matchgroup=pandocLinkDelim  start="\[" end="\]" '.s:pandoc_conceal_citations_ends.' contained'

"---------------------------------------------------------------------- }}}
" Pandoc Styles                                                         {{{
"----------------------------------------------------------------------
"
" Standard Styles, full collapse
"----------------------------------------------------------------------

" name of substyle and "c" for whether it conceals
let s:pandoc_substyles = [["","c"],["Heading","c"],["Definition","c"],["Table",""]]
for substyle in s:pandoc_substyles
if s:pandoc_conceal =~ "s" && substyle[1] =~ "c" | let s:substyle_conceal = "concealends" | else | let s:substyle_conceal = "" | endif
if s:pandoc_conceal =~ "u" && substyle[1] =~ "c" | let s:substyle_conceal_s = "concealends" | else | let s:substyle_conceal_s = "" | endif
exe 'syn cluster pandocStyles'.substyle[0].'                 contains=pandocEmphasis'.substyle[0].',pandocStrikeout'.substyle[0].',pandocStrongEmphasis'.substyle[0].',pandocStrongEmphasisEmphasis'.substyle[0].',pandocSubscript'.substyle[0].',pandocSuperscript'.substyle[0].',pandocVerbatimInline'.substyle[0]
exe 'syn region  pandocEmphasis'.substyle[0].'               matchgroup=pandocStyleDelim    start="\*\%(\%(\_.\(\_^\s*\_$\)\@!\)\{-}[*\\]\@<!\*\*\@!\)\@=" skip="[*\\]\*" end="\*" keepend '.s:substyle_conceal.' contained contains=@pandocInlineElements,pandocStrongEmphasisNested'
exe 'syn region  pandocEmphasis'.substyle[0].'               matchgroup=pandocStyleDelim    start="\w\@<!__\@!\%(\%(\_.\(\_^\s*\_$\)\@!\)\{-}_\w\@!\)\@=" skip="\\_" end="_\w\@!" keepend '.s:substyle_conceal.' contained contains=@pandocInlineElements,pandocStrongEmphasisNested'
exe 'syn region  pandocStrongEmphasis'.substyle[0].'         matchgroup=pandocStyleDelim    start="\*\*\%(\%(\_.\(\_^\s*\_$\)\@!\)\{-}\\\@<!\*\*\)\@=" skip="\\\*" end="\*\*" keepend '.s:substyle_conceal.' contained contains=@pandocInlineElements,pandocEmphasisNested'
exe 'syn region  pandocStrongEmphasis'.substyle[0].'         matchgroup=pandocStyleDelim    start="\w\@<!__\%(\%(\_.\(\_^\s*\_$\)\@!\)\{-}__\w\@!\)\@=" skip="\\_" end="__\w\@!" keepend '.s:substyle_conceal.' contained contains=@pandocInlineElements,pandocEmphasisNested'
exe 'syn region  pandocEmphasisNested'.substyle[0].'         matchgroup=pandocStyleDelim    start="\*\%(\%(\_.\(\_^\s*\_$\)\@!\)\{-}\*\)\@=" skip="[*\\]\*" end="\*" keepend '.s:substyle_conceal.' contained contains=@pandocInlineElements'
exe 'syn region  pandocEmphasisNested'.substyle[0].'         matchgroup=pandocStyleDelim    start="\w\@<!__\@!\%(\%(\_.\(\_^\s*\_$\)\@!\)\{-}_\w\@!\)\@=" skip="\\_" end="_\w\@!" keepend '.s:substyle_conceal.' contained contains=@pandocInlineElements'
exe 'syn region  pandocStrongEmphasisNested'.substyle[0].'   matchgroup=pandocStyleDelim    start="\*\*\%(\%(\_.\(\_^\s*\_$\)\@!\)\{-}\*\*\)\@=" skip="\\\*" end="\*\*" keepend '.s:substyle_conceal.' contained contains=@pandocInlineElements'
exe 'syn region  pandocStrongEmphasisNested'.substyle[0].'   matchgroup=pandocStyleDelim    start="\w\@<!__\%(\%(\_.\(\_^\s*\_$\)\@!\)\{-}__\w\@!\)\@=" skip="\\_" end="__\w\@!" keepend '.s:substyle_conceal.' contained contains=@pandocInlineElements'
exe 'syn region  pandocStrongEmphasisEmphasis'.substyle[0].' matchgroup=pandocStyleDelim    start="\*\*\*\%(\%(\_.\(\_^\s*\_$\)\@!\)\{-}\*\*\*\)\@=" skip="\\\*" end="\*\*\*" keepend '.s:substyle_conceal.' contained contains=@pandocInlineElements,pandocEmphasisNested'
exe 'syn region  pandocStrongEmphasisEmphasis'.substyle[0].' matchgroup=pandocStyleDelim    start="\w\@<!___\%(\%(\_.\(\_^\s*\_$\)\@!\)\{-}___\w\@!\)\@=" skip="\\[_*]" end="___\w\@!" keepend '.s:substyle_conceal.' contained contains=@pandocInlineElements,pandocEmphasisNested'
exe 'syn region  pandocStrongEmphasisEmphasis'.substyle[0].' matchgroup=pandocStyleDelim    start="\w\@<!__\*\%(\%(\_.\(\_^\s*\_$\)\@!\)\{-}__\*\w\@!\)\@=" skip="\\[_*]" end="\*__\w\@!" keepend '.s:substyle_conceal.' contained contains=@pandocInlineElements,pandocEmphasisNested'
exe 'syn region  pandocStrongEmphasisEmphasis'.substyle[0].' matchgroup=pandocStyleDelim    start="\w\@<!_\*\*\%(\%(\_.\(\_^\s*\_$\)\@!\)\{-}\*\*_\w\@!\)\@=" skip="\\[_*]" end="\*\*_\w\@!" keepend '.s:substyle_conceal.' contained contains=@pandocInlineElements,pandocEmphasisNested'
exe 'syn region  pandocStrikeout'.substyle[0].'              matchgroup=pandocStyleDelim    start="\~\~\%(\%(\_.\(\_^\s*\_$\)\@!\)\{-}\\\@<!\~\~\)\@=" skip="\\\~" end="\~\~" keepend '.s:substyle_conceal.' contained contains=@pandocInlineElements'
exe 'syn region  pandocVerbatimInline'.substyle[0].'         matchgroup=pandocStyleDelim    start="`\@<!\(\z(`\+\)\)`\@!\%(\%(\_.\(\_^\s*\_$\)\@!\)\{-}\1\)\@=" skip="\z1`" end="\z1" keepend '.s:substyle_conceal.' contained'
exe 'syn region  pandocSuperscript'.substyle[0].'            matchgroup=pandocStyleDelim    start="\^\[\@!\%(\%(\_.\(\_^\s*\_$\)\@!\)\{-}\\\@<!\^\)\@=" skip="\\\^" end="\^" '.s:substyle_conceal_s.' contained contains=@pandocInlineElements,@pandocSuperscriptValues'
exe 'syn region  pandocSubscript'.substyle[0].'              matchgroup=pandocStyleDelim    start="\~\~\@!\%(\%(\_.\(\_^\s*\_$\)\@!\)\{-}\\\@<!\~\)\@=" skip="\\\~" end="\~\@<!\~\~\@!" '.s:substyle_conceal_s.' contained contains=@pandocInlineElements,@pandocSubscriptValues'
endfor

" Collapse substitutions
"----------------------------------------------------------------------
if s:pandoc_conceal =~ "u"
syn cluster pandocSubscriptValues   contains=pandocSub0,pandocSub1,pandocSub2,pandocSub3,pandocSub4,pandocSub5,pandocSub6,pandocSub7,pandocSub8,pandocSub9
syn cluster pandocSuperscriptValues contains=pandocSuper0,pandocSuper1,pandocSuper2,pandocSuper3,pandocSuper4,pandocSuper5,pandocSuper6,pandocSuper7,pandocSuper8,pandocSuper9
syn match   pandocSub0              "0" contained conceal transparent cchar=₀
syn match   pandocSub1              "1" contained conceal transparent cchar=₁
syn match   pandocSub2              "2" contained conceal transparent cchar=₂
syn match   pandocSub3              "3" contained conceal transparent cchar=₃
syn match   pandocSub4              "4" contained conceal transparent cchar=₄
syn match   pandocSub5              "5" contained conceal transparent cchar=₅
syn match   pandocSub6              "6" contained conceal transparent cchar=₆
syn match   pandocSub7              "7" contained conceal transparent cchar=₇
syn match   pandocSub8              "8" contained conceal transparent cchar=₈
syn match   pandocSub9              "9" contained conceal transparent cchar=₉
syn match   pandocSuper0            "0" contained conceal transparent cchar=⁰
syn match   pandocSuper1            "1" contained conceal transparent cchar=¹
syn match   pandocSuper2            "2" contained conceal transparent cchar=²
syn match   pandocSuper3            "3" contained conceal transparent cchar=³
syn match   pandocSuper4            "4" contained conceal transparent cchar=⁴
syn match   pandocSuper5            "5" contained conceal transparent cchar=⁵
syn match   pandocSuper6            "6" contained conceal transparent cchar=⁶
syn match   pandocSuper7            "7" contained conceal transparent cchar=⁷
syn match   pandocSuper8            "8" contained conceal transparent cchar=⁸
syn match   pandocSuper9            "9" contained conceal transparent cchar=⁹
endif

"---------------------------------------------------------------------- }}}
" Pandoc Rule                                                           {{{
"----------------------------------------------------------------------
syn match   pandocRule              "\%(^\s*\n\) \=\(\([*\-_]\) \=\)\{2,}\2\s*\_$\%(\_s\_^\s*$\)" contains=pandocRuleLine
if s:pandoc_conceal =~ "r"
syn match   pandocRuleLine          "[ \-*_]"   contained conceal cchar=━
syn match   pandocRuleLine          "[ \-*_]"   contained conceal cchar=━
endif

"---------------------------------------------------------------------- }}}
" Pandoc Escaped Characters                                             {{{
"----------------------------------------------------------------------
syn match   pandocEscapePair "\$\@<!\\." contained contains=pandocEscapedCharacter,pandocNonBreakingSpace
if s:pandoc_conceal =~ "e"
syn match   pandocEscapedCharacter  "\\\@=\S" contained conceal
syn match   pandocNonBreakingSpace  "\\ " contained conceal cchar=〼
syn match   pandocLineBreak "\\$" contained conceal cchar=¶
syn match   pandocLineBreak "  $" contained conceal cchar=¶
else
syn match   pandocEscapedCharacter  "\\\@=\S" contained
syn match   pandocNonBreakingSpace  "\\ " contained
syn match   pandocLineBreak "\\$" contained
syn match   pandocLineBreak "  $" contained
endif

"---------------------------------------------------------------------- }}}
" Smart Type                                                            {{{
"----------------------------------------------------------------------
if s:pandoc_conceal =~ "q"
syn match   pandocQuote     +\w\@<!"\S\@=+ contained conceal cchar=“
syn match   pandocQuote     +\S\@<="w\@!+  contained conceal cchar=”
syn match   pandocQuote     +\w\@<!'\S\@=+ contained conceal cchar=‘
syn match   pandocQuote     +\S\@<='\w\@!+ contained conceal cchar=’
syn match   pandocEnDash    "-\@<!---\@!" contained conceal cchar=–
syn match   pandocEmDash    "-\@<!----\@!" contained contains=pandocEmDashes
syn match   pandocEmDashes  "---\@!" contained conceal cchar=—
syn match   pandocEmDashes  "-\@<!-" contained conceal cchar=—
syn match   pandocEllipsis  "\.\@<!\.\.\.\.\@!" contained conceal cchar=…
endif

"---------------------------------------------------------------------- }}}
" Embedded Code                                                         {{{
"----------------------------------------------------------------------
" see delimited code block above for dynamic code embeds

" HTML
"----------------------------------------------------------------------
syn region  pandocInlineHTML        start="<\S\@=" end="\S\@<=>" keepend contained contains=@pandocStyles,@pandocInlineElements,@pandocEmbeddedhtml
syn region  pandocInlineHTMLcomment start="<!--" end="-->" keepend contained contains=@pandocEmbeddedhtml
syn region  pandocHTMLcomment start="^\s*<!--" end="-->" keepend contains=@pandocEmbeddedhtml

" Pandoc TeX
"----------------------------------------------------------------------
syn region pandocInlineTeX          start="\\\w*[\[{]" end="}\%([^}]*$\)\@=" keepend oneline contained contains=@pandocEmbeddedtex
syn region pandocTeXBlock           start="\c\\begin{\z(\w*\)}" end="\c\\end{\z1}" keepend contains=@pandocEmbeddedtex
syn region pandocTeXBlock           start="^\\\w" end="\%(\_^\s*\_$\_s\s*[^\\]\)\@=" keepend contains=@pandocEmbeddedtex

" Pandoc Math
"----------------------------------------------------------------------
syn region  pandocInlineMath        start="\_s\@<=\(\z(\$\{1,2}\)\)\$\@!\S\@=\%(\%(\_.\(\_^\s*\_$\)\@!\)\{-}\\\@<!\1\)\@=" skip="\\\$" end="\S\@<=\z1" keepend contained contains=@pandocEmbeddedtex

" Pandoc Literate Haskell
"----------------------------------------------------------------------
if b:pandoc_lhs
syn region  pandocLiterateHaskell   start="\%(^\s*\n\)\@<=\z( \{0,3}\|\t\)> \%(.*$\)\@="     end="\%(\_^\s*\_$\_^ \{0,3}>\@!\)\@=" keepend transparent contains=@pandocEmbeddedhaskell,pandocLiterateHaskellIndicator
"syn match   pandocLiterateHaskellIndicator "^> " contained 
"contains=@pandocEmbeddedhaskell
endif

" Metadata (used by Hakyll/LHS)
"----------------------------------------------------------------------
syn region  pandocMetadata    matchgroup=pandocMetadataDelim start="\%^---\s*$" end="^\%(---\|...\)\s*$" contains=pandocMetadataKey keepend
syn region  pandocMetadataKey matchgroup=pandocMetadataKeyName start="\w\{-}:" end="$" contained

"---------------------------------------------------------------------- }}}
" Default Syntax Highlighting                                           {{{
"----------------------------------------------------------------------
" see http://ethanschoonover.com/solarized for a colorscheme with full
" support for these Pandoc Markdown syntax items

if version < 508
  command! -nargs=+ PandocHiLink hi link <args>
else
  command! -nargs=+ PandocHiLink hi def link <args>
endif

"PandocHiLink pandocNormalBlock
PandocHiLink pandocTitleBlock           Identifier
PandocHiLink pandocTitleBlockTitle      pandocTitleBlockTitle
PandocHiLink pandocComment              Comment
PandocHiLink pandocVerbatimBlock        PreProc
PandocHiLink pandocVerbatimBlockDeep    pandocVerbatimBlock
PandocHiLink pandocCodeBlock            pandocVerbatimBlock
PandocHiLink pandocCodeBlockDelim       pandocVerbatimBlock
PandocHiLink pandocBlockQuote           pandocBlockQuoteLeader1
"PandocHiLink pandocBlockQuoteLeader6   Underlined
"PandocHiLink pandocBlockQuoteLeader5   Todo
PandocHiLink pandocBlockQuoteLeader6    Comment
PandocHiLink pandocBlockQuoteLeader5    Constant
PandocHiLink pandocBlockQuoteLeader4    Special
PandocHiLink pandocBlockQuoteLeader3    PreProc
PandocHiLink pandocBlockQuoteLeader2    Statement
PandocHiLink pandocBlockQuoteLeader1    Identifier
PandocHiLink pandocDefinitionBlock      Statement
PandocHiLink pandocDefinitionTerm       Statement
PandocHiLink pandocDefinitionIndctr     Statement
"PandocHiLink pandocListBlock
"following item was previously linked to Todo but removed as many colorschemes
"have an absolutely insane highlight style for that highlight group
PandocHiLink pandocListMarker           Special
"PandocHiLink pandocList
"
"Following should be underlined in custom colorscheme
"PandocHiLink pandocListReference
"
"PandocHiLink pandocInlineHTML
"PandocHiLink pandocInlineHTMLcomment
PandocHiLink pandocTable                Statement
PandocHiLink pandocTableStructure       Identifier
PandocHiLink pandocTableStructureTop    pandocTableStructre
PandocHiLink pandocTableStructureEnd    pandocTableStructre
"PandocHiLink pandocTableTopRow
"PandocHiLink pandocTableEndRow
"PandocHiLink pandocTableZebraLight
"PandocHiLink pandocTableZebraDark
PandocHiLink pandocHeading              Type
PandocHiLink pandocHeadingMarker        PreProc
PandocHiLink pandocHeadingMarkerChar    pandocHeadingMarker
PandocHiLink pandocLinkDelim            Comment
PandocHiLink pandocLinkTitleDelim       Comment
PandocHiLink pandocLinkLabel            Statement
PandocHiLink pandocLinkText             Identifier
PandocHiLink pandocLinkURL              Comment
PandocHiLink pandocLinkTitle            pandocEmphasis
PandocHiLink pandocLinkDefinition       Normal
PandocHiLink pandocLinkDefinitionID     Underlined
"following item was previously linked to Todo but removed as many colorschemes
"have an absolutely insane highlight style for that highlight group
PandocHiLink pandocImageCaption         Special
PandocHiLink pandocFootnoteLink         Constant
PandocHiLink pandocFootnoteDefLink      Constant
PandocHiLink pandocFootnoteInline       Constant
PandocHiLink pandocFootnote             Constant
"PandocHiLink pandocFootnoteIndctr      Constant
PandocHiLink pandocCitationDelim        Underlined
PandocHiLink pandocCitation             Underlined
"following item was previously linked to Todo but removed as many colorschemes
"have an absolutely insane highlight style for that highlight group
PandocHiLink pandocCitationID           Special
"PandocHiLink pandocCitationInline
PandocHiLink pandocCitationRef          pandocCitation
PandocHiLink pandocStyleDelim           Comment
hi def pandocEmphasis                   term=italic cterm=italic gui=italic
hi def pandocEmphasisNested             term=bold,italic cterm=bold,italic gui=bold,italic
hi def pandocStrongEmphasis             term=bold cterm=bold gui=bold
hi def pandocStrongEmphasisNested       term=bold,italic cterm=bold,italic gui=bold,italic
hi def pandocStrongEmphasisEmphasis     term=bold,italic cterm=bold,italic gui=bold,italic
hi def pandocStrikeout                  term=reverse cterm=reverse gui=reverse
PandocHiLink pandocVerbatimInline       PreProc
PandocHiLink pandocSuperscript          Statement
PandocHiLink pandocSubscript            Statement
let s:pandoc_substyles_highlight = ["Definition","Table"]
for subhighlight in s:pandoc_substyles_highlight
exe 'PandocHiLink pandocEmphasis'.subhighlight.' pandocEmphasis'
exe 'PandocHiLink pandocEmphasisNested'.subhighlight.' pandocEmphasisNested'
exe 'PandocHiLink pandocStrongEmphasis'.subhighlight.' pandocStrongEmphasis'
exe 'PandocHiLink pandocStrongEmphasisNested'.subhighlight.' pandocStrongEmphasisNested'
exe 'PandocHiLink pandocStrongEmphasisEmphasis'.subhighlight.' pandocStrongEmphasisEmphasis'
exe 'PandocHiLink pandocStrikeout'.subhighlight.' pandocStrikeout'
exe 'PandocHiLink pandocVerbatimInline'.subhighlight.' pandocVerbatimInline'
exe 'PandocHiLink pandocSuperscript'.subhighlight.' pandocSuperscript'
exe 'PandocHiLink pandocSubscript'.subhighlight.' pandocSubscript'
endfor
PandocHiLink pandocEmphasisHeading                  pandocHeading
PandocHiLink pandocEmphasisNestedHeading            pandocHeading
PandocHiLink pandocStrongEmphasisHeading            pandocHeading
PandocHiLink pandocStrongEmphasisNestedHeading      pandocHeading
PandocHiLink pandocStrongEmphasisEmphasisHeading    pandocHeading
PandocHiLink pandocStrikeoutHeading                 pandocHeading
PandocHiLink pandocVerbatimInlineHeading            pandocHeading
PandocHiLink pandocSuperscriptHeading               pandocHeading
PandocHiLink pandocSubscriptHeading                 pandocHeading
PandocHiLink pandocRule                 Identifier
PandocHiLink pandocRuleLine             pandocRule
PandocHiLink pandocEscapePair           Special
PandocHiLink pandocEscapedCharacter     pandocEscapePair
PandocHiLink pandocNonBreakingSpace     pandocEscapePair
PandocHiLink pandocLineBreak            pandocEscapePair
"PandocHiLink pandocInlineMath
PandocHiLink pandocMetadataDelim        Comment
"following item was previously linked to Todo but removed as many colorschemes
"have an absolutely insane highlight style for that highlight group
PandocHiLink pandocMetadata             Special
PandocHiLink pandocMetadataKey          Identifier
PandocHiLink pandocMetadataKeyName      pandocMetadata
PandocHiLink pandocMetadataTitle        pandocMetadata

"---------------------------------------------------------------------- }}}
"----------------------------------------------------------------------
let b:current_syntax = "pandoc"
