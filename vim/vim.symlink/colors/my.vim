let g:lucius_style = exists('g:light') && g:light ? 'light' : 'dark'
let g:lucius_contrast = 'high'
let g:lucius_contrast_bg = 'normal'
runtime colors/lucius.vim

let g:colors_name = 'my'

" hi clear SignColumn
" hi link SignColumn LineNr

hi clear LineNr
hi clear CursorLineNr
hi LineNr ctermfg=246 guifg=#949494

" Make fold column stand out less
hi clear FoldColumn
hi FoldColumn ctermfg=250 ctermbg=238 guifg=#bcbcbc guibg=#444444
hi link FoldColumn LineNr

" Increase contrast for comments
hi Comment ctermfg=246 guifg=#949494

" Make folded stand out less
if g:light
    hi Folded ctermfg=241 ctermbg=254 guifg=#626262 guibg=#e4e4e4
else
    " hi Folded ctermfg=250 ctermbg=237 guifg=#bcbcbc guibg=#3a3a3a
endif

" Make coneal look normal
hi clear Conceal
