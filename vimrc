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

" Switch on filetype-specific plugins and indenting.
"  http://vimdoc.sourceforge.net/htmldoc/filetype.html
:filetype plugin indent on

" Switch off syntax highlighting, if so desired.
":syntax off
"
" I use Vim in terminals with dark backgrounds, so tell Vim about this
" (so it uses a light-coloured colour for comments, rather than dark blue).
" From this Stack Overflow answer: http://stackoverflow.com/a/6100153
:set background=dark

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
" after this width.  Also, turn on automatic spell-checking.
au BufEnter *.txt set tw=79 spell
set spelllang=en
set spellfile=$HOME/.vim/spell/en.utf-8.add
" Unless I don't *want* to break lines...
au BufEnter *.nobr set tw=0

" In Normal (Command) Mode, enable the following mappings:
" 1. K : "break long line before edge of screen".
" 2. t : the first part of "move to next window".
"
" (Hence:
"  ts : open ("split") a new window (equivalent to ':sp')
"  tv : open ("vsplit") a new window vertically (equivalent to ':vs')
"  tn : open a new, unnamed window (equivalent to ':new')
"
"  tw : move down/right to the next window in order (in a cycle)
"  tt : move to the top-left window
"  tp : move to the "previous" (most-recent) window
"  th : move to the next window left
"  tk : move to the next window up
"  tj : move to the next window down
"
"  tK : move the current window up to the top
"  tJ : move the current window up to the bottom
"  tr : cycle ("rotate") all windows down by one
"  tR : cycle ("reverse-rotate") all windows up by one
" etc.)
" http://vimdoc.sourceforge.net/htmldoc/windows.html
"
" Note that this clobbers the previous meaning of 't', namely:
" Move forward to just before char in current line.  Given the
" existence of the almost-identical command 'f', I'm OK with that.
"
:nmap <silent> K 82\|<C-Left>hr<Enter>
:nnoremap <silent> t <C-W>

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
" after this width.  Also, turn on automatic spell-checking.
au BufEnter *.email set tw=70 spell
" In Normal (Command) Mode, enable the following mappings:
" K to "break long line before edge of screen".
au BufEnter *.email nmap K 73\|Bhr<Enter>

" For Subversion commit log message temporary files...
au BufEnter svn-commit*.tmp set tw=0

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
au BufEnter *.bib set tw=0 paste
" Display tab characters as 2 spaces.
au BufEnter *.tex set ai tw=0 ts=2 sw=2

" For "Wiktex" (my own Wiki->Latex format) files...
" Dont break long lines.
" Also, DO auto-indent.
"au BufEnter *.wiktex set ai tw=0
au BufEnter *.wiktex set ai tw=99
au BufEnter *.wiktex nmap K 102\|Bhr<Enter>
au BufEnter *.wiktex set spell

" Also, ^N/^P-expand across hyphens in Insert mode.
" See http://vim.1045645.n5.nabble.com/Adding-hyphen-to-iskeyword-but-only-for-keyword-completion-td3279651.html
au InsertEnter *.wiktex :set isk+=- 
au InsertLeave *.wiktex :set isk-=- 
au BufEnter *.wiktex inoremap <c-c> <c-c>:set isk-=-<cr>

" For HTML source files (".html")...
"" Display tab characters as 4 spaces.
"au BufEnter *.html set ai tw=0 ts=2 sw=2
" Expand tab characters to 4 spaces.
"au BufEnter *.html set ai et tw=0 ts=2 sw=2
au BufEnter *.html set ai et tw=0 ts=4 sw=4
au BufEnter *.html nmap K 99\|Bhr<Enter>

" For CSS files (".css")...
" Display tab characters as 2 spaces.
"au BufEnter *.css set ai tw=0 ts=4 sw=4
au BufEnter *.css set ai et tw=0 ts=2 sw=2  " For Dad's website
"au BufEnter *.css set ai tw=0 ts=2 sw=2  " For Object AI website

" For my own Nested XPath Filters format...
au BufEnter *.nxf set ai syntax=python

" For Nim source files (".nim")...
" Expand tab characters to 2 spaces as per Nim style guide.
" Update #1: Python syntax highlighting sucks for single quotes like "123'u8".
" So, let's switch off Python syntax highlighting.
" Update #2: I'm disabling this line entirely, since I've copied "nim.vim"
" into the "vim" directory from https://github.com/zah/nim.vim
"au BufEnter *.nim set ai et tw=0 ts=2 sw=2 "syntax=python

" Following more installation instructions at
"  https://github.com/zah/nim.vim#final-step
"
" fun! JumpToDef()
"   if exists("*GotoDefinition_" . &filetype)
"     call GotoDefinition_{&filetype}()
"   else
"     exe "norm! \<C-]>"
"   endif
" endf
" " Jump to tag
" nn <M-g> :call JumpToDef()<cr>
" ino <M-g> <esc>:call JumpToDef()<cr>i

" Tab completion.
" '''
" When you type the first tab hit will complete as much as possible, the second
" tab hit will provide a list, the third and subsequent tabs will cycle through
" completion options so you can complete the file without further keys.
" '''
" See http://stackoverflow.com/questions/526858/how-do-i-make-vim-do-normal-bash-like-tab-completion-for-file-names
set wildmode=longest,list,full
set wildmenu

" For non-CamelCaseMotion text, we can just borrow the default <C-W>
" behaviour.
inoremap <C-R> <C-W>

" Note:  To correspond with Readline, it would be more correct
" to define this as 'imap <C-D> <C-O>de', but "dw" is more convenient.
"imap <C-D> <C-O>dw
" OTOH: "dw" doesn't work if the cursor is on or immediately before
" the last word of the line.  -.- -.- -.-
" So, I guess "ved" it is...
imap <C-D> <C-O>ved
" Note that this clobbers the previous meaning of C-R:
" insert the contents of a register:
"  http://vimdoc.sourceforge.net/htmldoc/insert.html#i_CTRL-R
" Hence, let's remap C-_C-R to C-R
inoremap <C-_><C-R> <C-R>
cnoremap <C-_><C-R> <C-R>
" This also clobbers the previous meaning of C-D:
" decrease indentation in Insert Mode.
" Hence, we will remap Ctrl+d to Ctrl+l ("Less indentation")
inoremap <silent> <C-L> <C-D>
" Since increasing indentation is not repeated as frequently
" as cycling through completions, let's also swap the powerful
" middle-finger C-T (increase indentation in Insert Mode) with
" the weaker pinky-finger C-N ("iNcrease indentation").
inoremap <silent> <C-N> <C-T>
" Remap the frequently-repeated but pinky-finger commands C-P/C-N
" to the much more powerful index/middle-finger commands C-H/C-T.
inoremap <C-T> <C-N>
inoremap <C-H> <C-P>

" Some convenient Insert mode mappings:
" Based upon examples at:
"  http://stackoverflow.com/questions/3602007/vim-del-in-insert-mode
"  http://stackoverflow.com/questions/1737163/vim-traversing-text-in-insert-mode
"  http://vim.wikia.com/wiki/Mapping_keys_in_Vim_-_Tutorial_(Part_1)
"
" Ctrl+o followed by a single command means "execute this command
" then return immediately to Insert Mode".
imap <silent> <C-F> <C-O>w
imap <silent> <C-B> <C-O>b

" And some similar mappings for Command-line Mode:
"  http://vimdoc.sourceforge.net/htmldoc/map.html#map-overview
"  http://vimdoc.sourceforge.net/htmldoc/cmdline.html#Command-line
"
" Unfortunately, I can't seem to repeat the Insert Mode mappings
" above, since Ctrl+o doesn't have the same convenient function of
" 'execute a single command then return immediately to Insert Mode'.
" Hence, I'll use Shift+Right and Shift-Left, which are equivalent
" to the default meanings of 'W' and 'B'.  Not perfect, but better
" than nothing:
"  http://vimdoc.sourceforge.net/htmldoc/motion.html#<S-Right>
cnoremap <C-F> <S-Right>
cnoremap <C-B> <S-Left>

" Mimic the Ctrl+A and Ctrl+E of Emacs in Insert Mode,
" replacing the useless default functions of these shortcuts:
"  http://vimdoc.sourceforge.net/htmldoc/insert.html#i_CTRL-A
"  http://vimdoc.sourceforge.net/htmldoc/insert.html#i_CTRL-E
inoremap <silent> <C-A> <C-O>^
inoremap <silent> <C-E> <C-O>$

" Select a whole word.
" Note that, by default, C-W is used to move between windows;
" however, we've already remapped this to the more convenient 't'.
nnoremap <C-W> viw

" Useful for both programming and LaTeX writing...
nnoremap <silent> <C-K> :!make<CR>

