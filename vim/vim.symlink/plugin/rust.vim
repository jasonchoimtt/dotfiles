if has_key(g:ide_use, 'rust')
    let g:ale_rust_rls_config = {
      \   'rust': {
      \     'features': ['test-bpf']
      \   }
      \ }

    " Use this instead of ALE since ALE doesn't work for test-bpf for some
    " reason
    let g:rustfmt_autosave = 1
endif

function! FtRust()
    setlocal cc=100
    if has_key(g:ide_use, 'rust')
        let b:ale_linters = ['cargo']
        let b:ale_fixers = []
        if !&ro
            ALEEnableBuffer
        endif
        call UseALENav()
        call UseALEComplete()
    endif

    " Borrow
    nnoremap <buffer> <leader>b ebi&<esc>W
    nnoremap <buffer> <leader>d ebi*<esc>W
endfunction
au FileType rust call FtRust()
