source ~/.vim/ftplugin/programming_common_jb.vim

" For Python source files (".py")...
" Previously, we set tabs to display as 4 spaces.
"au BufEnter *.py set ai tw=0 ts=4 sw=4
" But now (for the Google code Style Guide) we want to insert
" 2 space characters whenever the tab key is pressed.
"  http://code.google.com/p/soc/wiki/PythonStyleGuide#Indentation
set ai expandtab tw=0 ts=2 sw=2

" When there is a visual area of Python code highlighted, press C-P
" to pipe that code into the Python interpreter to be executed.
"
" Note:
"   :write !python<CR>
" runs the command 'python', pipes the selected text into it and presents
" the result on stdout.  This contrasts with
"   :write! python<CR>
" which forces the writing of a new file called 'python' in the current
" directory; and also contrasts with
"   :!python
" which will pipe the visually-selected text into the command 'python'
" and replace the visually-selected text with the result.
"
" See http://vimdoc.sourceforge.net/htmldoc/usr_10.html#10.9
" and http://vimdoc.sourceforge.net/htmldoc/usr_10.html#10.6
" and http://vimdoc.sourceforge.net/htmldoc/change.html#filter
" for details.
vnoremap <C-P> :write !python<CR>

" If there is no visual highlight, run from the beginning of the file
" to the current line.
nnoremap <C-P> :1,.write !python<CR>

