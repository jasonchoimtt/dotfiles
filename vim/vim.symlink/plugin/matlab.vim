function! FtMatlab()
    setlocal commentstring=%%s
endfunction
au FileType matlab call FtMatlab()
