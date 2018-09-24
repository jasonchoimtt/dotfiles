function! FtCoffee()
    setlocal makeprg= " Accidental compilation may shield the .coffee
    setlocal ts=2 sw=2 sts=2
endfunction
au FileType coffee call FtCoffee()
