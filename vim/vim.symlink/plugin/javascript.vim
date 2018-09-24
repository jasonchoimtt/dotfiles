function! FtJavascript()
    let b:interpreter="node %"
    let b:repl_with_file="node"
    let b:repl="node"
    setlocal foldmethod=syntax
endfunction
au FileType javascript call FtJavascript()

if has_key(g:ide_use, 'javascript')
    let g:javascript_enable_domhtmlcss = 1
    let g:syntastic_javascript_checkers = ["eslint"]
    let g:snipMate.scope_aliases['javascript'] = 'javascript,javascript.es6'
    command! EslintFix exec '!eslint --fix "%"' | SyntasticCheck
endif
