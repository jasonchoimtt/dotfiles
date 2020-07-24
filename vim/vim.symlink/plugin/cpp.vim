function! FtCpp()
    let b:ale_linters = ['gcc']
    let b:ale_fixers = []
    ALEEnable
endfunction
au FileType cpp call FtCpp()

if ide
    let g:ale_cpp_gcc_executable = 'g++-9'
    let g:ale_cpp_gcc_options = '-Wall -std=c++11'
endif
