function! FtJavascriptReact()
    let b:ale_linters = ['eslint']
    let b:ale_fixers = ['prettier']
    ALEEnableBuffer

    syntax sync minlines=500
endfunction
au FileType javascriptreact call FtJavascriptReact()
au FileType javascriptreact call FtJavascriptReact()
