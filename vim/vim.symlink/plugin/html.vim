au FileType html,jinja,jinja.html setlocal matchpairs-=<:>
au BufRead,BufNewFile *.md set ft=markdown
au BufRead,BufNewFile *.hbs,*.swig,*.vue set ft=html
