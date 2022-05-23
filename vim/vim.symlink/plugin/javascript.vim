function! FtJavascript()
    let b:interpreter="node %"
    let b:repl_with_file="node"
    let b:repl="node"
    setlocal foldmethod=syntax

    let b:ale_linters = ['eslint']
    " let b:ale_fixers = ['prettier']
    ALEEnableBuffer

    syntax sync minlines=100
endfunction
au FileType javascript call FtJavascript()

if has_key(g:ide_use, 'javascript')
    let g:javascript_enable_domhtmlcss = 1

    let g:snipMate.scope_aliases['javascript'] = 'javascript,javascript.es6'
endif
