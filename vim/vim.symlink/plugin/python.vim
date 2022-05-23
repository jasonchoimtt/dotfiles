function! FtPython()
    call system('which ipython3')
    let py = v:shell_error == 0 ? 'ipython3' : 'python3'
    let b:interpreter = py.' %'
    let b:repl_with_file = py.' -i %'
    imap <buffer> <c-q> <c-r>=repeat(' ', match(getline(line('.')-1), '(') - col('.') + 2)<cr>

    if has_key(g:ide_use, 'python')
        let b:delimitMate_nesting_quotes = ['"', "'"]
        let b:ale_linters = ['python', 'flake8', 'mypy']
        let b:ale_fixers = []
        if !&ro
            ALEEnableBuffer
        endif
    endif
endfunction
au FileType python call FtPython()

let g:pyindent_open_paren = '&sw'
let g:pyindent_continue = '&sw'
if has_key(ide_use, 'python')
    " Anti-clash config
    let g:jedi#auto_vim_configuration = 0
    let g:jedi#popup_on_dot = 0
    let g:jedi#popup_select_first = 0
    let g:jedi#smart_auto_mappings = 0
    let g:jedi#show_call_signatures = 2

    " Consistent with TypeScript plugin
    let g:jedi#goto_command = '<c-]>'
    let g:jedi#rename_command = ',^'

    let g:python_highlight_builtin_objs = 1
    let g:python_highlight_builtin_funcs = 1
    let g:python_highlight_exceptions = 1
    let g:python_highlight_string_formatting = 1
    let g:python_highlight_string_format = 1
    let g:python_highlight_class_vars = 1
    let g:python_slow_sync = 0
endif

