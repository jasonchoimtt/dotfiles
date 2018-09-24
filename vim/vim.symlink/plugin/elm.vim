if has_key(g:ide_use, 'elm')
    let g:elm_setup_keybindings = 0
    let g:elm_syntastic_show_warnings = 1
    let g:syntastic_elm_checkers = ['elm_make']
end
