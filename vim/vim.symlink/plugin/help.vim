function! FtHelp()
    setlocal buflisted
    nmap <silent><buffer>   <cr> <c-]>
endfunction
au FileType help call FtHelp()
