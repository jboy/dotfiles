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

" Switch off syntax highlighting, if so desired.
":syntax off

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
" 1. K : "break long line before edge of screen".
" 2. t : the first part of "move to next window".
"
" (Hence:
"  ts : open ("split") a new window (equivalent to ':sp')
"  tv : open ("vsplit") a new window vertically (equivalent to ':vs')
"  tn : open a new, unnamed window (equivalent to ':new')
"  tw : move down/right to the next window in order (in a cycle)
"  tt : move to the top-left window
"  tp : move to the "previous" (most-recent) window
"  th : move to the next window left
"  tj : move to the next window down
"  etc.)
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
"au BufEnter *.wiktex set ai tw=0
au BufEnter *.wiktex set ai tw=99
au BufEnter *.wiktex nmap K 102\|Bhr<Enter>

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

" The following configurations added on 2011-08-09:

" Note that Vim does not like Alt-key shortcuts, so we will avoid
" use of the Alt key in mappings:
"  http://vim.wikia.com/wiki/Fix_meta-keys_that_break_out_of_Insert_mode

" Alto, don't use Ctrl+m (aka carriage return, <CR>) in any mappings,
" because otherwise you'll lose Enter in Insert Mode.  :P
" In contrast, there seem to be no ill-effects after remapping Ctrl+j
" (newline/linefeed, <NL>).
"  http://vimdoc.sourceforge.net/htmldoc/motion.html#CTRL-M
"  http://vimdoc.sourceforge.net/htmldoc/motion.html#CTRL-J

" Replace the default 'w', 'b' and 'e' mappings
" instead of defining additional mappings',w', ',b' and ',e'.
"
" This uses the amazing CamelCaseMotion plugin:
"  http://www.vim.org/scripts/script.php?script_id=1905
" These mappings are taken from the examples on that page.
"
" The CamelCaseMotion plugin enables the 'w', 'b' and 'e'
" commands to recognise underscores and CamelCase boundaries,
" without breaking ^N/^P completion (as is the unfortunate
" result of the "set iskeyword-=_" approach)
"  http://stackoverflow.com/questions/1279462/how-can-i-configure-vim-so-that-movement-commands-will-include-underscores-and-ca
"
" Note: Ensure there are no trailing space characters at the end
" of these lines, or the mappings will be messed up.
au BufEnter *.c,*.cc,*.cpp,*.h,*.hh,*.hpp,*.py map <silent> w <Plug>CamelCaseMotion_w
au BufEnter *.c,*.cc,*.cpp,*.h,*.hh,*.hpp,*.py map <silent> b <Plug>CamelCaseMotion_b
au BufEnter *.c,*.cc,*.cpp,*.h,*.hh,*.hpp,*.py map <silent> e <Plug>CamelCaseMotion_e
au BufEnter *.c,*.cc,*.cpp,*.h,*.hh,*.hpp,*.py sunmap w
au BufEnter *.c,*.cc,*.cpp,*.h,*.hh,*.hpp,*.py sunmap b
au BufEnter *.c,*.cc,*.cpp,*.h,*.hh,*.hpp,*.py sunmap e

" Replace default 'iw' text-object and define 'ib' and 'ie' motions.
" Also from the examples on:
"  http://www.vim.org/scripts/script.php?script_id=1905
"
" These motions may be used as visual mode operators:
"  http://vimdoc.sourceforge.net/htmldoc/visual.html#visual-operators
" eg, to visually-select the current word, use 'viw'.
"
" Note: Ensure there are no trailing space characters at the end
" of these lines, or the mappings will be messed up.
au BufEnter *.c,*.cc,*.cpp,*.h,*.hh,*.hpp,*.py omap <silent> iw <Plug>CamelCaseMotion_iw
au BufEnter *.c,*.cc,*.cpp,*.h,*.hh,*.hpp,*.py xmap <silent> iw <Plug>CamelCaseMotion_iw
au BufEnter *.c,*.cc,*.cpp,*.h,*.hh,*.hpp,*.py omap <silent> ib <Plug>CamelCaseMotion_ib
au BufEnter *.c,*.cc,*.cpp,*.h,*.hh,*.hpp,*.py xmap <silent> ib <Plug>CamelCaseMotion_ib
au BufEnter *.c,*.cc,*.cpp,*.h,*.hh,*.hpp,*.py omap <silent> ie <Plug>CamelCaseMotion_ie
au BufEnter *.c,*.cc,*.cpp,*.h,*.hh,*.hpp,*.py xmap <silent> ie <Plug>CamelCaseMotion_ie

" Now change the meanings of 'W', 'B' and 'E' (which by default
" jump to the next/previous whitespace) with the default meanings
" of 'w', 'b' and 'e' (ie, whole "words" as defined by 'iskeyword').
"  http://vimdoc.sourceforge.net/htmldoc/motion.html#word
"  http://vimdoc.sourceforge.net/htmldoc/options.html#'iskeyword'
au BufEnter *.c,*.cc,*.cpp,*.h,*.hh,*.hpp,*.py noremap W w
au BufEnter *.c,*.cc,*.cpp,*.h,*.hh,*.hpp,*.py noremap B b
au BufEnter *.c,*.cc,*.cpp,*.h,*.hh,*.hpp,*.py noremap E e

" Do a similar thing to convert 'iW' to what 'iw' used to be.
" (There are no 'ib' or 'ie' by default.)
au BufEnter *.c,*.cc,*.cpp,*.h,*.hh,*.hpp,*.py onoremap <silent> iW iw
au BufEnter *.c,*.cc,*.cpp,*.h,*.hh,*.hpp,*.py xnoremap <silent> iW iw

" Some convenient Insert mode mappings:
" Based upon examples at:
"  http://stackoverflow.com/questions/3602007/vim-del-in-insert-mode
"  http://stackoverflow.com/questions/1737163/vim-traversing-text-in-insert-mode
"  http://vim.wikia.com/wiki/Mapping_keys_in_Vim_-_Tutorial_(Part_1)
"
" Note that 'imap' does what I want here; if I use 'inoremap',
" I lose the CamelCaseMotion mappings defined above.
"
" Ctrl+o followed by a single command means "execute this command
" then return immediately to Insert Mode".
imap <C-F> <C-O>w
imap <C-B> <C-O>b

" Update: The obvious implementation of <C-R> as <C-O>db fails if the
" cursor is at the end of the line (ie, if you're typing a new line),
" since the <C-O>, which effectively ESCs out of Insert Mode, will
" cause the cursor to step back onto the last character that exists,
" which will be the last character of the word; then the "db" will
" delete the characters *before* the cursor.
"imap <C-R> <C-O>db
"
" Also, neither "bdw" nor "bde" work at all, due to what appears to be
" a bug in the CamelCaseMotion plugin.  :\
"
" As a work-around, let's use "vbd" -- with the added proviso that
" "vb" *also* seems to contain a bug:  It goes back 1 char too far
" to the left!  -.-
" We could change this to "vbld", but then it will be wrong at the
" BEGINNING of the line!  FML.
" If we use "vib" instead of "vb", it will not select any space
" trailing the word, so the space will accumulate after successive
" rubouts.  In addition, it suffers from the same problem as "vbd".
" So, it looks like "vbld" is the least-broken approach for now.
"
" Question, 2011-10-18:  Why was that leading underscore there??
"imap <C-R> _<C-O>vbld
"au BufEnter *.c,*.cc,*.cpp,*.h,*.hh,*.hpp,*.py imap <C-R> <C-O>h<C-O>vbld
" Question, 2011-10-22:  Why did I add '<C-O>h' at the beginning??
"
" OK, this is getting ludicrous.  Time to write out some test cases.
" 1. If you're typing at the end of the line, eg, "foo bar baz", you want
"   <C-O>vbld  " this leaves a space after 'bar'
" 2. If you're typing at the end of the line of CamelCase, eg, "FooBarBaz", you want
"   <C-O>vbld  " this leaves the cursor immediately after 'Bar'.
" 3. If you're typing at the end of the line of underscored_text, eg, "foo_bar_baz", you want
"   <C-O>vbld  " this leaves the cursor immediately after 'bar_'.
" 4. If you go all the way back to the beginning of the line, then '<C-O>vbld'
"   will not delete the very first character of the line.
" 5. '<C-O>vbld' works correctly for single-character words (except, of course,
"   for the very first character of the line.
"au BufEnter *.c,*.cc,*.cpp,*.h,*.hh,*.hpp,*.py imap <C-R> <C-O>vbld
"
" 6. Ah, OK, now I see why I included the '<C-O>h':  If you are in Insert Mode
"   and the cursor is on the 'z' of "foo bar bozo", then when you press <C-R>
"   it will inappropriately delete the 'z' in addition to 'bo'.
"   Hence, what if we insert a space then '<C-O>h'?
"au BufEnter *.c,*.cc,*.cpp,*.h,*.hh,*.hpp,*.py imap <C-R>  <C-O>h<C-O>vbld
"
" No, that breaks test case #1 above: the final 'z' will now remain.
" Basically, the issue seems to come down to: Do you want to delete the
" character under the cursor?  In general, the answer is No, unless it's
" a whitespace character or you're at the end of a word.  However, mostly
" when we're typing naturally, we *will* be using this at the end of a word.
"
" '<C-O>vobd' doesn't work for CamelCase (it removes that 'l' at the end of
" the preceding word also).
" '<C-O>vobld' seems to behave the same as '<C-O>vbld'.
"au BufEnter *.c,*.cc,*.cpp,*.h,*.hh,*.hpp,*.py imap <C-R> <C-O>vobd

" For non-CamelCaseMotion text, we can just borrow the default <C-W> behaviour.
imap <C-R> <C-W>
au BufEnter *.c,*.cc,*.cpp,*.h,*.hh,*.hpp,*.py imap <C-R> <C-O>vbld

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
" Hence, let's remap C-_ to C-R
inoremap <C-_> <C-R>
cnoremap <C-_> <C-R>
" This also clobbers the previous meaning of C-D:
" decrease indentation in Insert Mode.
" Hence, we will remap Ctrl+d to Ctrl+l ("Less indentation")
inoremap <C-L> <C-D>
" Since increasing indentation is not repeated as frequently
" as cycling through completions, let's also swap the powerful
" middle-finger C-T (increase indentation in Insert Mode) with
" the weaker pinky-finger C-N ("iNcrease indentation").
inoremap <C-N> <C-T>
" Remap the frequently-repeated but pinky-finger commands C-P/C-N
" to the much more powerful index/middle-finger commands C-H/C-T.
inoremap <C-T> <C-N>
inoremap <C-H> <C-P>

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
imap <silent> <C-A> <C-O>^
imap <silent> <C-E> <C-O>$

" Some general convenience mappings for using tags...
" Split the window and jump to the definition of the identifier
" under the cursor.
nnoremap <silent> <C-T> :sp<CR><C-]>
" Close this split window.  Won't close the window if it's the
" last window (which would exit the program).
nnoremap <silent> <C-X> :close<CR>
" Jump to the definition of the identifier under the cursor.
nnoremap <silent> <C-J> <C-]>
" Pop the top of the tag stack.
" OK, we've stolen the use of C-P and given it to 'Pipe into Python' below.
"nnoremap <silent> <C-P> :pop<CR>

" A few mappings for the Tagbar plugin:
"  http://www.vim.org/scripts/script.php?script_id=3465
" Quickly toggle the visibility of the tagbar.
nnoremap <silent> T :TagbarToggle<CR>

" Useful for both programming and LaTeX writing...
nnoremap <silent> <C-K> :!make<CR>

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
au BufEnter *.py vnoremap <C-P> :write !python<CR>

" If there is no visual highlight, run from the beginning of the file
" to the current line.
au BufEnter *.py nnoremap <C-P> :1,.write !python<CR>

" Only source this if we're editing a LaTeX file; it drops its mappings
" into the main namespace, which is pretty irritating for other file-types.
"
" Update, 2011-10-24:  OK, it's pissing me off a bit... it seems to trigger
" LaTeX-compiles (and complaints about errors that interrupt my train of
" thought) at arbitrary/unexpected moments.  Disabling it now...
"autocmd Filetype tex source ~/.vim/source_explicitly/auctex.vim

