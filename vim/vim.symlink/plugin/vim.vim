function! FtVim()
    setlocal foldmethod=marker foldlevel=0
endfunction
au FileType vim call FtVim()
