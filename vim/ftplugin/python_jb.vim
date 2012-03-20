source ~/.vim/ftplugin/programming_common_jb.vim

" For Python source files (".py")...
" Previously, we set tabs to display as 4 spaces.
"au BufEnter *.py set ai tw=0 ts=4 sw=4
" But now (for the Google code Style Guide) we want to insert
" 2 space characters whenever the tab key is pressed.
"  http://code.google.com/p/soc/wiki/PythonStyleGuide#Indentation
"set ai expandtab tw=0 ts=2 sw=2
" OK, now for HQ, we'll go back to the Python PEP-8 standard of 4 spaces.
set ai et tw=0 ts=4 sw=4

" See http://vimdoc.sourceforge.net/htmldoc/options.html for more info:
" - ai (autoindent): same indentation as previous line
" - et (expandtab): replace Tab presses with spaces
" - tw=0 (textwidth): don't break lines at a certain length
" - ts=4 (tabstop): how many spaces tabs get expanded to (I think)
" - sw=4 (shiftwidth): number of spaces to autoindent (I think)
" 
" http://vimdoc.sourceforge.net/htmldoc/options.html#'tabstop'
" http://vimdoc.sourceforge.net/htmldoc/options.html#'shiftwidth'


" Some mappings for convenient navigation.
noremap [a vi(
noremap [i vi[
noremap ( ?[[({]<CR>
noremap ) /[[({]<CR>
noremap ; ?[,.;:]<CR>
noremap , /[,.;:]<CR>
"noremap = <Esc>/=[^=]<CR>wv$
noremap = <Esc>/=[^=]<CR>wv$?[^:]<CR>o
noremap g= <Esc>B?=[^=]<CR>wv$?[^:]<CR>o
"noremap ] <Esc>/^[^#]*\\\zs\\\<if\\\>\\\|^[^#]*\\\zs\\\<in\\\><CR>wv$?[^:]<CR>o

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
vnoremap <C-P><C-P> :write !python<CR>

" If there is no visual highlight, run from the beginning of the file
" to the current line.
nnoremap <C-P><C-P> :1,.write !python<CR>

