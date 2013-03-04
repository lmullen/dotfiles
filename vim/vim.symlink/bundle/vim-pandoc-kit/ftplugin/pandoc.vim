" ftplugin files are read only if the filetype has been detected so this should 
" only run if the file has been set to a pandoc filetype.
"
" We want to check if the string "LHS or lhs" is present in the vim modeline 
" after the final colon. A sample modeline might be:
"
"   %% vim:sw=4:"lhs"
"
" The %% assigns this as a Pandoc comment line (this is a newer feature in 
" Pandoc). Content in a modeline after the final colon is ignored and can be 
" used to set plugin specific values through string detection.

amenu &Pandoc.&Preview.HTML     :echo "test"<CR>
amenu &Pandoc.&Preview.&PDF     :echo "test"<CR>

amenu &Pandoc.&Format.&Normalize\ Markdown     :echo "test"<CR>

let g:pandoc_menu=1

let Pandoc={}
let Pandoc.test={'test':[1,2],'testdict':{'sub1':[3,4],'sub2':[5,6]}}
let Pandoc.defaults={
            \'conceal':             {
            \'citations':           [0,"conceals citation formatting"],
            \'definitions':         [1,"conceals definition formatting"],
            \'escaped_characters':  [1,"conceals backslash on escaped characters"],
            \'footnotes':           [0,"conceals footnote formatting"],
            \'headers_underscore':  [1,"setext style header underscore formatting concealed"],
            \'headers_all':         [0,"atx (hash) and setext (underscore) header formatting concealed"],
            \'links':               [1,"conceals url and formatting in links"],
            \'smart_quotes':        [1,"displays straight quotes as smart quotes (simulating output)"],
            \'rules':               [1,"horizontal rules markup is displayed as a simulated rule"],
            \'styles':              [1,"strong, emphasized, strikout and other standard formatting displayed or simulated"],
            \'tables':              [1,"table lines are displayed as true line drawing characters"],
            \'sub_super_script':    [0,"sub and superscript values are display as such when numeric values"],
            \},
            \'styles':              {
            \'zebrastriping':       [0,"tables are displayed with zebrastriped background"],
            \},
            \'folding':             [1,"Pandoc headers, lists set as fold points"],
            \'embed':               [["html","haskell","tex"],"list of syntaxes to highlight"],
            \'lhs':                 [1,"Sets Literate Haskell Mode; highlights blockquotes using Haskell syntax"],
            \}

let g:Pandoc.options={'lhs':'yes'}

function! s:SetOption()
" recursively process dict for key values, prioritize preset value, append to 
" option generation list
endfunction

function! PandocTest(...)
    echo a:000
endfunction

function! PandocSetOptions(dict,path)
    let d='.'
    for l:key in keys(a:dict)
        if type(a:dict[key])==type({})
            call add(path,key)
            call PandocSetOptions(a:dict[key],a:newroot,path.key)
        else
            let l:full=a:newroot.d.l:path.l:key
            echo full
            let full='g:'.l:full
            if exists(l:full) | echo "XXXXXX FOUND XXXXXX ".eval(l:full) | endif
            let {'g:'.a:newroot.d.l:path.'["'.l:key.'"]'}=1234
            if exists(l:full) | echo "XXXXXX FOUND XXXXXX ".eval(l:full) | endif
            " . " : " . string(a:dict[key])
        endif
    endfor
endfunction

function! s:GenerateMenu()

    if exists("g:loaded_pandoc_menu")
        try
            silent! aunmenu Pandoc
        endtry
    endif

    let g:loaded_pandoc_menu = 1

    function! l:MakeToggleMenuItem(submenu,optionkey,menuitem,shortcutkey,tooltip,commandstring)
        if eval{'Pandoc.'.tolower(a:submenuname).'.'.a:optionname} == 1
            let l:state_indicator="*"
        else
            let l:state_indicator=" "
        endif
        exe 'amenu &Pandoc.&'.a:submenu.'.'.a:optionname.'<Tab>'.a:shortcutkey.' '.commandstring<Nop>
    endfunction

    if g:pandoc_menu != 0

        amenu &Pandoc.&Conceal.&Conceal\ Everything :let g:solarized_contrast="low"       \| colorscheme solarized<CR>
        an    &Pandoc.&Conceal.-sep0-                <Nop>
        amenu &Pandoc.&Conceal.&Conceal\ Defaults   :let g:solarized_contrast="low"       \| colorscheme solarized<CR>
        an    &Pandoc.&Conceal.-sep1-                <Nop>
        amenu &Pandoc.&Conceal.&Conceal\ Nothing    :let g:solarized_contrast="low"       \| colorscheme solarized<CR>
        an    &Pandoc.&Conceal.-sep2-                <Nop>
        an    &Pandoc.&Conceal.(default\ options,\ *=active)                 <Nop>
        amenu &Pandoc.&Conceal.\ \ \ &definitions <Nop>
        amenu &Pandoc.&Conceal.\ \ \ &escaped\ characters <Nop>
        amenu &Pandoc.&Conceal.\ \ \ &headers\ (underscore\ only) <Nop>
        amenu &Pandoc.&Conceal.\ \ \ &links <Nop>
        amenu &Pandoc.&Conceal.\ \ \ &smart\ Quotes\ &\ typography <Nop>
        amenu &Pandoc.&Conceal.\ \ \ &rules <Nop>
        amenu &Pandoc.&Conceal.\ \ \ &styles <Nop>
        amenu &Pandoc.&Conceal.\ \ \ &tables <Nop>
        an    &Pandoc.&Conceal.-sep3-                <Nop>
        an    &Pandoc.&Conceal.(non-default\ options:\ *=active)                 <Nop>
        amenu &Pandoc.&Conceal.\ \ \ &citations <Nop>
        amenu &Pandoc.&Conceal.\ \ \ &footnotes <Nop>
        amenu &Pandoc.&Conceal.\ \ \ &Headers\ (hash+underscore) <Nop>
        amenu &Pandoc.&Conceal.\ \ \ &sUb/sUperscript <Nop>
        an    &Pandoc.&Conceal.-sep3-                <Nop>

    endif

endfunction

call s:GenerateMenu()


function! s:GenerateOptions()
endfunction

function! s:SetOption()
endfunction

function! s:GetOption()
endfunction

function! s:ToggleOption()
endfunction


