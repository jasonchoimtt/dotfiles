function! FtMan()
    setlocal ts=8 nolist nornu nonu cc= fdm=indent fdl=99 so=50
    let &titlestring=split(getline('1').getline('2').getline('3'), '\s\+', 'keepempty')[0].""
    nmap q ZQ
    normal M0
endfunction
au FileType man call FtMan()
