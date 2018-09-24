function! FtRuby()
    let b:interpreter="ruby %"
    let b:repl_with_file="irb -I . -r %"
    let b:repl="irb"
endfunction
au FileType ruby call FtRuby()
