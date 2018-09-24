function! FtTypescript()
    if has_key(g:ide_use, 'typescript')
        " Workaround for splitjoin somehow breaking for typescript
        unlet b:splitjoin_split_callbacks b:splitjoin_join_callbacks
        source ~/.vim/bundle/splitjoin.vim/ftplugin/typescript/splitjoin.vim
        nmap <leader>i :TsuImport<cr>

        let b:ale_linters = ['tsserver', 'tslint']
        let b:ale_fixers = []
        ALEEnable
    endif
endfunction
au FileType typescript call FtTypescript()

let g:typescript_compiler_options='--sourcemap --module commonjs'
let g:syntastic_typescript_checkers = ['tsuquyomi']
