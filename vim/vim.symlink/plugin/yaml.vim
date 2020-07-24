function! FtYaml()
    setlocal ts=2 sw=2 sts=2
    setlocal indentkeys-=<:>
    setlocal iskeyword+=-
endfunction
au FileType yaml call FtYaml()
