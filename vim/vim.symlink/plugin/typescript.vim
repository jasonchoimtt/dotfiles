function! FtTypescript()
    if has_key(g:ide_use, 'typescript')
        nmap <buffer> K :10split \| TsuDefinition<cr>
        nmap <buffer> <leader>K :10split \| TsuTypeDefinition<cr>
        nmap <buffer> <leader>k <Plug>(TsuquyomiSignatureHelp)
        nmap <buffer> <leader>i :TsuImport<cr>
        nmap <buffer> <leader><C-^> <Plug>(TsuquyomiReferences)

        let b:ale_linters = ['tsserver', 'eslint']
        let b:ale_fixers = ['prettier']
        ALEEnableBuffer

        setlocal omnifunc=ale#completion#OmniFunc
        syntax sync minlines=1000
    endif
endfunction
au FileType typescript,typescriptreact call FtTypescript()

let g:typescript_compiler_options='--sourcemap --module commonjs'
let g:syntastic_typescript_checkers = ['tsuquyomi']
let g:tsuquyomi_single_quote_import = 1
let g:tsuquyomi_disable_quickfix = 1

" TODO motion
" gC go to constructor
