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
map <silent> w <Plug>CamelCaseMotion_w
map <silent> b <Plug>CamelCaseMotion_b
map <silent> e <Plug>CamelCaseMotion_e
sunmap w
sunmap b
sunmap e

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
omap <silent> iw <Plug>CamelCaseMotion_iw
xmap <silent> iw <Plug>CamelCaseMotion_iw
omap <silent> ib <Plug>CamelCaseMotion_ib
xmap <silent> ib <Plug>CamelCaseMotion_ib
omap <silent> ie <Plug>CamelCaseMotion_ie
xmap <silent> ie <Plug>CamelCaseMotion_ie

" Now change the meanings of 'W', 'B' and 'E' (which by default
" jump to the next/previous whitespace) with the default meanings
" of 'w', 'b' and 'e' (ie, whole "words" as defined by 'iskeyword').
"  http://vimdoc.sourceforge.net/htmldoc/motion.html#word
"  http://vimdoc.sourceforge.net/htmldoc/options.html#'iskeyword'
"noremap W w
"noremap B b
"noremap E e

" Do a similar thing to convert 'iW' to what 'iw' used to be.
" (There are no 'ib' or 'ie' by default.)
"onoremap <silent> iW iw
"xnoremap <silent> iW iw

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
imap <silent> <C-F> <C-O>w
imap <silent> <C-B> <C-O>b

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

imap <silent> <C-R> <C-O>vbld

" Note:  To correspond with Readline, it would be more correct
" to define this as 'imap <C-D> <C-O>de', but "dw" is more convenient.
"imap <C-D> <C-O>dw
" OTOH: "dw" doesn't work if the cursor is on or immediately before
" the last word of the line.  -.- -.- -.-
" So, I guess "ved" it is...
imap <silent> <C-D> <C-O>ved

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

" Set the "syntax highlighting" (colour scheme) so comments are displayed
" in "dark cyan" rather than the usual dark blue.
"  http://andrewradev.com/2011/08/06/making-vim-pretty-with-custom-colors/
"  http://vimdoc.sourceforge.net/htmldoc/syntax.html#highlight-ctermbg
:hi Comment ctermfg=DarkCyan
