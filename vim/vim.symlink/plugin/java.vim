function! FtJava()
    if has_key(g:ide_use, 'java')
        setlocal omnifunc=javacomplete#Complete
        map <buffer> <leader>i :JCimportAdd<cr>
    endif
endfunction
au FileType java call FtJava()
