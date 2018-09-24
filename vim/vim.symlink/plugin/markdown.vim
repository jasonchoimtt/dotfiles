function FtMarkdown()
    let &l:makeprg='mark "%" && open -a /Applications/Preview.app "%:r.pdf"'
    setl matchpairs-=<:>
    nmap <buffer> <leader>M :up<cr>:Make!<cr>
    nmap <buffer> gX <Plug>Markdown_EditUrlUnderCursor
    " math display to math align
    nmap <buffer> <silent> <leader>& $Bi\\<cr><esc>k0ea&<esc>0f=i&<esc>o<tab>
    " math align add line break
    nmap <buffer> <silent> <leader>\ :s/\.\?$/ \\\\<cr>:nohls<cr>o
    " math align to math display
    nmap <buffer> <silent> <leader><bs> :s/&\\| \\\\//g<cr>:nohls<cr>
    " preview
    nmap <buffer> <silent> <space> :call system('pandown "'.expand('%').'"')<cr>
    nmap <buffer> <silent> g<space> :up<cr>:call system('pandown "'.expand('%').'"')<cr>
    " add bullet point
    vmap <buffer> <silent> <leader>> :s/^\(.\)/-   \1/<cr>:nohls<cr>
    " remove bulet point
    vmap <buffer> <silent> <leader>< :s/^[- ]   //<cr>:nohls<cr>
    " wrap with \sth{}
    nmap <buffer> <silent> g\ ysiw}i\
    " delete \left \right
    nmap <buffer> <silent> ds\ /\\right<cr>dft?\\left<cr>dft:nohls<cr>
    " auto format
    nmap <cr> gqj
    " add bullet in insert mode
    imap <buffer> <c-_> <bs><bs><bs><bs>-<space><space><space>
    imap <buffer> <c-\> <bs><bs><bs><bs><space><space><space><space>
    setl tw=80
    let &l:commentstring=">%s"
    let b:repl_with_file="open %<.pdf"

    let b:delimitMate_quotes = "\" ' ` $"
    let b:surround_{char2nr('4')} = "$$ \r $$"
    let b:surround_{char2nr('0')} = "\\left(\r\\right)"
    let b:surround_{char2nr('9')} = "\\left[\r\\right]"
    let b:surround_{char2nr('8')} = "**\r**"
    let b:surround_{char2nr('1')} = "‖\r‖"
    let b:surround_{char2nr('!')} = "\\left|\r\\right|"
endfunction
au FileType markdown call FtMarkdown()

let g:tex_superscripts= "[0-9a-zA-W.,:;+-<>/()=]"
let g:tex_subscripts= "0-9aeijoruvx+-/()."
let g:markdown_syntax_conceal = 0
let g:markdown_fenced_languages = ['{\?\.dot.*=dot', '{\?\.python.*=python',  '{\?\.matlab.*=matlab',  '{\?\.\(ba\)\?sh.*=sh']

function MarkdownSyn()
    syn clear markdownItalic markdownError
    unlet b:current_syntax
    syn include @fasttex syntax/fasttex.vim
    let b:current_syntax='markdown'
    syn region markdownMath start="\\\@1<!\$" end="\$" contains=@fasttex keepend
    syn region markdownMath start="\\\@1<!\$\$" end="\$\$" contains=@fasttex keepend
    syn clear markdownCodeBlock
    syn sync maxlines=50
    set conceallevel=0
endfunction
au Syntax markdown call MarkdownSyn()
