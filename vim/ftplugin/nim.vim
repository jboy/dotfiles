if exists("b:nim_loaded")
  finish
endif

" Added by JB, 2016-02-15.
" Read basic configurations for programming, such as the CamelCaseMode plugin.
source ~/.vim/ftplugin/programming_common_jb.vim

let b:nim_loaded = 1

let s:cpo_save = &cpo
set cpo&vim

call nim#init()

setlocal formatoptions-=t formatoptions+=croql
setlocal comments=:##,:#
setlocal commentstring=#\ %s
setlocal omnifunc=NimComplete
setlocal suffixesadd=.nim 
setlocal expandtab  "Make sure that only spaces are used

" Added by JB, 2016-02-15.
" Some mappings for convenient navigation.
noremap ( ?[[({]<CR>
noremap ) /[])}]<CR>
noremap ; ?[,.;:]<CR>
noremap , /[,.;:]<CR>
" Jump to the next assignment operator.
noremap = <Esc>/[^=>!<]=<CR>ll

compiler nim

let &cpo = s:cpo_save
unlet s:cpo_save

