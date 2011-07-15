" $HOME/.vimrc
" Vim initialisation file.
" James Boyden, 2006-12-11 -- 2011-02-25
"
" To quote from the Vim manpage:
" 
"  -u {vimrc}  Use  the  commands in the file {vimrc} for initializations.
"              All the other initializations are  skipped.   Use  this  to
"              edit  a special kind of files.  It can also be used to skip
"              all initializations by giving the name "NONE".  See  ":help
"              initialization" within vim for more details.

" Disable viminfo.
:set viminfo=""

" Switch off that abominable syntax highlighting.
" Vim version 7.0.235 complains that:
" Sorry, the command is not available in this version: :syntax off
:syntax off

" Switch off search pattern highlighting.
:set nohlsearch

" Display tabstops as 8 spaces.
:set ts=8

" Remove the following from the Vi-compatibility options (':help cpoptions' for
" more info; ':set cpoptions' to list the currently-set options) when Vim is
" executed in Vi-compatibility mode:
" 1. To enable the recognition of special key codes in |<>| form in mappings.
" 2. To enable the use of a backslash like a CTRL-V.
" 2. To enable the literal inclusion of '|'.
" 4. To add two spaces after '?' and '!' (just like '.') when joining lines.
" 5. To enable multi-level undo.
" 6. To erase backspaced characters from the screen right away.
" 7. To make <Esc> on a command-line abandon the command-line.
" 8. To enable more intelligent paren-matching.
:set cpo-=<
:set cpo-=B
:set cpo-=b
:set cpo-=J
:set cpo-=u
:set cpo-=v
:set cpo-=x
:set cpo-=%

" For 'plain-text' files (".txt")...
" Set textwidth (":help textwidth") to 79 characters; lines will be broken
" after this width.
au BufEnter *.txt set tw=79
" Unless I don't *want* to break lines...
au BufEnter *.nobr set tw=0

" In Normal (Command) Mode, enable the following mappings:
" K to "break long line before edge of screen".
" ; to "move to next window".
:nmap K 82\|Bhr<Enter>
:nmap ; <C-W>w

" /*
"  * C-style comments.
"  */
:set comments=s1:/*,mb:*,ex:*/

" For C and C++ source files...
" 1. Automatically indent a new line to the same level as the previous one.
"     Hit Ctrl-D to decrease the indentation level, Ctrl-T to increase.
" 2. Use C indentation.
" 3. Format the text so that:
"  - auto-wrap comments using textwidth, inserting the current comment
"     leader automatically. ('c')
"  - the current comment leader is automatically inserted after hitting ENTER
"     in Insert mode. ('r')
"  - the current comment leader is automatically inserted after hitting 'o'
"     or 'O' in Command mode. ('o')
" (see ":help 'formatoptions'", :help fo-table")
au BufEnter *.c,*.cc,*.cpp,*.h,*.hh,*.hpp set ai cindent fo=cro

" C indentation options...  (":help cinoptions-values")
" 1. Place case labels 0 character from the indent of the switch (":0").
" 2. Place C++ scope declarations 0 characters from the indent of the enclosing
"     block ("g0").
" 3. Intend a function return type declaration 2 shiftwidths from the margin
"     ("t2s").
" 4. Indent C++ base class declarations and constructor initialisations 2
"     additional shiftwidths ("i2s").
" 5. Indent a continuation line (a line that spills onto the next) 2
"     additional shiftwidths ("+2s").
set cino=:0g0t2si2s+2s

" For C and C++ source files...
" In Normal (Command) Mode, enable the following mappings:
" 1. Set textwidth (":help textwidth") to 99 characters; lines will be broken
"     after this width.
" 2. K to "break long line before edge of screen".
" 3. J to "strip leading space and comments before line-join".
au BufEnter *.c,*.cc,*.cpp,*.h,*.hh,*.hpp set tw=99
au BufEnter *.c,*.cc,*.cpp,*.h,*.hh,*.hpp nmap K 102\|Bhr<Enter>
au BufEnter *.c,*.cc,*.cpp,*.h,*.hh,*.hpp nnoremap J :.+1s/^<Tab>*\\( \\*\\\|\\/\\/\\)\\? *//<Enter>kJ

" For 'emails' (".email")...
" Set textwidth (":help textwidth") to 70 characters; lines will be broken
" after this width.
au BufEnter *.email set tw=70
" In Normal (Command) Mode, enable the following mappings:
" K to "break long line before edge of screen".
au BufEnter *.email nmap K 73\|Bhr<Enter>

" For Subversion commit log message temporary files...
au BufEnter svn-commit*.tmp set tw=0

" For Python source files (".py")...
" Previously, we set tabs to display as 4 spaces.
"au BufEnter *.py set ai tw=0 ts=4 sw=4
" But now (for the Google code Style Guide) we want to insert 2 space characters
" whenever the tab key is pressed.
"  http://code.google.com/p/soc/wiki/PythonStyleGuide#Indentation
au BufEnter *.py set ai expandtab tw=0 ts=2 sw=2

" Since my plugin "~/.vim/after/ftplugin/mail.vim" no longer seems to work
" in Vim 7 (Ubuntu Feisty Fawn), I'll have to put it here, I guess...
" These next two lines are what's recommended, but they don't seem to work...
"au FileType mail set tw=74
"au FileType mail nmap K 77\|Bhr<Enter>
au BufEnter mutt-* set tw=74
au BufEnter mutt-* nmap K 77\|Bhr<Enter>

" For Tex and BibTex files...
" Dont break long lines.
"au BufEnter *.tex set tw=0
au BufEnter *.bib set tw=0
" Display tab characters as 2 spaces.
au BufEnter *.tex set ai tw=0 ts=2 sw=2

" For "Wiktex" (my own Wiki->Latex format) files...
" Dont break long lines.
" Also, DO auto-indent.
au BufEnter *.wiktex set ai tw=0

" Also, ^N/^P-expand across hyphens in Insert mode.
" See http://vim.1045645.n5.nabble.com/Adding-hyphen-to-iskeyword-but-only-for-keyword-completion-td3279651.html
au InsertEnter *.wiktex :set isk+=- 
au InsertLeave *.wiktex :set isk-=- 
au BufEnter *.wiktex inoremap <c-c> <c-c>:set isk-=-<cr>

" For HTML source files (".html")...
" Display tab characters as 2 spaces.
au BufEnter *.html set ai tw=0 ts=2 sw=2
au BufEnter *.html nmap K 99\|Bhr<Enter>

" For CSS files (".css")...
" Display tab characters as 4 spaces.
au BufEnter *.css set ai tw=0 ts=4 sw=4

" Tab completion.
" '''
" When you type the first tab hit will complete as much as possible, the second
" tab hit will provide a list, the third and subsequent tabs will cycle through
" completion options so you can complete the file without further keys.
" '''
" See http://stackoverflow.com/questions/526858/how-do-i-make-vim-do-normal-bash-like-tab-completion-for-file-names
set wildmode=longest,list,full
set wildmenu

