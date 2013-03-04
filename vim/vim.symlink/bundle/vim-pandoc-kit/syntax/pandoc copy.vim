"" Vim syntax file
"" Language: Pandoc Markdown
"" Maintainer: Ethan Schoonover <es@ethanschoonover.com>
"" URL: http://ethanschoonover.com/vim-syntax-pandoc
"" Filenames: *.markdown,*.mdown,*.mkd,*.mkdn,*.md,*.pandoc
"" Last Change: March 1, 2010
""
"" This is a very heavily commented "literate code" vim syntax file and also 
"" serves as a webpage describing how to make a vim syntax file.
""
"" Comments with a leading pair of double-quotes (such as this line) will be 
"" stripped prior to converting the file to Pandoc markdown format. This 
"" conversion is done with the following search and replace steps:
""
"" Step 1: strip all paired double-quote comment lines
"" Step 2: comment out and non-vim-commented lines in Pandoc blockquote style
"" Step 3: strip leading vim comments from existing comment lines, turning them
""         into valid Pandoc Markdown as well.
""
"" I've create a simple vim script to toggle between the "vim script mode" of 
"" this file and the "pandoc markdown mode", allowing me to seamlessly 
"" round-trip edit this file and test it as a vim script and then output 
"" a version for use as a webpage with Pandoc:
""
"" TODO: toggleLiterateVimMode script goes here
""
"" To create a minimal version of this file (because you don't like the 
"" verbosity, because you hate our freedom, I don't know... for whatever 
"" reason), you can run the following script:
""
"" TODO: minimizeVimScript goes here
""
" % Pandoc Vim Syntax - File and How-to
" % Ethan Schoonover
" % March 1, 2010
"
" Summary
" =======
" 
" Pandoc is an impressive utility that translates between many popular document 
" formats, allowing one to write a document in Markdown or reStructuredText, 
" for example, and automatically translate that same text document to PDF, 
" HTML, LaTeX, or any of several other popular formats.
"
" While I have a great love for the concepts and semantic capabilities of 
" reStructuredText, Markdown use in Pandoc is more popular and better developed 
" at this time. I'm at the beginning of my Haskell studies and may tackle 
" better support for reStructuredText later on, but for now I'll be using 
" Markdown. The beauty of Pandoc is that I can use Markdown now and easily 
" migrate to reStructuredText later.
"
" There were a couple existing Vim syntax definitions available for Pandoc 
" Markdown use prior to my work on this syntax file. The basic Markdown syntax 
" is well maintained and works well for "strict" Markdown. Pandoc, however, 
" extends Markdown and addresses a few issues that make it more acceptable as 
" a reStructuredText replacement. There is an older Pandoc syntax file that 
" uses "pdc" as its filetype, but it was incomplete (no support for 
" definitions, no difference in emphasis and strong-emphasis, etc.). Additional 
" changes to Pandoc (a proposed Pandoc Markdown comment style, for instance) 
" compelled me to wade into Vim syntax authoring.
"
" Use with non-Pandoc Markdown
" ----------------------------
"
" This pandoc.vim syntax file should work fine with non-Pandoc Markdown files, 
" so if you edit both "traditional" and "Pandoc-extended" Markdown documents, 
" you should be safe associating this syntax file with whatever filetypes you 
" use for Markdown (*.markdown or even *.txt, as I do). See the "Syntax 
" Loading" section below for details on how you tell Vim to load this syntax 
" file.
"
" Literate Vim Syntax File
" ------------------------
"
" In order to learn, teach. I felt it might be useful to describe how I have 
" written this syntax file for:
"
" * ease of maintenance
" * educational resource for others that may wish to author a syntax document
"   or alter this document
" * revealing shortcomings or areas that may benefit from improvement in the
"   syntax file itself
"
" I decided to try using a literate programming approach to creating and manage 
" this syntax definition. The document that you are reading right now is either 
" a web page or text file. It is a form of "literate code". Not as native as 
" with Hasekll, for instance, but essentially just a heavily commented Vim 
" syntax which will, with a flick of the wrist and a search/replace or two, 
" turn into a Pandoc markdown file for posting online.
"
" Download
" ========
"
" You can download the current version from:
"
" http://ethanschoonover.com/vim-syntax-pandoc (this page)
" http://ethanschoonover.com/vim-syntax-pandoc/download (actual syntax file)
"
" or from github:
"
" http://github.com/altercation/vim-syntax-pandoc
"
" Installation
" ============
"
" You can install one of two ways: manually or using the recommended method 
" utilizing the Pathogen plugin from Tim Pope.
" 
" Pathogen intall (recommended)
" -----------------------------
" Make sure you are using the Pathogen plugin first. It allows you to keep your 
" many vim plugins organized in a "bundle" subdirectory without scattering 
" configuration files all over the place.
"
" Download the distribution archive and unpack it. You'll have a directory 
" named "vim-syntax-pandoc". Move this directory to your .vim/bundle directory 
" (so the entire path is .vim/bundle/vim-syntax-pandoc). That's it. No need to 
" add anything to your .vimrc (unless you want to add .txt files to your pandoc 
" filetype list, see below).
"
" Manual install
" --------------
" Download the distribution archive and unpack it. Inside the resulting 
" "vim-syntax-pandoc" directory you will find subdirectories named: ftdetect, 
" syntax. You may already have those subdirectories in your .vim configuration 
" directory. If so, move the files you'll find in each of the distribution 
" directories to their corresponding .vim subdirectory. If you don't already 
" have those subdirectories in .vim, you'll have to either create them or 
" simple move the entire directories over from the vim-syntax-pandoc directory.
"
" Features
" =======
"
" Beyond adding in the missing or newer Pandoc markdown features, I wanted to 
" also include:
"
" * folding at header levels
" * folding at collapsible objects such as definition lists
" * list folding for better outlining
" * sample functions for special navigation / content editing
" * sample functions for automatice pandoc output
"
" Differences with the PDC Pandoc syntax and Markdown syntax
" --------------------------------------
" Recognizes escaped characters
" Unified verbatim (code) blocks for folding, etc.
" Greater number of Pandoc features supported
" Breaks out header delimiters from header text
" Supports Pandoc comments (%%)
" Supports Literate Haskell formatting (option)
" Allows for embedded code highlighting and spell checking in code blocks
" Title Block highlighting
" Inline styles that cross Vim line breaks! (but not blank/empty lines as these 
" are paragraphs)
"
" Options
" =======
"
" The following options may be set in your .vimrc or in your modeline on a per 
" file basis if you use the let-modeline vim script.
"
" pandoc_lhs=1
" : turn on Literate Haskell syntax highlighting in blockquotes
"
" pandoc_spell_verbatim=1
" : turn on spelling on pandoc verbatim text blocks (indented content, also
"   called code blocks)
"
" pandoc_comments=[1|0] (default 1)
" : turn on or off support for pandoc comment lines (lines beginnign with %%)
"
" pandoc_fold=[0,1,2,3,4]
"
"
" The Syntax
" ==========
"
" Let's jump in to the actual syntax. I've build this file by simple describing 
" the syntax matching and patterns I wish to achieve and them implementing. 
" I'll detail the pattern syntax as much as possible so that it is 
" comprehensible for those not familiar with Vim's regex syntax.
"
" Reference
" ---------
" 
" If you wish to really understand Vim syntax creation, there is no better 
" resource than the extensive and usually well written Vim help files:
"
"     :help syntax.txt
"     :help vimfiles
"
" Testing
" -------
"
" To test or compare standard Markdown formatting vs Pandoc Markdown 
" formatting, you can load a test file and easily switch between modes by 
" changing the filtype. Once a markdown file is loaded, change filetypes by 
" issuing the following commands:
"
"     :set filetype=markdown
" or
"     :set filetype=pandoc
" 
" See https://github.com/jgm/pandoc/tree/master/tests for an excellent set of 
" test files.
"
" Vim preliminaries
" -----------------
"
" ### Syntax loading
"
" If there is a different syntax file loaded for the filetypes we are 
" targetting, we don't override it. This means that a markdown file with the 
" extension of "markdown" will normally source the markdown.vim syntax file in 
" the $VIMRUNTIME/syntax directory and this file, pandoc.vim, will see that the 
" markdown.vim syntax has already been loaded and so exit (the "finish" command 
" in the conditional statement that follows).
" 
" #### Ensuring pandoc.vim is loaded
"
" To ensure that our markdown files are highlighted using this pandoc.vim 
" syntax file, we need to do a couple things:
"
" 1. Make sure that vim can tell the file we are loading is a markdown file and 
" thus should be highlighted as a "pandoc" filetype.
" 2. Ensure that our pandoc.vim syntax file (this document) is in the correct 
" location to be sourced by Vim when one of our filetypes is loaded.
"
" Let's take this step by step:
" 
" ##### 1. Correct filetype associations
"
" Note that I'll go through this explanation here, but you don't need to add 
" these lines to your vimrc if you are using the Pathogen install method. The 
" reason for this is that I've included an ftdetect/pandoc.vim file in the 
" vim-syntax-pandoc distribution which has the correct autocmd in it already 
" (though it doesn't set .txt files as pandoc by default, so you'll still need 
" to add that autocmd to your .vimrc if you want that functionality).
"
" Vim has a couple ways of determining filetypes when you open a document:
"
" * built in list of file extension (.hs is a haskell file, for instance)
" * your own filetype commands (in your .vimrc file, possibly)
" * file contents (#!/bin/sh as a first line indicates a shell script)
" * vim mode lines in a document itself
" * manually setting filetype by issuing a command such as:
"       :set filetype=pandoc
"
" You could include a modeline in each of your Pandoc markdown files, but if 
" you are a heavy Pandoc user this is tedious. Instead, we'll simply tell vim, 
" in our .vimrc file, that all files with a .markdown or .pandoc suffix are 
" Pandoc files and should use our syntax file.
"
"     au! BufNewFile,BufRead *.markdown,*.mdown,*.mkd,*.mkdn,*.md,*.pandoc filetype=pandoc
"
" Note that the use of "filetype=pandoc" overrides the (already read by vim) 
" filetype association for these file suffixes with the markdown.vim syntax. 
" If you don't want to override an otherwise detected filetype, you can use the 
" command "setfiletype pandoc" instead. I'm a heavy Pandoc user and want to 
" treat my .txt files as Pandoc Markdown unless they are detected as something 
" else first, so we'll use this setfiletype command to do just that.
"
"     au! BufRead,BufNewFile *.txt set setfiletype pandoc
" 
" ##### 2. Ensure that Vim can find our pandoc syntax file
"
" Once Vim knows that the file it is loading is a Pandoc Markdown file, it 
" needs to load the correct syntax file. Dropping this file (pandoc.vim) into 
" your .vim/syntax directory should do the trick, though I absoutely prefer and 
" recommend the Pathogen installation method. Both options are covered in the 
" "Installation" section above.
"
" #### Check syntax and load pandoc.vim
" For version 5.x: Clear all syntax items, unset the folding value
" For version 6.x: Quit if a syntax file was already loaded
"
if version < 600
    syntax clear
    if exists("pandoc_fold")
        unlet pandoc_fold
    endif
elseif exists("b:current_syntax")
    finish
endif

" ### Load HTML
"
" We can use embedded HTML and LaTeX in Pandoc Markdown, so we want to allow 
" those syntax files to load. After loading the HTML syntax file we remove the 
" "current_syntax" variable as we will set it ourselves later and will want to 
" load other syntaxes in a moment (LaTeX).
"
" Note that one could simply source the html.vim syntax file using:
"
"     runtime! syntax/html.vim
" 
" This works fine, but we'll go a step further and add a groupname to HTML
"
unlet! b:current_syntax
" TODO: delete runtime! syntax/html.vim
if version < 600
    syntax include @html <sfile>:p:h/html.vim
else
    syntax include @html syntax/html.vim
endif

" ### Load LaTeX
"
unlet! b:current_syntax
" TODO: delete runtime! syntax/tex.vim
if version < 600
    syntax include @latex <sfile>:p:h/tex.vim
else
    syntax include @latex syntax/tex.vim
endif

" ### Literate Haskell Support
"
" cf http://www.haskell.org/haskellwiki/Literate_programming/Vim
"
" Pandoc has support for literate Haskell code formatting. Code preceded by 
" birdtracks can be treated as Haskell code (normally blockquote). Note that by 
" "birdtracks" we mean the right angle bracket as a line prefix.
"
" If a "b:pandoc_lhs" buffer local variable we can load Haskell syntax and 
" highlight it appropriately.
"
" You can set a global "LHS always on in pandoc markdown files" variable in 
" your .vimrc using the following line:
"
"     let lhs_markup="pandoc"
"
" Alternately, you can include the buffer local version of this in your vim 
" modeline command. You'll first need to install the "let-modeline" vim script 
" from: http://www.vim.org/scripts/script.php?script_id=83 and then need to set 
" the value properly in your vim modeline. Something like the following in your 
" Pandoc file (at the end or beginning should be fine):
"
" %% vim: let b:lhs_markup="pandoc"
"
" If you opt not to set the lhs_markup variable in your .vimrc or modeline, 
" there is still hope. We will check to see if the birdtrack sections of any 
" Pandoc Markdown file you open match a couple Haskell fingerprints and, if so, 
" will turn on LHS as appropriate.
"
" We first check for a buffer-local lhs_markup variable and, if not present, 
" see if there is a global user preference from, for example, the user's .vimrc 
" file. If we find *any* value for the buffer local variable besides 'tex' or 
" 'none' , we'll go ahead and set this as an LHS Pandoc Markdown file. If we 
" don't find a buffer local value, we will check if the global value is present 
" and if so, if it's value is "markdown" or "pandoc" (either is fine). Finally, 
" if we find no variables, we do a quick check for any birdtrack content in the 
" file and see if it has any telltale Haskell content, in which case we turn on 
" LHS.
"
if !exists("b:lhs_markup")
    if exists("lhs_markup")
	if lhs_markup =~ '\<\%(markdown\|pandoc\)\>'
	    let b:lhs_markup = "pandoc"
	else
	    echohl WarningMsg | echo "Unknown value of lhs_markup" | echohl None
	    let b:lhs_markup = "unknown"
	endif
    else
        " no global or buffer local lhs_markup value
	let b:lhs_markup = "unknown"
    endif
else
    if b:lhs_markup !~ '\<\%(tex\|none\)\>'
        let b:lhs_markup = "pandoc"
    endif
endif

if b:lhs_markup == "unknown"
    " TODO: check for Haskell fingerprint
endif

if b:lhs_markup == "pandoc"
    unlet! b:current_syntax
    if version < 600
        syntax include @haskell <sfile>:p:h/haskell.vim
    else
        syntax include @haskell syntax/haskell.vim
    endif
endif

" ### Vim Syntax Highlighting Synchronization
"
" Vim is somewhat "quick and dirty" in its approach to syntax highlighting and 
" occasionally can get "out of sync" (highlighting improperly or not at all).  
"
" There are four ways to synchronize:
" 1. Always parse from the start of the file.
" 2. Based on C-style comments.  Vim understands how C-comments work and can
"    figure out if the current line starts inside or outside a comment.
" 3. Jumping back a certain number of lines and start parsing there.
" 4. Searching backwards in the text for a pattern to sync on.
"
" Like the Markdown syntax, we'll use method 3, jumping back a number of lines 
" and starting from there. We want to ensure a minimum number of lines to jump 
" back so that Vim has enough content to work with in formatting our syntax 
" properly. We'll set the minimum to ten lines, the same as the Markdown vim 
" syntax:
"
syn sync minlines=10

" ### Case (in)sensitivity
"
" Case sensitivity can be switched on and off throughout a Vim syntax 
" definition file using:
" 
"     syn case ignore
"     syn case match
" 
" These are switches which turn case sensitivity off and on and affect all 
" syntax commands following them until another "syn case [ignore|match]" 
" directive is encountered.
"
" We can comfortably turn off case sensitivity as we aren't using any case 
" sensitive keywords.
"
syn case ignore

" Core Markdown
" -------------
"
" This section includes the traditional Markdown syntax with notes if there are 
" differences or restrictions that Pandoc imposes in contrast to the origional 
" Markdown specification. cf http://daringfireball.net/projects/markdown/syntax

" Markdown Block elements
" Markdown Inline elements
" Markdown Misc elements


" Embedded code
" -------------
"
syn cluster pandocEmbeddedCode contains=pandocHTML,pandocLatex,pandocHaskell
" ### HTML
"
syn match pandocHTML "<[^>]*>" contains=@html
syn region pandocHTMLcomment start="<!--" end="-->" contains=@html keepend

" ### LaTeX
"
" TODO: Broken!
"
" Single Tex command
"
"syn match pandocLatex  "\\\w\+{[^}]\+}" contains=@latex

" Tex Block (begin-end)
"
"syn region pandocLatex start="\\begin{[^}]\+}\ze" end="\ze\\end{[^}]\+}" 
"contains=@latex

" Math Tex
"syn match pandocLatex "\(\\\)\@<!\$\S[^$]\+\S\$" contains=@latex

" Block Elements
" --------------
"
" ### Block cluster
"
syn cluster pandocBlockElements contains=pandocHeading,pandocParagraph,pandocList,pandocVerbatimblock,pandocFootnote,pandocComment,pandocFrontMatter
"
" ### Paragraphs and Line Breaks
"
" Two spaces at end of line, treat as newline and allow conceal (replace with 
" pilcrow). Same for a backslash followed by a newline.
"
" ### Headers
" 
" #### Setext style header (underlined)
"
syn region pandocHeading matchgroup=pandocHeadingMarker start="\%(^\_s\+\_^\|\%^\)\@<=\%(.*\_$\_s\_^[\-=]\+\s*\_$\)\@=" end="^[\-=]\+\s*$" contains=@pandocInlineCluster,@pandocStyleCluster keepend
"syn region pandocHeading matchgroup=pandocHeadingMarker 
"start="\(^\_s\+\_^\|\%^\)\@<=\(.*\_s\{1}\_^[\-=]\+\)\@=" end="^[\-=]\+\s*$" 
"contains=@pandocInlineCluster,@pandocStyleCluster keepend

" #### Atx style header (hash marks)
"
syn region pandocHeading matchgroup=pandocHeadingMarker start="\%(^\_s\+\_^\|\%^\)\@<=#\{1,6}#\@!" end="#*\s*$" contains=@pandocInlineCluster,@pandocStyleCluster keepend

" ### Blockquotes
"
" TODO: make sure to check for LHS mode
" in which case blockquotes are the same but contain haskell
"
" ### Lists
"  
"
" ### Verbatim Block (code block)
"
" If you want to allow for specific types of code to show up properly 
" highlighted in your Pandoc Markdown, it is a simple matter of importing the 
" syntax (see above) and adding them to a comma separated contains list as 
" below.
" 
" TODO: try a version of this with skip commands
syn region pandocVerbatimBlock start="\%(^\_s\+\_^\|\%^\)\@<=\%(    \|\t\)" skip="^\_s\+\_^\%(    \|\t\)" end="\%(^\_s\+\_^\)\@=\%(    \|\t\)\@<!"
" contains=@html

" TODO: add code block with delimiter ... tildes, and highlight the code name 
" separately for possible inclusion in a dynamic contains expression
"
" ### Pandoc Title Block & Comments
"
syn region pandocTitleBlock start="^%" skip="^\%(    \|\t\)" end="\_^\@=\%(    \|\t\)\@<!" contains=@pandocInlineCluster,@pandocStyleCluster keepend
syn match pandocComment "^%%.*$"

" ### Horizontal Rules

" Markdown Inline Elements (span elements)
" ------------------------
"
syn cluster pandocInlineCluster contains=pandocEscapePair,pandocImage,pandocLink,pandocFootnoteLink
syn cluster pandocStyleCluster contains=pandocEmphasis,pandocStrongEmphasis,pandocStrikeout,pandocVerbatimInline
"
" ### Backslash Escapes
" any character
" not in verbatim blocks and inline code
"

"
"TODO: following region match just doesn't work (blank line jump)
"syn region pandocEmphasis matchgroup=pandocEmphasisDelim start="\*" 
"skip="\(\\\*\)" end="\*"
"yet the following match based syntax are slow
syn match pandocEmphasis "[\*]\@<!\*\*\@!.\{-}\%(\%(\_^\)\@<!\_$\_s\_^.\{-}\)\{-}.\+[\*]\@<!\*\*\@!" contains=@pandocInlineCluster keepend
syn match pandocEmphasis "[\_[:alnum:]]\@<!_\%(_\)\@!.\{-}\%(\%(\_^\)\@<!\_$\_s\_^.\{-}\)\{-}.\+[\_]\@<!__\@!" contains=@pandocInlineCluster keepend
syn match pandocStrongEmphasis "\\\@<!\*\*.\{-}\%(\%(\_^\)\@<!\_$\_s\_^.\{-}\)\{-}.\+\\\@<!\*\*" contains=@pandocInlineCluster keepend
syn match pandocStrongEmphasis "[\[:alnum:]]\@<!__.\{-}\%(\%(\_^\)\@<!\_$\_s\_^.\{-}\)\{-}.\+\\\@<!__" contains=@pandocInlineCluster keepend
syn match pandocStrikeout "\~\~.\{-}\%(\%(\_^\)\@<!\_$\_s\_^.\{-}\)\{-}.\+\~\~" contains=@pandocInlineCluster keepend
syn match pandocSubscript "[\~]\@<!\~\~\@!.\{-}\%(\%(\_^\)\@<!\_$\_s\_^.\{-}\)\{-}.\+[\~]\@<!\~\~\@!" contains=@pandocInlineCluster keepend
syn match pandocSuperscript "[\\^]\@<!\^\^\@!.\{-}\%(\%(\_^\)\@<!\_$\_s\_^.\{-}\)\{-}.\+[\\^]\@<!\^\^\@!" contains=@pandocInlineCluster keepend
syn match pandocVerbatimInline "[\`]\@<!`.\{-}\%(\%(\_^\)\@<!\_$\_s\_^.\{-}\)\{-}.\+[\`]\@<!`" contains=@pandocInlineCluster keepend
syn match pandocVerbatimInline "\\\@<!``.\{-}\%(\%(\_^\)\@<!\_$\_s\_^.\{-}\)\{-}[^`]\+\\\@<!``" contains=@pandocInlineCluster keepend
syn match pandocLaTeXMath "[\$]\@<!\$\$\@!.\{-}\%(\%(\_^\)\@<!\_$\_s\_^.\{-}\)\{-}.\+[\$]\@<!\$\$\@!" contains=@latex transparent keepend

syn match pandocEscapePair "\\." contains=pandocEscapedCharacter,pandocNonBreakingSpace
syn match pandocEscapedCharacter "\\\@=\S" contained conceal
syn match pandocNonBreakingSpace " " contained conceal
syn match pandocLineBreak "\\$" conceal cchar=¶

" ### Links
" ### Emphasis
" ### Code
" ### Images

let b:current_syntax = "pandoc"

