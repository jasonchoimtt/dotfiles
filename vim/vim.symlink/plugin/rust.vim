function! FtRust()
    setlocal cc=100
    if has_key(g:ide_use, 'rust')
        compiler rustc
    endif
endfunction
au FileType rust call FtRust()
