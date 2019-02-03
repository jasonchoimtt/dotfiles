function! GoFt()
    Spaces 8
    nmap <buffer> <silent> <leader>zc :call Preserve("g/if err != nil {/normal zozc")<cr>

    if has_key(g:ide_use, "go")
        setl fdm=syntax
        let b:ale_linters = ["go build"]
        let b:ale_fixers = []
        if !&ro
            ALEEnableBuffer
        endif
    endif
endfunction
au FileType go call GoFt()

if has_key(g:ide_use, "go")
    let g:go_fmt_fail_silently = 1
    let g:go_fmt_experimental = 1 " Keeps folds
    let g:go_list_type = "quickfix"
endif
