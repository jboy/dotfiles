" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
plugin/tagbar.vim	[[[1
2830
" ============================================================================
" File:        tagbar.vim
" Description: List the current file's tags in a sidebar, ordered by class etc
" Author:      Jan Larres <jan@majutsushi.net>
" Licence:     Vim licence
" Website:     http://majutsushi.github.com/tagbar/
" Version:     2.1
" Note:        This plugin was heavily inspired by the 'Taglist' plugin by
"              Yegappan Lakshmanan and uses a small amount of code from it.
"
" Original taglist copyright notice:
"              Permission is hereby granted to use and distribute this code,
"              with or without modifications, provided that this copyright
"              notice is copied with it. Like anything else that's free,
"              taglist.vim is provided *as is* and comes with no warranty of
"              any kind, either expressed or implied. In no event will the
"              copyright holder be liable for any damamges resulting from the
"              use of this software.
" ============================================================================

if &cp || exists('g:loaded_tagbar')
    finish
endif

" Initialization {{{1

" Basic init {{{2

if v:version < 700
    echomsg 'Tagbar: Vim version is too old, Tagbar requires at least 7.0'
    finish
endif

if !exists('g:tagbar_ctags_bin')
    if executable('ctags-exuberant')
        let g:tagbar_ctags_bin = 'ctags-exuberant'
    elseif executable('exuberant-ctags')
        let g:tagbar_ctags_bin = 'exuberant-ctags'
    elseif executable('exctags')
        let g:tagbar_ctags_bin = 'exctags'
    elseif executable('ctags')
        let g:tagbar_ctags_bin = 'ctags'
    elseif executable('ctags.exe')
        let g:tagbar_ctags_bin = 'ctags.exe'
    elseif executable('tags')
        let g:tagbar_ctags_bin = 'tags'
    else
        echomsg 'Tagbar: Exuberant ctags not found, skipping plugin'
        finish
    endif
else
    let g:tagbar_ctags_bin = expand(g:tagbar_ctags_bin)
    if !executable(g:tagbar_ctags_bin)
        echomsg 'Tagbar: Exuberant ctags not found in specified place,'
              \ 'skipping plugin'
        finish
    endif
endif

redir => s:ftype_out
silent filetype
redir END
if s:ftype_out !~# 'detection:ON'
    echomsg 'Tagbar: Filetype detection is turned off, skipping plugin'
    unlet s:ftype_out
    finish
endif
unlet s:ftype_out

let g:loaded_tagbar = 1

if !exists('g:tagbar_left')
    let g:tagbar_left = 0
endif

if !exists('g:tagbar_width')
    let g:tagbar_width = 40
endif

if !exists('g:tagbar_autoclose')
    let g:tagbar_autoclose = 0
endif

if !exists('g:tagbar_autofocus')
    let g:tagbar_autofocus = 0
endif

if !exists('g:tagbar_sort')
    let g:tagbar_sort = 1
endif

if !exists('g:tagbar_compact')
    let g:tagbar_compact = 0
endif

if !exists('g:tagbar_expand')
    let g:tagbar_expand = 0
endif

if !exists('g:tagbar_foldlevel')
    let g:tagbar_foldlevel = 99
endif

if !exists('g:tagbar_usearrows')
    let g:tagbar_usearrows = 0
endif

if !exists('g:tagbar_autoshowtag')
    let g:tagbar_autoshowtag = 0
endif

if !exists('g:tagbar_systemenc')
    let g:tagbar_systemenc = &encoding
endif

if has('multi_byte') && has('unix') && &encoding == 'utf-8' &&
 \ (empty(&termencoding) || &termencoding == 'utf-8')
    let s:icon_closed = '▶'
    let s:icon_open   = '▼'
elseif has('multi_byte') && (has('win32') || has('win64')) && g:tagbar_usearrows
    let s:icon_closed = '▷'
    let s:icon_open   = '◢'
else
    let s:icon_closed = '+'
    let s:icon_open   = '-'
endif

let s:type_init_done    = 0
let s:autocommands_done = 0
let s:checked_ctags     = 0
let s:window_expanded   = 0

let s:access_symbols = {
    \ 'public'    : '+',
    \ 'protected' : '#',
    \ 'private'   : '-'
\ }

autocmd SessionLoadPost * nested call s:RestoreSession()

" s:InitTypes() {{{2
function! s:InitTypes()
    let s:known_types = {}

    " Ant {{{3
    let type_ant = {}
    let type_ant.ctagstype = 'ant'
    let type_ant.kinds     = [
        \ {'short' : 'p', 'long' : 'projects', 'fold' : 0},
        \ {'short' : 't', 'long' : 'targets',  'fold' : 0}
    \ ]
    let s:known_types.ant = type_ant
    " Asm {{{3
    let type_asm = {}
    let type_asm.ctagstype = 'asm'
    let type_asm.kinds     = [
        \ {'short' : 'm', 'long' : 'macros',  'fold' : 0},
        \ {'short' : 't', 'long' : 'types',   'fold' : 0},
        \ {'short' : 'd', 'long' : 'defines', 'fold' : 0},
        \ {'short' : 'l', 'long' : 'labels',  'fold' : 0}
    \ ]
    let s:known_types.asm = type_asm
    " ASP {{{3
    let type_aspvbs = {}
    let type_aspvbs.ctagstype = 'asp'
    let type_aspvbs.kinds     = [
        \ {'short' : 'd', 'long' : 'constants',   'fold' : 0},
        \ {'short' : 'c', 'long' : 'classes',     'fold' : 0},
        \ {'short' : 'f', 'long' : 'functions',   'fold' : 0},
        \ {'short' : 's', 'long' : 'subroutines', 'fold' : 0},
        \ {'short' : 'v', 'long' : 'variables',   'fold' : 0}
    \ ]
    let s:known_types.aspvbs = type_aspvbs
    " Awk {{{3
    let type_awk = {}
    let type_awk.ctagstype = 'awk'
    let type_awk.kinds     = [
        \ {'short' : 'f', 'long' : 'functions', 'fold' : 0}
    \ ]
    let s:known_types.awk = type_awk
    " Basic {{{3
    let type_basic = {}
    let type_basic.ctagstype = 'basic'
    let type_basic.kinds     = [
        \ {'short' : 'c', 'long' : 'constants',    'fold' : 0},
        \ {'short' : 'g', 'long' : 'enumerations', 'fold' : 0},
        \ {'short' : 'f', 'long' : 'functions',    'fold' : 0},
        \ {'short' : 'l', 'long' : 'labels',       'fold' : 0},
        \ {'short' : 't', 'long' : 'types',        'fold' : 0},
        \ {'short' : 'v', 'long' : 'variables',    'fold' : 0}
    \ ]
    let s:known_types.basic = type_basic
    " BETA {{{3
    let type_beta = {}
    let type_beta.ctagstype = 'beta'
    let type_beta.kinds     = [
        \ {'short' : 'f', 'long' : 'fragments', 'fold' : 0},
        \ {'short' : 's', 'long' : 'slots',     'fold' : 0},
        \ {'short' : 'v', 'long' : 'patterns',  'fold' : 0}
    \ ]
    let s:known_types.beta = type_beta
    " C {{{3
    let type_c = {}
    let type_c.ctagstype = 'c'
    let type_c.kinds     = [
        \ {'short' : 'd', 'long' : 'macros',      'fold' : 1},
        \ {'short' : 'p', 'long' : 'prototypes',  'fold' : 1},
        \ {'short' : 'g', 'long' : 'enums',       'fold' : 0},
        \ {'short' : 'e', 'long' : 'enumerators', 'fold' : 0},
        \ {'short' : 't', 'long' : 'typedefs',    'fold' : 0},
        \ {'short' : 's', 'long' : 'structs',     'fold' : 0},
        \ {'short' : 'u', 'long' : 'unions',      'fold' : 0},
        \ {'short' : 'm', 'long' : 'members',     'fold' : 0},
        \ {'short' : 'v', 'long' : 'variables',   'fold' : 0},
        \ {'short' : 'f', 'long' : 'functions',   'fold' : 0}
    \ ]
    let type_c.sro        = '::'
    let type_c.kind2scope = {
        \ 'g' : 'enum',
        \ 's' : 'struct',
        \ 'u' : 'union'
    \ }
    let type_c.scope2kind = {
        \ 'enum'   : 'g',
        \ 'struct' : 's',
        \ 'union'  : 'u'
    \ }
    let s:known_types.c = type_c
    " C++ {{{3
    let type_cpp = {}
    let type_cpp.ctagstype = 'c++'
    let type_cpp.kinds     = [
        \ {'short' : 'd', 'long' : 'macros',      'fold' : 1},
        \ {'short' : 'p', 'long' : 'prototypes',  'fold' : 1},
        \ {'short' : 'g', 'long' : 'enums',       'fold' : 0},
        \ {'short' : 'e', 'long' : 'enumerators', 'fold' : 0},
        \ {'short' : 't', 'long' : 'typedefs',    'fold' : 0},
        \ {'short' : 'n', 'long' : 'namespaces',  'fold' : 0},
        \ {'short' : 'c', 'long' : 'classes',     'fold' : 0},
        \ {'short' : 's', 'long' : 'structs',     'fold' : 0},
        \ {'short' : 'u', 'long' : 'unions',      'fold' : 0},
        \ {'short' : 'f', 'long' : 'functions',   'fold' : 0},
        \ {'short' : 'm', 'long' : 'members',     'fold' : 0},
        \ {'short' : 'v', 'long' : 'variables',   'fold' : 0}
    \ ]
    let type_cpp.sro        = '::'
    let type_cpp.kind2scope = {
        \ 'g' : 'enum',
        \ 'n' : 'namespace',
        \ 'c' : 'class',
        \ 's' : 'struct',
        \ 'u' : 'union'
    \ }
    let type_cpp.scope2kind = {
        \ 'enum'      : 'g',
        \ 'namespace' : 'n',
        \ 'class'     : 'c',
        \ 'struct'    : 's',
        \ 'union'     : 'u'
    \ }
    let s:known_types.cpp = type_cpp
    " C# {{{3
    let type_cs = {}
    let type_cs.ctagstype = 'c#'
    let type_cs.kinds     = [
        \ {'short' : 'd', 'long' : 'macros',      'fold' : 1},
        \ {'short' : 'f', 'long' : 'fields',      'fold' : 0},
        \ {'short' : 'g', 'long' : 'enums',       'fold' : 0},
        \ {'short' : 'e', 'long' : 'enumerators', 'fold' : 0},
        \ {'short' : 't', 'long' : 'typedefs',    'fold' : 0},
        \ {'short' : 'n', 'long' : 'namespaces',  'fold' : 0},
        \ {'short' : 'i', 'long' : 'interfaces',  'fold' : 0},
        \ {'short' : 'c', 'long' : 'classes',     'fold' : 0},
        \ {'short' : 's', 'long' : 'structs',     'fold' : 0},
        \ {'short' : 'E', 'long' : 'events',      'fold' : 0},
        \ {'short' : 'm', 'long' : 'methods',     'fold' : 0},
        \ {'short' : 'p', 'long' : 'properties',  'fold' : 0}
    \ ]
    let type_cs.sro        = '.'
    let type_cs.kind2scope = {
        \ 'n' : 'namespace',
        \ 'i' : 'interface',
        \ 'c' : 'class',
        \ 's' : 'struct',
        \ 'g' : 'enum'
    \ }
    let type_cs.scope2kind = {
        \ 'namespace' : 'n',
        \ 'interface' : 'i',
        \ 'class'     : 'c',
        \ 'struct'    : 's',
        \ 'enum'      : 'g'
    \ }
    let s:known_types.cs = type_cs
    " COBOL {{{3
    let type_cobol = {}
    let type_cobol.ctagstype = 'cobol'
    let type_cobol.kinds     = [
        \ {'short' : 'd', 'long' : 'data items',        'fold' : 0},
        \ {'short' : 'f', 'long' : 'file descriptions', 'fold' : 0},
        \ {'short' : 'g', 'long' : 'group items',       'fold' : 0},
        \ {'short' : 'p', 'long' : 'paragraphs',        'fold' : 0},
        \ {'short' : 'P', 'long' : 'program ids',       'fold' : 0},
        \ {'short' : 's', 'long' : 'sections',          'fold' : 0}
    \ ]
    let s:known_types.cobol = type_cobol
    " DOS Batch {{{3
    let type_dosbatch = {}
    let type_dosbatch.ctagstype = 'dosbatch'
    let type_dosbatch.kinds     = [
        \ {'short' : 'l', 'long' : 'labels',    'fold' : 0},
        \ {'short' : 'v', 'long' : 'variables', 'fold' : 0}
    \ ]
    let s:known_types.dosbatch = type_dosbatch
    " Eiffel {{{3
    let type_eiffel = {}
    let type_eiffel.ctagstype = 'eiffel'
    let type_eiffel.kinds     = [
        \ {'short' : 'c', 'long' : 'classes',  'fold' : 0},
        \ {'short' : 'f', 'long' : 'features', 'fold' : 0}
    \ ]
    let type_eiffel.sro        = '.' " Not sure, is nesting even possible?
    let type_eiffel.kind2scope = {
        \ 'c' : 'class',
        \ 'f' : 'feature'
    \ }
    let type_eiffel.scope2kind = {
        \ 'class'   : 'c',
        \ 'feature' : 'f'
    \ }
    let s:known_types.eiffel = type_eiffel
    " Erlang {{{3
    let type_erlang = {}
    let type_erlang.ctagstype = 'erlang'
    let type_erlang.kinds     = [
        \ {'short' : 'm', 'long' : 'modules',            'fold' : 0},
        \ {'short' : 'd', 'long' : 'macro definitions',  'fold' : 0},
        \ {'short' : 'f', 'long' : 'functions',          'fold' : 0},
        \ {'short' : 'r', 'long' : 'record definitions', 'fold' : 0}
    \ ]
    let type_erlang.sro        = '.' " Not sure, is nesting even possible?
    let type_erlang.kind2scope = {
        \ 'm' : 'module'
    \ }
    let type_erlang.scope2kind = {
        \ 'module' : 'm'
    \ }
    let s:known_types.erlang = type_erlang
    " Flex {{{3
    " Vim doesn't support Flex out of the box, this is based on rough
    " guesses and probably requires
    " http://www.vim.org/scripts/script.php?script_id=2909
    " Improvements welcome!
    let type_mxml = {}
    let type_mxml.ctagstype = 'flex'
    let type_mxml.kinds     = [
        \ {'short' : 'v', 'long' : 'global variables', 'fold' : 0},
        \ {'short' : 'c', 'long' : 'classes',          'fold' : 0},
        \ {'short' : 'm', 'long' : 'methods',          'fold' : 0},
        \ {'short' : 'p', 'long' : 'properties',       'fold' : 0},
        \ {'short' : 'f', 'long' : 'functions',        'fold' : 0},
        \ {'short' : 'x', 'long' : 'mxtags',           'fold' : 0}
    \ ]
    let type_mxml.sro        = '.'
    let type_mxml.kind2scope = {
        \ 'c' : 'class'
    \ }
    let type_mxml.scope2kind = {
        \ 'class' : 'c'
    \ }
    let s:known_types.mxml = type_mxml
    " Fortran {{{3
    let type_fortran = {}
    let type_fortran.ctagstype = 'fortran'
    let type_fortran.kinds     = [
        \ {'short' : 'm', 'long' : 'modules',                      'fold' : 0},
        \ {'short' : 'p', 'long' : 'programs',                     'fold' : 0},
        \ {'short' : 'k', 'long' : 'components',                   'fold' : 0},
        \ {'short' : 't', 'long' : 'derived types and structures', 'fold' : 0},
        \ {'short' : 'c', 'long' : 'common blocks',                'fold' : 0},
        \ {'short' : 'b', 'long' : 'block data',                   'fold' : 0},
        \ {'short' : 'e', 'long' : 'entry points',                 'fold' : 0},
        \ {'short' : 'f', 'long' : 'functions',                    'fold' : 0},
        \ {'short' : 's', 'long' : 'subroutines',                  'fold' : 0},
        \ {'short' : 'l', 'long' : 'labels',                       'fold' : 0},
        \ {'short' : 'n', 'long' : 'namelists',                    'fold' : 0},
        \ {'short' : 'v', 'long' : 'variables',                    'fold' : 0}
    \ ]
    let type_fortran.sro        = '.' " Not sure, is nesting even possible?
    let type_fortran.kind2scope = {
        \ 'm' : 'module',
        \ 'p' : 'program',
        \ 'f' : 'function',
        \ 's' : 'subroutine'
    \ }
    let type_fortran.scope2kind = {
        \ 'module'     : 'm',
        \ 'program'    : 'p',
        \ 'function'   : 'f',
        \ 'subroutine' : 's'
    \ }
    let s:known_types.fortran = type_fortran
    " HTML {{{3
    let type_html = {}
    let type_html.ctagstype = 'html'
    let type_html.kinds     = [
        \ {'short' : 'f', 'long' : 'JavaScript funtions', 'fold' : 0},
        \ {'short' : 'a', 'long' : 'named anchors',       'fold' : 0}
    \ ]
    let s:known_types.html = type_html
    " Java {{{3
    let type_java = {}
    let type_java.ctagstype = 'java'
    let type_java.kinds     = [
        \ {'short' : 'p', 'long' : 'packages',       'fold' : 1},
        \ {'short' : 'f', 'long' : 'fields',         'fold' : 0},
        \ {'short' : 'g', 'long' : 'enum types',     'fold' : 0},
        \ {'short' : 'e', 'long' : 'enum constants', 'fold' : 0},
        \ {'short' : 'i', 'long' : 'interfaces',     'fold' : 0},
        \ {'short' : 'c', 'long' : 'classes',        'fold' : 0},
        \ {'short' : 'm', 'long' : 'methods',        'fold' : 0}
    \ ]
    let type_java.sro        = '.'
    let type_java.kind2scope = {
        \ 'g' : 'enum',
        \ 'i' : 'interface',
        \ 'c' : 'class'
    \ }
    let type_java.scope2kind = {
        \ 'enum'      : 'g',
        \ 'interface' : 'i',
        \ 'class'     : 'c'
    \ }
    let s:known_types.java = type_java
    " JavaScript {{{3
    " JavaScript is weird -- it does have scopes, but ctags doesn't seem to
    " properly generate the information for them, instead it simply uses the
    " complete name. So ctags has to be fixed before I can do anything here.
    " Alternatively jsctags/doctorjs will be used if available.
    let type_javascript = {}
    let type_javascript.ctagstype = 'javascript'
    if executable('jsctags')
        let type_javascript.kinds = [
            \ {'short' : 'v', 'long' : 'variables', 'fold' : 0},
            \ {'short' : 'f', 'long' : 'functions', 'fold' : 0}
        \ ]
        let type_javascript.sro        = '.'
        let type_javascript.kind2scope = {
            \ 'v' : 'namespace',
            \ 'f' : 'namespace'
        \ }
        let type_javascript.scope2kind = {
            \ 'namespace' : 'v'
        \ }
        let type_javascript.ctagsbin   = 'jsctags'
        let type_javascript.ctagsargs  = '-f -'
    else
        let type_javascript.kinds = [
            \ {'short' : 'v', 'long' : 'global variables', 'fold' : 0},
            \ {'short' : 'c', 'long' : 'classes',          'fold' : 0},
            \ {'short' : 'p', 'long' : 'properties',       'fold' : 0},
            \ {'short' : 'm', 'long' : 'methods',          'fold' : 0},
            \ {'short' : 'f', 'long' : 'functions',        'fold' : 0}
        \ ]
    endif
    let s:known_types.javascript = type_javascript
    " Lisp {{{3
    let type_lisp = {}
    let type_lisp.ctagstype = 'lisp'
    let type_lisp.kinds     = [
        \ {'short' : 'f', 'long' : 'functions', 'fold' : 0}
    \ ]
    let s:known_types.lisp = type_lisp
    " Lua {{{3
    let type_lua = {}
    let type_lua.ctagstype = 'lua'
    let type_lua.kinds     = [
        \ {'short' : 'f', 'long' : 'functions', 'fold' : 0}
    \ ]
    let s:known_types.lua = type_lua
    " Make {{{3
    let type_make = {}
    let type_make.ctagstype = 'make'
    let type_make.kinds     = [
        \ {'short' : 'm', 'long' : 'macros', 'fold' : 0}
    \ ]
    let s:known_types.make = type_make
    " Matlab {{{3
    let type_matlab = {}
    let type_matlab.ctagstype = 'matlab'
    let type_matlab.kinds     = [
        \ {'short' : 'f', 'long' : 'functions', 'fold' : 0}
    \ ]
    let s:known_types.matlab = type_matlab
    " Ocaml {{{3
    let type_ocaml = {}
    let type_ocaml.ctagstype = 'ocaml'
    let type_ocaml.kinds     = [
        \ {'short' : 'M', 'long' : 'modules or functors', 'fold' : 0},
        \ {'short' : 'v', 'long' : 'global variables',    'fold' : 0},
        \ {'short' : 'c', 'long' : 'classes',             'fold' : 0},
        \ {'short' : 'C', 'long' : 'constructors',        'fold' : 0},
        \ {'short' : 'm', 'long' : 'methods',             'fold' : 0},
        \ {'short' : 'e', 'long' : 'exceptions',          'fold' : 0},
        \ {'short' : 't', 'long' : 'type names',          'fold' : 0},
        \ {'short' : 'f', 'long' : 'functions',           'fold' : 0},
        \ {'short' : 'r', 'long' : 'structure fields',    'fold' : 0}
    \ ]
    let type_ocaml.sro        = '.' " Not sure, is nesting even possible?
    let type_ocaml.kind2scope = {
        \ 'M' : 'Module',
        \ 'c' : 'class',
        \ 't' : 'type'
    \ }
    let type_ocaml.scope2kind = {
        \ 'Module' : 'M',
        \ 'class'  : 'c',
        \ 'type'   : 't'
    \ }
    let s:known_types.ocaml = type_ocaml
    " Pascal {{{3
    let type_pascal = {}
    let type_pascal.ctagstype = 'pascal'
    let type_pascal.kinds     = [
        \ {'short' : 'f', 'long' : 'functions',  'fold' : 0},
        \ {'short' : 'p', 'long' : 'procedures', 'fold' : 0}
    \ ]
    let s:known_types.pascal = type_pascal
    " Perl {{{3
    let type_perl = {}
    let type_perl.ctagstype = 'perl'
    let type_perl.kinds     = [
        \ {'short' : 'p', 'long' : 'packages',    'fold' : 1},
        \ {'short' : 'c', 'long' : 'constants',   'fold' : 0},
        \ {'short' : 'f', 'long' : 'formats',     'fold' : 0},
        \ {'short' : 'l', 'long' : 'labels',      'fold' : 0},
        \ {'short' : 's', 'long' : 'subroutines', 'fold' : 0}
    \ ]
    let s:known_types.perl = type_perl
    " PHP {{{3
    let type_php = {}
    let type_php.ctagstype = 'php'
    let type_php.kinds     = [
        \ {'short' : 'i', 'long' : 'interfaces',           'fold' : 0},
        \ {'short' : 'c', 'long' : 'classes',              'fold' : 0},
        \ {'short' : 'd', 'long' : 'constant definitions', 'fold' : 0},
        \ {'short' : 'f', 'long' : 'functions',            'fold' : 0},
        \ {'short' : 'v', 'long' : 'variables',            'fold' : 0},
        \ {'short' : 'j', 'long' : 'javascript functions', 'fold' : 0}
    \ ]
    let s:known_types.php = type_php
    " Python {{{3
    let type_python = {}
    let type_python.ctagstype = 'python'
    let type_python.kinds     = [
        \ {'short' : 'i', 'long' : 'imports',   'fold' : 1},
        \ {'short' : 'c', 'long' : 'classes',   'fold' : 0},
        \ {'short' : 'f', 'long' : 'functions', 'fold' : 0},
        \ {'short' : 'm', 'long' : 'members',   'fold' : 0},
        \ {'short' : 'v', 'long' : 'variables', 'fold' : 0}
    \ ]
    let type_python.sro        = '.'
    let type_python.kind2scope = {
        \ 'c' : 'class',
        \ 'f' : 'function',
        \ 'm' : 'function'
    \ }
    let type_python.scope2kind = {
        \ 'class'    : 'c',
        \ 'function' : 'f'
    \ }
    let s:known_types.python = type_python
    " REXX {{{3
    let type_rexx = {}
    let type_rexx.ctagstype = 'rexx'
    let type_rexx.kinds     = [
        \ {'short' : 's', 'long' : 'subroutines', 'fold' : 0}
    \ ]
    let s:known_types.rexx = type_rexx
    " Ruby {{{3
    let type_ruby = {}
    let type_ruby.ctagstype = 'ruby'
    let type_ruby.kinds     = [
        \ {'short' : 'm', 'long' : 'modules',           'fold' : 0},
        \ {'short' : 'c', 'long' : 'classes',           'fold' : 0},
        \ {'short' : 'f', 'long' : 'methods',           'fold' : 0},
        \ {'short' : 'F', 'long' : 'singleton methods', 'fold' : 0}
    \ ]
    let type_ruby.sro        = '.'
    let type_ruby.kind2scope = {
        \ 'c' : 'class',
        \ 'm' : 'class'
    \ }
    let type_ruby.scope2kind = {
        \ 'class' : 'c'
    \ }
    let s:known_types.ruby = type_ruby
    " Scheme {{{3
    let type_scheme = {}
    let type_scheme.ctagstype = 'scheme'
    let type_scheme.kinds     = [
        \ {'short' : 'f', 'long' : 'functions', 'fold' : 0},
        \ {'short' : 's', 'long' : 'sets',      'fold' : 0}
    \ ]
    let s:known_types.scheme = type_scheme
    " Shell script {{{3
    let type_sh = {}
    let type_sh.ctagstype = 'sh'
    let type_sh.kinds     = [
        \ {'short' : 'f', 'long' : 'functions', 'fold' : 0}
    \ ]
    let s:known_types.sh = type_sh
    let s:known_types.csh = type_sh
    let s:known_types.zsh = type_sh
    " SLang {{{3
    let type_slang = {}
    let type_slang.ctagstype = 'slang'
    let type_slang.kinds     = [
        \ {'short' : 'n', 'long' : 'namespaces', 'fold' : 0},
        \ {'short' : 'f', 'long' : 'functions',  'fold' : 0}
    \ ]
    let s:known_types.slang = type_slang
    " SML {{{3
    let type_sml = {}
    let type_sml.ctagstype = 'sml'
    let type_sml.kinds     = [
        \ {'short' : 'e', 'long' : 'exception declarations', 'fold' : 0},
        \ {'short' : 'f', 'long' : 'function definitions',   'fold' : 0},
        \ {'short' : 'c', 'long' : 'functor definitions',    'fold' : 0},
        \ {'short' : 's', 'long' : 'signature declarations', 'fold' : 0},
        \ {'short' : 'r', 'long' : 'structure declarations', 'fold' : 0},
        \ {'short' : 't', 'long' : 'type definitions',       'fold' : 0},
        \ {'short' : 'v', 'long' : 'value bindings',         'fold' : 0}
    \ ]
    let s:known_types.sml = type_sml
    " SQL {{{3
    " The SQL ctags parser seems to be buggy for me, so this just uses the
    " normal kinds even though scopes should be available. Improvements
    " welcome!
    let type_sql = {}
    let type_sql.ctagstype = 'sql'
    let type_sql.kinds     = [
        \ {'short' : 'P', 'long' : 'packages',               'fold' : 1},
        \ {'short' : 'c', 'long' : 'cursors',                'fold' : 0},
        \ {'short' : 'f', 'long' : 'functions',              'fold' : 0},
        \ {'short' : 'F', 'long' : 'record fields',          'fold' : 0},
        \ {'short' : 'L', 'long' : 'block label',            'fold' : 0},
        \ {'short' : 'p', 'long' : 'procedures',             'fold' : 0},
        \ {'short' : 's', 'long' : 'subtypes',               'fold' : 0},
        \ {'short' : 't', 'long' : 'tables',                 'fold' : 0},
        \ {'short' : 'T', 'long' : 'triggers',               'fold' : 0},
        \ {'short' : 'v', 'long' : 'variables',              'fold' : 0},
        \ {'short' : 'i', 'long' : 'indexes',                'fold' : 0},
        \ {'short' : 'e', 'long' : 'events',                 'fold' : 0},
        \ {'short' : 'U', 'long' : 'publications',           'fold' : 0},
        \ {'short' : 'R', 'long' : 'services',               'fold' : 0},
        \ {'short' : 'D', 'long' : 'domains',                'fold' : 0},
        \ {'short' : 'V', 'long' : 'views',                  'fold' : 0},
        \ {'short' : 'n', 'long' : 'synonyms',               'fold' : 0},
        \ {'short' : 'x', 'long' : 'MobiLink Table Scripts', 'fold' : 0},
        \ {'short' : 'y', 'long' : 'MobiLink Conn Scripts',  'fold' : 0}
    \ ]
    let s:known_types.sql = type_sql
    " Tcl {{{3
    let type_tcl = {}
    let type_tcl.ctagstype = 'tcl'
    let type_tcl.kinds     = [
        \ {'short' : 'c', 'long' : 'classes',    'fold' : 0},
        \ {'short' : 'm', 'long' : 'methods',    'fold' : 0},
        \ {'short' : 'p', 'long' : 'procedures', 'fold' : 0}
    \ ]
    let s:known_types.tcl = type_tcl
    " LaTeX {{{3
    let type_tex = {}
    let type_tex.ctagstype = 'tex'
    let type_tex.kinds     = [
        \ {'short' : 'p', 'long' : 'parts',          'fold' : 0},
        \ {'short' : 'c', 'long' : 'chapters',       'fold' : 0},
        \ {'short' : 's', 'long' : 'sections',       'fold' : 0},
        \ {'short' : 'u', 'long' : 'subsections',    'fold' : 0},
        \ {'short' : 'b', 'long' : 'subsubsections', 'fold' : 0},
        \ {'short' : 'P', 'long' : 'paragraphs',     'fold' : 0},
        \ {'short' : 'G', 'long' : 'subparagraphs',  'fold' : 0}
    \ ]
    let s:known_types.tex = type_tex
    " Vera {{{3
    " Why are variables 'virtual'?
    let type_vera = {}
    let type_vera.ctagstype = 'vera'
    let type_vera.kinds     = [
        \ {'short' : 'd', 'long' : 'macros',      'fold' : 1},
        \ {'short' : 'g', 'long' : 'enums',       'fold' : 0},
        \ {'short' : 'T', 'long' : 'typedefs',    'fold' : 0},
        \ {'short' : 'c', 'long' : 'classes',     'fold' : 0},
        \ {'short' : 'e', 'long' : 'enumerators', 'fold' : 0},
        \ {'short' : 'm', 'long' : 'members',     'fold' : 0},
        \ {'short' : 'f', 'long' : 'functions',   'fold' : 0},
        \ {'short' : 't', 'long' : 'tasks',       'fold' : 0},
        \ {'short' : 'v', 'long' : 'variables',   'fold' : 0},
        \ {'short' : 'p', 'long' : 'programs',    'fold' : 0}
    \ ]
    let type_vera.sro        = '.' " Nesting doesn't seem to be possible
    let type_vera.kind2scope = {
        \ 'g' : 'enum',
        \ 'c' : 'class',
        \ 'v' : 'virtual'
    \ }
    let type_vera.scope2kind = {
        \ 'enum'      : 'g',
        \ 'class'     : 'c',
        \ 'virtual'   : 'v'
    \ }
    let s:known_types.vera = type_vera
    " Verilog {{{3
    let type_verilog = {}
    let type_verilog.ctagstype = 'verilog'
    let type_verilog.kinds     = [
        \ {'short' : 'c', 'long' : 'constants',           'fold' : 0},
        \ {'short' : 'e', 'long' : 'events',              'fold' : 0},
        \ {'short' : 'f', 'long' : 'functions',           'fold' : 0},
        \ {'short' : 'm', 'long' : 'modules',             'fold' : 0},
        \ {'short' : 'n', 'long' : 'net data types',      'fold' : 0},
        \ {'short' : 'p', 'long' : 'ports',               'fold' : 0},
        \ {'short' : 'r', 'long' : 'register data types', 'fold' : 0},
        \ {'short' : 't', 'long' : 'tasks',               'fold' : 0}
    \ ]
    let s:known_types.verilog = type_verilog
    " VHDL {{{3
    " The VHDL ctags parser unfortunately doesn't generate proper scopes
    let type_vhdl = {}
    let type_vhdl.ctagstype = 'vhdl'
    let type_vhdl.kinds     = [
        \ {'short' : 'P', 'long' : 'packages',   'fold' : 1},
        \ {'short' : 'c', 'long' : 'constants',  'fold' : 0},
        \ {'short' : 't', 'long' : 'types',      'fold' : 0},
        \ {'short' : 'T', 'long' : 'subtypes',   'fold' : 0},
        \ {'short' : 'r', 'long' : 'records',    'fold' : 0},
        \ {'short' : 'e', 'long' : 'entities',   'fold' : 0},
        \ {'short' : 'f', 'long' : 'functions',  'fold' : 0},
        \ {'short' : 'p', 'long' : 'procedures', 'fold' : 0}
    \ ]
    let s:known_types.vhdl = type_vhdl
    " Vim {{{3
    let type_vim = {}
    let type_vim.ctagstype = 'vim'
    let type_vim.kinds     = [
        \ {'short' : 'v', 'long' : 'variables',          'fold' : 1},
        \ {'short' : 'f', 'long' : 'functions',          'fold' : 0},
        \ {'short' : 'a', 'long' : 'autocommand groups', 'fold' : 1},
        \ {'short' : 'c', 'long' : 'commands',           'fold' : 0},
        \ {'short' : 'm', 'long' : 'maps',               'fold' : 1}
    \ ]
    let s:known_types.vim = type_vim
    " YACC {{{3
    let type_yacc = {}
    let type_yacc.ctagstype = 'yacc'
    let type_yacc.kinds     = [
        \ {'short' : 'l', 'long' : 'labels', 'fold' : 0}
    \ ]
    let s:known_types.yacc = type_yacc
    " }}}3

    let user_defs = s:GetUserTypeDefs()
    for [key, value] in items(user_defs)
        if !has_key(s:known_types, key) ||
         \ (has_key(value, 'replace') && value.replace)
            let s:known_types[key] = value
        else
            call extend(s:known_types[key], value)
        endif
    endfor

    " Create a dictionary of the kind order for fast
    " access in sorting functions
    for type in values(s:known_types)
        let i = 0
        let type.kinddict = {}
        for kind in type.kinds
            let type.kinddict[kind.short] = i
            let i += 1
        endfor
    endfor

    let s:type_init_done = 1
endfunction

" s:GetUserTypeDefs() {{{2
function! s:GetUserTypeDefs()
    redir => defs
    silent execute 'let g:'
    redir END

    let deflist = split(defs, '\n')
    call map(deflist, 'substitute(v:val, ''^\S\+\zs.*'', "", "")')
    call filter(deflist, 'v:val =~ "^tagbar_type_"')

    let defdict = {}
    for defstr in deflist
        let type = substitute(defstr, '^tagbar_type_', '', '')
        execute 'let defdict["' . type . '"] = g:' . defstr
    endfor

    " If the user only specified one of kind2scope and scope2kind use it to
    " generate the other one
    " Also, transform the 'kind' definitions into dictionary format
    for def in values(defdict)
        let kinds = def.kinds
        let def.kinds = []
        for kind in kinds
            let kindlist = split(kind, ':')
            let kinddict = {'short' : kindlist[0], 'long' : kindlist[1]}
            if len(kindlist) == 3
                let kinddict.fold = kindlist[2]
            else
                let kinddict.fold = 0
            endif
            call add(def.kinds, kinddict)
        endfor

        if has_key(def, 'kind2scope') && !has_key(def, 'scope2kind')
            let def.scope2kind = {}
            for [key, value] in items(def.kind2scope)
                let def.scope2kind[value] = key
            endfor
        elseif has_key(def, 'scope2kind') && !has_key(def, 'kind2scope')
            let def.kind2scope = {}
            for [key, value] in items(def.scope2kind)
                let def.kind2scope[value] = key
            endfor
        endif
    endfor

    return defdict
endfunction

" s:RestoreSession() {{{2
" Properly restore Tagbar after a session got loaded
function! s:RestoreSession()
    let tagbarwinnr = bufwinnr('__Tagbar__')
    if tagbarwinnr == -1
        " Tagbar wasn't open in the saved session, nothing to do
        return
    else
        let in_tagbar = 1
        if winnr() != tagbarwinnr
            execute tagbarwinnr . 'wincmd w'
            let in_tagbar = 0
        endif
    endif

    if !s:type_init_done
        call s:InitTypes()
    endif

    if !s:checked_ctags
        if !s:CheckForExCtags()
            return
        endif
    endif

    call s:InitWindow(g:tagbar_autoclose)

    " Leave the Tagbar window and come back so the update event gets triggered
    execute 'wincmd p'
    execute tagbarwinnr . 'wincmd w'

    if !in_tagbar
        execute 'wincmd p'
    endif
endfunction

" s:MapKeys() {{{2
function! s:MapKeys()
    nnoremap <script> <silent> <buffer> <CR>    :call <SID>JumpToTag(0)<CR>
    nnoremap <script> <silent> <buffer> <2-LeftMouse>
                                              \ :call <SID>JumpToTag(0)<CR>
    nnoremap <script> <silent> <buffer> p       :call <SID>JumpToTag(1)<CR>
    nnoremap <script> <silent> <buffer> <LeftRelease>
                \ <LeftRelease>:call <SID>CheckMouseClick()<CR>
    nnoremap <script> <silent> <buffer> <Space> :call <SID>ShowPrototype()<CR>

    nnoremap <script> <silent> <buffer> +        :call <SID>OpenFold()<CR>
    nnoremap <script> <silent> <buffer> <kPlus>  :call <SID>OpenFold()<CR>
    nnoremap <script> <silent> <buffer> zo       :call <SID>OpenFold()<CR>
    nnoremap <script> <silent> <buffer> -        :call <SID>CloseFold()<CR>
    nnoremap <script> <silent> <buffer> <kMinus> :call <SID>CloseFold()<CR>
    nnoremap <script> <silent> <buffer> zc       :call <SID>CloseFold()<CR>
    nnoremap <script> <silent> <buffer> o        :call <SID>ToggleFold()<CR>
    nnoremap <script> <silent> <buffer> za       :call <SID>ToggleFold()<CR>

    nnoremap <script> <silent> <buffer> *    :call <SID>SetFoldLevel(99)<CR>
    nnoremap <script> <silent> <buffer> <kMultiply>
                                           \ :call <SID>SetFoldLevel(99)<CR>
    nnoremap <script> <silent> <buffer> zR   :call <SID>SetFoldLevel(99)<CR>
    nnoremap <script> <silent> <buffer> =    :call <SID>SetFoldLevel(0)<CR>
    nnoremap <script> <silent> <buffer> zM   :call <SID>SetFoldLevel(0)<CR>

    nnoremap <script> <silent> <buffer> <C-N>
                                        \ :call <SID>GotoNextToplevelTag(1)<CR>
    nnoremap <script> <silent> <buffer> <C-P>
                                        \ :call <SID>GotoNextToplevelTag(-1)<CR>

    nnoremap <script> <silent> <buffer> s    :call <SID>ToggleSort()<CR>
    nnoremap <script> <silent> <buffer> x    :call <SID>ZoomWindow()<CR>
    nnoremap <script> <silent> <buffer> q    :call <SID>CloseWindow()<CR>
    nnoremap <script> <silent> <buffer> <F1> :call <SID>ToggleHelp()<CR>
endfunction

" s:CreateAutocommands() {{{2
function! s:CreateAutocommands()
    augroup TagbarAutoCmds
        autocmd!
        autocmd BufEnter   __Tagbar__ nested call s:QuitIfOnlyWindow()
        autocmd BufUnload  __Tagbar__ call s:CleanUp()
        autocmd CursorHold __Tagbar__ call s:ShowPrototype()

        autocmd BufEnter,CursorHold * call
                    \ s:AutoUpdate(fnamemodify(expand('<afile>'), ':p'))
        autocmd BufDelete * call
                    \ s:CleanupFileinfo(fnamemodify(expand('<afile>'), ':p'))
    augroup END

    let s:autocommands_done = 1
endfunction

" s:CheckForExCtags() {{{2
" Test whether the ctags binary is actually Exuberant Ctags and not GNU ctags
" (or something else)
function! s:CheckForExCtags()
    let ctags_cmd = s:EscapeCtagsCmd(g:tagbar_ctags_bin, '--version')
    if ctags_cmd == ''
        return
    endif

    let ctags_output = s:ExecuteCtags(ctags_cmd)

    if v:shell_error || ctags_output !~# 'Exuberant Ctags'
        echoerr 'Tagbar: Ctags doesn''t seem to be Exuberant Ctags!'
        echomsg 'GNU ctags will NOT WORK.'
              \ 'Please download Exuberant Ctags from ctags.sourceforge.net'
              \ 'and install it in a directory in your $PATH'
              \ 'or set g:tagbar_ctags_bin.'
        echomsg 'Executed command: "' . ctags_cmd . '"'
        if !empty(ctags_output)
            echomsg 'Command output:'
            for line in split(ctags_output, '\n')
                echomsg line
            endfor
        endif
        return 0
    elseif !s:CheckExCtagsVersion(ctags_output)
        echoerr 'Tagbar: Exuberant Ctags is too old!'
        echomsg 'You need at least version 5.5 for Tagbar to work.'
              \ 'Please download a newer version from ctags.sourceforge.net.'
        echomsg 'Executed command: "' . ctags_cmd . '"'
        if !empty(ctags_output)
            echomsg 'Command output:'
            for line in split(ctags_output, '\n')
                echomsg line
            endfor
        endif
        return 0
    else
        let s:checked_ctags = 1
        return 1
    endif
endfunction

" s:CheckExCtagsVersion() {{{2
function! s:CheckExCtagsVersion(output)
    let matchlist = matchlist(a:output, '\vExuberant Ctags (\d+)\.(\d+)')
    let major     = matchlist[1]
    let minor     = matchlist[2]

    return major >= 6 || (major == 5 && minor >= 5)
endfunction

" Prototypes {{{1
" Base tag {{{2
let s:BaseTag = {}

" s:BaseTag._init() {{{3
function! s:BaseTag._init(name) dict
    let self.name        = a:name
    let self.fields      = {}
    let self.fields.line = 0
    let self.path        = ''
    let self.fullpath    = a:name
    let self.depth       = 0
    let self.parent      = {}
    let self.tline       = -1
    let self.fileinfo    = {}
endfunction

" s:BaseTag.isNormalTag() {{{3
function! s:BaseTag.isNormalTag() dict
    return 0
endfunction

" s:BaseTag.isPseudoTag() {{{3
function! s:BaseTag.isPseudoTag() dict
    return 0
endfunction

" s:BaseTag.isKindheader() {{{3
function! s:BaseTag.isKindheader() dict
    return 0
endfunction

" s:BaseTag.getPrototype() {{{3
function! s:BaseTag.getPrototype() dict
    return ''
endfunction

" s:BaseTag._getPrefix() {{{3
function! s:BaseTag._getPrefix() dict
    let fileinfo = self.fileinfo

    if has_key(self, 'children') && !empty(self.children)
        if fileinfo.tagfolds[self.fields.kind][self.fullpath]
            let prefix = s:icon_closed
        else
            let prefix = s:icon_open
        endif
    else
        let prefix = ' '
    endif
    if has_key(self.fields, 'access')
        let prefix .= get(s:access_symbols, self.fields.access, ' ')
    else
        let prefix .= ' '
    endif

    return prefix
endfunction

" s:BaseTag.initFoldState() {{{3
function! s:BaseTag.initFoldState() dict
    let fileinfo = self.fileinfo

    if s:known_files.has(fileinfo.fpath) &&
     \ has_key(fileinfo._tagfolds_old[self.fields.kind], self.fullpath)
        " The file has been updated and the tag was there before, so copy its
        " old fold state
        let fileinfo.tagfolds[self.fields.kind][self.fullpath] =
                    \ fileinfo._tagfolds_old[self.fields.kind][self.fullpath]
    elseif self.depth >= fileinfo.foldlevel
        let fileinfo.tagfolds[self.fields.kind][self.fullpath] = 1
    else
        let fileinfo.tagfolds[self.fields.kind][self.fullpath] =
                    \ fileinfo.kindfolds[self.fields.kind]
    endif
endfunction

" s:BaseTag.getClosedParentTline() {{{3
function! s:BaseTag.getClosedParentTline() dict
    let tagline = self.tline
    let fileinfo = self.fileinfo

    let parent = self.parent
    while !empty(parent)
        if parent.isFolded()
            let tagline = parent.tline
            break
        endif
        let parent = parent.parent
    endwhile

    return tagline
endfunction

" s:BaseTag.isFoldable() {{{3
function! s:BaseTag.isFoldable() dict
    return has_key(self, 'children') && !empty(self.children)
endfunction

" s:BaseTag.isFolded() {{{3
function! s:BaseTag.isFolded() dict
    return self.fileinfo.tagfolds[self.fields.kind][self.fullpath]
endfunction

" s:BaseTag.openFold() {{{3
function! s:BaseTag.openFold() dict
    if self.isFoldable()
        let self.fileinfo.tagfolds[self.fields.kind][self.fullpath] = 0
    endif
endfunction

" s:BaseTag.closeFold() {{{3
function! s:BaseTag.closeFold() dict
    let newline = line('.')

    if !empty(self.parent) && self.parent.isKindheader()
        " Tag is child of generic 'kind'
        call self.parent.closeFold()
        let newline = self.parent.tline
    elseif self.isFoldable() && !self.isFolded()
        " Tag is parent of a scope and is not folded
        let self.fileinfo.tagfolds[self.fields.kind][self.fullpath] = 1
    elseif !empty(self.parent)
        " Tag is normal child, so close parent
        let parent = self.parent
        let self.fileinfo.tagfolds[parent.fields.kind][parent.fullpath] = 1
        let newline = parent.tline
    endif

    return newline
endfunction

" s:BaseTag.setFolded() {{{3
function! s:BaseTag.setFolded(folded) dict
    let self.fileinfo.tagfolds[self.fields.kind][self.fullpath] = a:folded
endfunction

" s:BaseTag.openParents() {{{3
function! s:BaseTag.openParents() dict
    let parent = self.parent

    while !empty(parent)
        call parent.openFold()
        let parent = parent.parent
    endwhile
endfunction

" Normal tag {{{2
let s:NormalTag = copy(s:BaseTag)

" s:NormalTag.New() {{{3
function! s:NormalTag.New(name) dict
    let newobj = copy(self)

    call newobj._init(a:name)

    return newobj
endfunction

" s:NormalTag.isNormalTag() {{{3
function! s:NormalTag.isNormalTag() dict
    return 1
endfunction

" s:NormalTag.str() {{{3
function! s:NormalTag.str() dict
    let fileinfo = self.fileinfo
    let typeinfo = s:known_types[fileinfo.ftype]

    let suffix = get(self.fields, 'signature', '')
    if has_key(self.fields, 'type')
        let suffix .= ' : ' . self.fields.type
    elseif has_key(typeinfo, 'kind2scope') &&
         \ has_key(typeinfo.kind2scope, self.fields.kind)
        let suffix .= ' : ' . typeinfo.kind2scope[self.fields.kind]
    endif

    return self._getPrefix() . self.name . suffix . "\n"
endfunction

" s:NormalTag.getPrototype() {{{3
function! s:NormalTag.getPrototype() dict
    return self.prototype
endfunction

" Pseudo tag {{{2
let s:PseudoTag = copy(s:BaseTag)

" s:PseudoTag.New() {{{3
function! s:PseudoTag.New(name) dict
    let newobj = copy(self)

    call newobj._init(a:name)

    return newobj
endfunction

" s:PseudoTag.isPseudoTag() {{{3
function! s:PseudoTag.isPseudoTag() dict
    return 1
endfunction

" s:PseudoTag.str() {{{3
function! s:PseudoTag.str() dict
    let fileinfo = self.fileinfo
    let typeinfo = s:known_types[fileinfo.ftype]

    let suffix = get(self.fields, 'signature', '')
    if has_key(typeinfo.kind2scope, self.fields.kind)
        let suffix .= ' : ' . typeinfo.kind2scope[self.fields.kind]
    endif

    return self._getPrefix() . self.name . '*' . suffix
endfunction

" Kind header {{{2
let s:KindheaderTag = copy(s:BaseTag)

" s:KindheaderTag.New() {{{3
function! s:KindheaderTag.New(name) dict
    let newobj = copy(self)

    call newobj._init(a:name)

    return newobj
endfunction

" s:KindheaderTag.isKindheader() {{{3
function! s:KindheaderTag.isKindheader() dict
    return 1
endfunction

" s:KindheaderTag.getPrototype() {{{3
function! s:KindheaderTag.getPrototype() dict
    return self.name . ': ' .
         \ self.numtags . ' ' . (self.numtags > 1 ? 'tags' : 'tag')
endfunction

" s:KindheaderTag.isFoldable() {{{3
function! s:KindheaderTag.isFoldable() dict
    return 1
endfunction

" s:KindheaderTag.isFolded() {{{3
function! s:KindheaderTag.isFolded() dict
    return self.fileinfo.kindfolds[self.short]
endfunction

" s:KindheaderTag.openFold() {{{3
function! s:KindheaderTag.openFold() dict
    let self.fileinfo.kindfolds[self.short] = 0
endfunction

" s:KindheaderTag.closeFold() {{{3
function! s:KindheaderTag.closeFold() dict
    let self.fileinfo.kindfolds[self.short] = 1
    return line('.')
endfunction

" s:KindheaderTag.toggleFold() {{{3
function! s:KindheaderTag.toggleFold() dict
    let fileinfo = s:known_files.getCurrent()

    let fileinfo.kindfolds[self.short] = !fileinfo.kindfolds[self.short]
endfunction

" File info {{{2
let s:FileInfo = {}

" s:FileInfo.New() {{{3
function! s:FileInfo.New(fname, ftype) dict
    let newobj = copy(self)

    " The complete file path
    let newobj.fpath = a:fname

    " File modification time
    let newobj.mtime = getftime(a:fname)

    " The vim file type
    let newobj.ftype = a:ftype

    " List of the tags that are present in the file, sorted according to the
    " value of 'g:tagbar_sort'
    let newobj.tags = []

    " Dictionary of the tags, indexed by line number in the file
    let newobj.fline = {}

    " Dictionary of the tags, indexed by line number in the tagbar
    let newobj.tline = {}

    " Dictionary of the folding state of 'kind's, indexed by short name
    let newobj.kindfolds = {}
    let typeinfo = s:known_types[a:ftype]
    " copy the default fold state from the type info
    for kind in typeinfo.kinds
        let newobj.kindfolds[kind.short] =
                    \ g:tagbar_foldlevel == 0 ? 1 : kind.fold
    endfor

    " Dictionary of dictionaries of the folding state of individual tags,
    " indexed by kind and full path
    let newobj.tagfolds = {}
    for kind in typeinfo.kinds
        let newobj.tagfolds[kind.short] = {}
    endfor

    " The current foldlevel of the file
    let newobj.foldlevel = g:tagbar_foldlevel

    return newobj
endfunction

" s:FileInfo.reset() {{{3
" Reset stuff that gets regenerated while processing a file and save the old
" tag folds
function! s:FileInfo.reset() dict
    let self.mtime = getftime(self.fpath)
    let self.tags  = []
    let self.fline = {}
    let self.tline = {}

    let self._tagfolds_old = self.tagfolds
    let self.tagfolds = {}

    let typeinfo = s:known_types[self.ftype]
    for kind in typeinfo.kinds
        let self.tagfolds[kind.short] = {}
    endfor
endfunction

" s:FileInfo.clearOldFolds() {{{3
function! s:FileInfo.clearOldFolds() dict
    if exists('self._tagfolds_old')
        unlet self._tagfolds_old
    endif
endfunction

" s:FileInfo.sortTags() {{{3
function! s:FileInfo.sortTags() dict
    if has_key(s:compare_typeinfo, 'sort')
        if s:compare_typeinfo.sort
            call s:SortTags(self.tags, 's:CompareByKind')
        else
            call s:SortTags(self.tags, 's:CompareByLine')
        endif
    elseif g:tagbar_sort
        call s:SortTags(self.tags, 's:CompareByKind')
    else
        call s:SortTags(self.tags, 's:CompareByLine')
    endif
endfunction

" s:FileInfo.openKindFold() {{{3
function! s:FileInfo.openKindFold(kind) dict
    let self.kindfolds[a:kind.short] = 0
endfunction

" s:FileInfo.closeKindFold() {{{3
function! s:FileInfo.closeKindFold(kind) dict
    let self.kindfolds[a:kind.short] = 1
endfunction

" Known files {{{2
let s:known_files = {
    \ '_current' : {},
    \ '_files'   : {}
\ }

" s:known_files.getCurrent() {{{3
function! s:known_files.getCurrent() dict
    return self._current
endfunction

" s:known_files.setCurrent() {{{3
function! s:known_files.setCurrent(fileinfo) dict
    let self._current = a:fileinfo
endfunction

" s:known_files.get() {{{3
function! s:known_files.get(fname) dict
    return get(self._files, a:fname, {})
endfunction

" s:known_files.put() {{{3
" Optional second argument is the filename
function! s:known_files.put(fileinfo, ...) dict
    if a:0 == 1
        let self._files[a:1] = a:fileinfo
    else
        let fname = a:fileinfo.fpath
        let self._files[fname] = a:fileinfo
    endif
endfunction

" s:known_files.has() {{{3
function! s:known_files.has(fname) dict
    return has_key(self._files, a:fname)
endfunction

" s:known_files.rm() {{{3
function! s:known_files.rm(fname) dict
    if s:known_files.has(a:fname)
        call remove(self._files, a:fname)
    endif
endfunction

" Window management {{{1
" s:ToggleWindow() {{{2
function! s:ToggleWindow()
    let tagbarwinnr = bufwinnr("__Tagbar__")
    if tagbarwinnr != -1
        call s:CloseWindow()
        return
    endif

    call s:OpenWindow(0)
endfunction

" s:OpenWindow() {{{2
function! s:OpenWindow(autoclose)
    " If the tagbar window is already open jump to it
    let tagbarwinnr = bufwinnr('__Tagbar__')
    if tagbarwinnr != -1
        if winnr() != tagbarwinnr
            execute tagbarwinnr . 'wincmd w'
        endif
        return
    endif

    if !s:type_init_done
        call s:InitTypes()
    endif

    if !s:checked_ctags
        if !s:CheckForExCtags()
            return
        endif
    endif

    " Expand the Vim window to accomodate for the Tagbar window if requested
    if g:tagbar_expand && !s:window_expanded && has('gui_running')
        let &columns += g:tagbar_width + 1
        let s:window_expanded = 1
    endif

    let openpos = g:tagbar_left ? 'topleft vertical ' : 'botright vertical '
    exe 'silent keepalt ' . openpos . g:tagbar_width . 'split ' . '__Tagbar__'

    call s:InitWindow(a:autoclose)

    execute 'wincmd p'

    " Jump back to the tagbar window if autoclose or autofocus is set. Can't
    " just stay in it since it wouldn't trigger the update event
    if g:tagbar_autoclose || a:autoclose || g:tagbar_autofocus
        let tagbarwinnr = bufwinnr('__Tagbar__')
        execute tagbarwinnr . 'wincmd w'
    endif
endfunction

" s:InitWindow() {{{2
function! s:InitWindow(autoclose)
    setlocal noreadonly " in case the "view" mode is used
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal nobuflisted
    setlocal nomodifiable
    setlocal filetype=tagbar
    setlocal nolist
    setlocal nonumber
    setlocal nowrap
    setlocal winfixwidth
    setlocal textwidth=0

    if exists('+relativenumber')
        setlocal norelativenumber
    endif

    setlocal nofoldenable
    " Reset fold settings in case a plugin set them globally to something
    " expensive. Apparently 'foldexpr' gets executed even if 'foldenable' is
    " off, and then for every appended line (like with :put).
    setlocal foldmethod&
    setlocal foldexpr&

    setlocal statusline=%!TagbarGenerateStatusline()

    " Script-local variable needed since compare functions can't
    " take extra arguments
    let s:compare_typeinfo = {}

    let s:is_maximized = 0
    let s:short_help   = 1

    let w:autoclose = a:autoclose

    if has('balloon_eval')
        setlocal balloonexpr=TagbarBalloonExpr()
        set ballooneval
    endif

    let cpoptions_save = &cpoptions
    set cpoptions&vim

    if !hasmapto('JumpToTag', 'n')
        call s:MapKeys()
    endif

    if !s:autocommands_done
        call s:CreateAutocommands()
    endif

    let &cpoptions = cpoptions_save
endfunction

" s:CloseWindow() {{{2
function! s:CloseWindow()
    let tagbarwinnr = bufwinnr('__Tagbar__')
    if tagbarwinnr == -1
        return
    endif

    let tagbarbufnr = winbufnr(tagbarwinnr)

    if winnr() == tagbarwinnr
        if winbufnr(2) != -1
            " Other windows are open, only close the tagbar one
            close
        endif
    else
        " Go to the tagbar window, close it and then come back to the
        " original window
        let curbufnr = bufnr('%')
        execute tagbarwinnr . 'wincmd w'
        close
        " Need to jump back to the original window only if we are not
        " already in that window
        let winnum = bufwinnr(curbufnr)
        if winnr() != winnum
            exe winnum . 'wincmd w'
        endif
    endif

    " If the Vim window has been expanded, and Tagbar is not open in any other
    " tabpages, shrink the window again
    if s:window_expanded
        let tablist = []
        for i in range(tabpagenr('$'))
            call extend(tablist, tabpagebuflist(i + 1))
        endfor

        if index(tablist, tagbarbufnr) == -1
            let &columns -= g:tagbar_width + 1
            let s:window_expanded = 0
        endif
    endif
endfunction

" s:ZoomWindow() {{{2
function! s:ZoomWindow()
    if s:is_maximized
        execute 'vert resize ' . g:tagbar_width
        let s:is_maximized = 0
    else
        vert resize
        let s:is_maximized = 1
    endif
endfunction

" Tag processing {{{1
" s:ProcessFile() {{{2
" Execute ctags and put the information into a 'FileInfo' object
function! s:ProcessFile(fname, ftype)
    if !s:IsValidFile(a:fname, a:ftype)
        return
    endif

    let ctags_output = s:ExecuteCtagsOnFile(a:fname, a:ftype)

    if ctags_output == -1
        " put an empty entry into known_files so the error message is only
        " shown once
        call s:known_files.put({}, a:fname)
        return
    elseif ctags_output == ''
        return
    endif

    " If the file has only been updated preserve the fold states, otherwise
    " create a new entry
    if s:known_files.has(a:fname)
        let fileinfo = s:known_files.get(a:fname)
        call fileinfo.reset()
    else
        let fileinfo = s:FileInfo.New(a:fname, a:ftype)
    endif

    let typeinfo = s:known_types[a:ftype]

    " Parse the ctags output lines
    let rawtaglist = split(ctags_output, '\n\+')
    for line in rawtaglist
        let parts = split(line, ';"')
        if len(parts) == 2 " Is a valid tag line
            let taginfo = s:ParseTagline(parts[0], parts[1], typeinfo, fileinfo)
            let fileinfo.fline[taginfo.fields.line] = taginfo
            call add(fileinfo.tags, taginfo)
        endif
    endfor

    " Process scoped tags
    let processedtags = []
    if has_key(typeinfo, 'kind2scope')
        let scopedtags = []
        let is_scoped = 'has_key(typeinfo.kind2scope, v:val.fields.kind) ||
                       \ has_key(v:val, "scope")'
        let scopedtags += filter(copy(fileinfo.tags), is_scoped)
        call filter(fileinfo.tags, '!(' . is_scoped . ')')

        call s:AddScopedTags(scopedtags, processedtags, {}, 0,
                           \ typeinfo, fileinfo)

        if !empty(scopedtags)
            echoerr 'Tagbar: ''scopedtags'' not empty after processing,'
                  \ 'this should never happen!'
                  \ 'Please contact the script maintainer with an example.'
        endif
    endif

    " Create a placeholder tag for the 'kind' header for folding purposes
    for kind in typeinfo.kinds
        let curtags = filter(copy(fileinfo.tags),
                           \ 'v:val.fields.kind ==# kind.short')

        if empty(curtags)
            continue
        endif

        let kindtag          = s:KindheaderTag.New(kind.long)
        let kindtag.short    = kind.short
        let kindtag.numtags  = len(curtags)
        let kindtag.fileinfo = fileinfo

        for tag in curtags
            let tag.parent = kindtag
        endfor
    endfor

    if !empty(processedtags)
        call extend(fileinfo.tags, processedtags)
    endif

    " Clear old folding information from previous file version
    call fileinfo.clearOldFolds()

    " Sort the tags
    let s:compare_typeinfo = typeinfo
    call fileinfo.sortTags()

    call s:known_files.put(fileinfo)
endfunction

" s:ExecuteCtagsOnFile() {{{2
function! s:ExecuteCtagsOnFile(fname, ftype)
    let typeinfo = s:known_types[a:ftype]

    if has_key(typeinfo, 'ctagsargs')
        let ctags_args = ' ' . typeinfo.ctagsargs . ' '
    else
        let ctags_args  = ' -f - '
        let ctags_args .= ' --format=2 '
        let ctags_args .= ' --excmd=pattern '
        let ctags_args .= ' --fields=nksSa '
        let ctags_args .= ' --extra= '
        let ctags_args .= ' --sort=yes '

        " Include extra type definitions
        if has_key(typeinfo, 'deffile')
            let ctags_args .= ' --options=' . typeinfo.deffile . ' '
        endif

        let ctags_type = typeinfo.ctagstype

        let ctags_kinds = ''
        for kind in typeinfo.kinds
            let ctags_kinds .= kind.short
        endfor

        let ctags_args .= ' --language-force=' . ctags_type .
                        \ ' --' . ctags_type . '-kinds=' . ctags_kinds . ' '
    endif

    if has_key(typeinfo, 'ctagsbin')
        let ctags_bin = expand(typeinfo.ctagsbin)
    else
        let ctags_bin = g:tagbar_ctags_bin
    endif

    let ctags_cmd = s:EscapeCtagsCmd(ctags_bin, ctags_args, a:fname)
    if ctags_cmd == ''
        return ''
    endif

    let ctags_output = s:ExecuteCtags(ctags_cmd)

    if v:shell_error || ctags_output =~ 'Warning: cannot open source file'
        echoerr 'Tagbar: Could not execute ctags for ' . a:fname . '!'
        echomsg 'Executed command: "' . ctags_cmd . '"'
        if !empty(ctags_output)
            echomsg 'Command output:'
            for line in split(ctags_output, '\n')
                echomsg line
            endfor
        endif
        return -1
    endif

    return ctags_output
endfunction

" s:ParseTagline() {{{2
" Structure of a tag line:
" tagname<TAB>filename<TAB>expattern;"fields
" fields: <TAB>name:value
" fields that are always present: kind, line
function! s:ParseTagline(part1, part2, typeinfo, fileinfo)
    let basic_info  = split(a:part1, '\t')

    let taginfo      = s:NormalTag.New(basic_info[0])
    let taginfo.file = basic_info[1]

    " the pattern can contain tabs and thus may have been split up, so join
    " the rest of the items together again
    let pattern = join(basic_info[2:], "\t")
    let start   = 2 " skip the slash and the ^
    let end     = strlen(pattern) - 1
    if pattern[end - 1] ==# '$'
        let end -= 1
        let dollar = '\$'
    else
        let dollar = ''
    endif
    let pattern           = strpart(pattern, start, end - start)
    let taginfo.pattern   = '\V\^' . pattern . dollar
    let prototype         = substitute(pattern,   '^[[:space:]]\+', '', '')
    let prototype         = substitute(prototype, '[[:space:]]\+$', '', '')
    let taginfo.prototype = prototype

    let fields = split(a:part2, '\t')
    let taginfo.fields.kind = remove(fields, 0)
    for field in fields
        " can't use split() since the value can contain ':'
        let delimit             = stridx(field, ':')
        let key                 = strpart(field, 0, delimit)
        let val                 = strpart(field, delimit + 1)
        let taginfo.fields[key] = val
    endfor
    " Needed for jsctags
    if has_key(taginfo.fields, 'lineno')
        let taginfo.fields.line = taginfo.fields.lineno
    endif

    " Make some information easier accessible
    if has_key(a:typeinfo, 'scope2kind')
        for scope in keys(a:typeinfo.scope2kind)
            if has_key(taginfo.fields, scope)
                let taginfo.scope = scope
                let taginfo.path  = taginfo.fields[scope]

                let taginfo.fullpath = taginfo.path . a:typeinfo.sro .
                                     \ taginfo.name
                break
            endif
        endfor
        let taginfo.depth = len(split(taginfo.path, '\V' . a:typeinfo.sro))
    endif

    let taginfo.fileinfo = a:fileinfo

    " Needed for folding
    call taginfo.initFoldState()

    return taginfo
endfunction

" s:AddScopedTags() {{{2
" Recursively process tags. Unfortunately there is a problem: not all tags in
" a hierarchy are actually there. For example, in C++ a class can be defined
" in a header file and implemented in a .cpp file (so the class itself doesn't
" appear in the .cpp file and thus doesn't generate a tag). Another example
" are anonymous structures like namespaces, structs, enums, and unions, that
" also don't get a tag themselves. These tags are thus called 'pseudo-tags' in
" Tagbar. Properly parsing them is quite tricky, so try not to think about it
" too much.
function! s:AddScopedTags(tags, processedtags, parent, depth,
                        \ typeinfo, fileinfo)
    if !empty(a:parent)
        let curpath = a:parent.fullpath
        let pscope  = a:typeinfo.kind2scope[a:parent.fields.kind]
    else
        let curpath = ''
        let pscope  = ''
    endif

    let is_cur_tag = 'v:val.depth == a:depth'

    if !empty(curpath)
        " Check whether the tag is either a direct child at the current depth
        " or at least a proper grandchild with pseudo-tags in between. If it
        " is a direct child also check for matching scope.
        let is_cur_tag .= ' &&
        \ (v:val.path ==# curpath ||
         \ match(v:val.path, ''\V\^\C'' . curpath . a:typeinfo.sro) == 0) &&
        \ (v:val.path ==# curpath ? (v:val.scope ==# pscope) : 1)'
    endif

    let curtags = filter(copy(a:tags), is_cur_tag)

    if !empty(curtags)
        call filter(a:tags, '!(' . is_cur_tag . ')')

        let realtags   = []
        let pseudotags = []

        while !empty(curtags)
            let tag = remove(curtags, 0)

            if tag.path != curpath
                " tag is child of a pseudo-tag, so create a new pseudo-tag and
                " add all its children to it
                let pseudotag = s:ProcessPseudoTag(curtags, tag, a:parent,
                                                 \ a:typeinfo, a:fileinfo)

                call add(pseudotags, pseudotag)
            else
                call add(realtags, tag)
            endif
        endwhile

        " Recursively add the children of the tags on the current level
        for tag in realtags
            let tag.parent = a:parent

            if !has_key(a:typeinfo.kind2scope, tag.fields.kind)
                continue
            endif

            if !has_key(tag, 'children')
                let tag.children = []
            endif

            call s:AddScopedTags(a:tags, tag.children, tag, a:depth + 1,
                               \ a:typeinfo, a:fileinfo)
        endfor
        call extend(a:processedtags, realtags)

        " Recursively add the children of the tags that are children of the
        " pseudo-tags on the current level
        for tag in pseudotags
            call s:ProcessPseudoChildren(a:tags, tag, a:depth, a:typeinfo,
                                       \ a:fileinfo)
        endfor
        call extend(a:processedtags, pseudotags)
    endif

    " Now we have to check if there are any pseudo-tags at the current level
    " so we have to check for real tags at a lower level, i.e. grandchildren
    let is_grandchild = 'v:val.depth > a:depth'

    if !empty(curpath)
        let is_grandchild .=
        \ ' && match(v:val.path, ''\V\^\C'' . curpath . a:typeinfo.sro) == 0'
    endif

    let grandchildren = filter(copy(a:tags), is_grandchild)

    if !empty(grandchildren)
        call s:AddScopedTags(a:tags, a:processedtags, a:parent, a:depth + 1,
                           \ a:typeinfo, a:fileinfo)
    endif
endfunction

" s:ProcessPseudoTag() {{{2
function! s:ProcessPseudoTag(curtags, tag, parent, typeinfo, fileinfo)
    let curpath = !empty(a:parent) ? a:parent.fullpath : ''

    let pseudoname = substitute(a:tag.path, curpath, '', '')
    let pseudoname = substitute(pseudoname, '\V\^' . a:typeinfo.sro, '', '')
    let pseudotag  = s:CreatePseudoTag(pseudoname, a:parent, a:tag.scope,
                                     \ a:typeinfo, a:fileinfo)
    let pseudotag.children = [a:tag]

    " get all the other (direct) children of the current pseudo-tag
    let ispseudochild = 'v:val.path ==# a:tag.path && v:val.scope ==# a:tag.scope'
    let pseudochildren = filter(copy(a:curtags), ispseudochild)
    if !empty(pseudochildren)
        call filter(a:curtags, '!(' . ispseudochild . ')')
        call extend(pseudotag.children, pseudochildren)
    endif

    return pseudotag
endfunction

" s:ProcessPseudoChildren() {{{2
function! s:ProcessPseudoChildren(tags, tag, depth, typeinfo, fileinfo)
    for childtag in a:tag.children
        let childtag.parent = a:tag

        if !has_key(a:typeinfo.kind2scope, childtag.fields.kind)
            continue
        endif

        if !has_key(childtag, 'children')
            let childtag.children = []
        endif

        call s:AddScopedTags(a:tags, childtag.children, childtag, a:depth + 1,
                           \ a:typeinfo, a:fileinfo)
    endfor

    let is_grandchild = 'v:val.depth > a:depth &&
                       \ match(v:val.path, ''^\C'' . a:tag.fullpath) == 0'
    let grandchildren = filter(copy(a:tags), is_grandchild)
    if !empty(grandchildren)
        call s:AddScopedTags(a:tags, a:tag.children, a:tag, a:depth + 1,
                           \ a:typeinfo, a:fileinfo)
    endif
endfunction

" s:CreatePseudoTag() {{{2
function! s:CreatePseudoTag(name, parent, scope, typeinfo, fileinfo)
    if !empty(a:parent)
        let curpath = a:parent.fullpath
        let pscope  = a:typeinfo.kind2scope[a:parent.fields.kind]
    else
        let curpath = ''
        let pscope  = ''
    endif

    let pseudotag             = s:PseudoTag.New(a:name)
    let pseudotag.fields.kind = a:typeinfo.scope2kind[a:scope]

    let parentscope = substitute(curpath, a:name . '$', '', '')
    let parentscope = substitute(parentscope,
                               \ '\V\^' . a:typeinfo.sro . '\$', '', '')

    if pscope != ''
        let pseudotag.fields[pscope] = parentscope
        let pseudotag.scope    = pscope
        let pseudotag.path     = parentscope
        let pseudotag.fullpath =
                    \ pseudotag.path . a:typeinfo.sro . pseudotag.name
    endif
    let pseudotag.depth = len(split(pseudotag.path, '\V' . a:typeinfo.sro))

    let pseudotag.parent = a:parent

    let pseudotag.fileinfo = a:fileinfo

    call pseudotag.initFoldState()

    return pseudotag
endfunction

" Sorting {{{1
" s:SortTags() {{{2
function! s:SortTags(tags, comparemethod)
    call sort(a:tags, a:comparemethod)

    for tag in a:tags
        if has_key(tag, 'children')
            call s:SortTags(tag.children, a:comparemethod)
        endif
    endfor
endfunction

" s:CompareByKind() {{{2
function! s:CompareByKind(tag1, tag2)
    let typeinfo = s:compare_typeinfo

    if typeinfo.kinddict[a:tag1.fields.kind] <#
     \ typeinfo.kinddict[a:tag2.fields.kind]
        return -1
    elseif typeinfo.kinddict[a:tag1.fields.kind] >#
         \ typeinfo.kinddict[a:tag2.fields.kind]
        return 1
    else
        " Ignore '~' prefix for C++ destructors to sort them directly under
        " the constructors
        if a:tag1.name[0] ==# '~'
            let name1 = a:tag1.name[1:]
        else
            let name1 = a:tag1.name
        endif
        if a:tag2.name[0] ==# '~'
            let name2 = a:tag2.name[1:]
        else
            let name2 = a:tag2.name
        endif

        if name1 <=# name2
            return -1
        else
            return 1
        endif
    endif
endfunction

" s:CompareByLine() {{{2
function! s:CompareByLine(tag1, tag2)
    return a:tag1.fields.line - a:tag2.fields.line
endfunction

" s:ToggleSort() {{{2
function! s:ToggleSort()
    let fileinfo = s:known_files.getCurrent()
    if empty(fileinfo)
        return
    endif

    let curline = line('.')

    match none

    let s:compare_typeinfo = s:known_types[fileinfo.ftype]

    if has_key(s:compare_typeinfo, 'sort')
        let s:compare_typeinfo.sort = !s:compare_typeinfo.sort
    else
        let g:tagbar_sort = !g:tagbar_sort
    endif

    call fileinfo.sortTags()

    call s:RenderContent()

    execute curline
endfunction

" Display {{{1
" s:RenderContent() {{{2
function! s:RenderContent(...)
    if a:0 == 1
        let fileinfo = a:1
    else
        let fileinfo = s:known_files.getCurrent()
    endif

    if empty(fileinfo)
        return
    endif

    let tagbarwinnr = bufwinnr('__Tagbar__')

    if &filetype == 'tagbar'
        let in_tagbar = 1
    else
        let in_tagbar = 0
        let prevwinnr = winnr()
        execute tagbarwinnr . 'wincmd w'
    endif

    if !empty(s:known_files.getCurrent()) &&
     \ fileinfo.fpath ==# s:known_files.getCurrent().fpath
        " We're redisplaying the same file, so save the view
        let saveline = line('.')
        let savecol  = col('.')
        let topline  = line('w0')
    endif

    let lazyredraw_save = &lazyredraw
    set lazyredraw
    let eventignore_save = &eventignore
    set eventignore=all

    setlocal modifiable

    silent %delete _

    call s:PrintHelp()

    let typeinfo = s:known_types[fileinfo.ftype]

    " Print tags
    call s:PrintKinds(typeinfo, fileinfo)

    " Delete empty lines at the end of the buffer
    for linenr in range(line('$'), 1, -1)
        if getline(linenr) =~ '^$'
            execute linenr . 'delete _'
        else
            break
        endif
    endfor

    setlocal nomodifiable

    if !empty(s:known_files.getCurrent()) &&
     \ fileinfo.fpath ==# s:known_files.getCurrent().fpath
        let scrolloff_save = &scrolloff
        set scrolloff=0

        call cursor(topline, 1)
        normal! zt
        call cursor(saveline, savecol)

        let &scrolloff = scrolloff_save
    else
        " Make sure as much of the Tagbar content as possible is shown in the
        " window by jumping to the top after drawing
        execute 1
        call winline()
    endif

    let &lazyredraw  = lazyredraw_save
    let &eventignore = eventignore_save

    if !in_tagbar
        execute prevwinnr . 'wincmd w'
    endif
endfunction

" s:PrintKinds() {{{2
function! s:PrintKinds(typeinfo, fileinfo)
    let first_tag = 1

    for kind in a:typeinfo.kinds
        let curtags = filter(copy(a:fileinfo.tags),
                           \ 'v:val.fields.kind ==# kind.short')

        if empty(curtags)
            continue
        endif

        if has_key(a:typeinfo, 'kind2scope') &&
         \ has_key(a:typeinfo.kind2scope, kind.short)
            " Scoped tags
            for tag in curtags
                if g:tagbar_compact && first_tag && s:short_help
                    silent 0put =tag.str()
                else
                    silent  put =tag.str()
                endif

                " Save the current tagbar line in the tag for easy
                " highlighting access
                let curline                   = line('.')
                let tag.tline                 = curline
                let a:fileinfo.tline[curline] = tag

                if tag.isFoldable() && !tag.isFolded()
                    for childtag in tag.children
                        call s:PrintTag(childtag, 1, a:fileinfo, a:typeinfo)
                    endfor
                endif

                if !g:tagbar_compact
                    silent put _
                endif

                let first_tag = 0
            endfor
        else
            " Non-scoped tags
            let kindtag = curtags[0].parent

            if kindtag.isFolded()
                let foldmarker = s:icon_closed
            else
                let foldmarker = s:icon_open
            endif

            if g:tagbar_compact && first_tag && s:short_help
                silent 0put =foldmarker . ' ' . kind.long
            else
                silent  put =foldmarker . ' ' . kind.long
            endif

            let curline                   = line('.')
            let kindtag.tline             = curline
            let a:fileinfo.tline[curline] = kindtag

            if !kindtag.isFolded()
                for tag in curtags
                    let str = tag.str()
                    silent put ='  ' . str

                    " Save the current tagbar line in the tag for easy
                    " highlighting access
                    let curline                   = line('.')
                    let tag.tline                 = curline
                    let a:fileinfo.tline[curline] = tag
                    let tag.depth                 = 1
                endfor
            endif

            if !g:tagbar_compact
                silent put _
            endif

            let first_tag = 0
        endif
    endfor
endfunction

" s:PrintTag() {{{2
function! s:PrintTag(tag, depth, fileinfo, typeinfo)
    " Print tag indented according to depth
    silent put =repeat(' ', a:depth * 2) . a:tag.str()

    " Save the current tagbar line in the tag for easy
    " highlighting access
    let curline                   = line('.')
    let a:tag.tline               = curline
    let a:fileinfo.tline[curline] = a:tag

    " Recursively print children
    if a:tag.isFoldable() && !a:tag.isFolded()
        for childtag in a:tag.children
            call s:PrintTag(childtag, a:depth + 1, a:fileinfo, a:typeinfo)
        endfor
    endif
endfunction

" s:PrintHelp() {{{2
function! s:PrintHelp()
    if !g:tagbar_compact && s:short_help
        silent 0put ='\" Press <F1> for help'
        silent  put _
    elseif !s:short_help
        silent 0put ='\" Tagbar keybindings'
        silent  put ='\"'
        silent  put ='\" --------- General ---------'
        silent  put ='\" <Enter>   : Jump to tag definition'
        silent  put ='\" <Space>   : Display tag prototype'
        silent  put ='\"'
        silent  put ='\" ---------- Folds ----------'
        silent  put ='\" +, zo     : Open fold'
        silent  put ='\" -, zc     : Close fold'
        silent  put ='\" o, za     : Toggle fold'
        silent  put ='\" *, zR     : Open all folds'
        silent  put ='\" =, zM     : Close all folds'
        silent  put ='\"'
        silent  put ='\" ---------- Misc -----------'
        silent  put ='\" s          : Toggle sort'
        silent  put ='\" x          : Zoom window in/out'
        silent  put ='\" q          : Close window'
        silent  put ='\" <F1>       : Remove help'
        silent  put _
    endif
endfunction

" s:RenderKeepView() {{{2
" The gist of this function was taken from NERDTree by Martin Grenfell.
function! s:RenderKeepView(...)
    if a:0 == 1
        let line = a:1
    else
        let line = line('.')
    endif

    let curcol  = col('.')
    let topline = line('w0')

    call s:RenderContent()

    let scrolloff_save = &scrolloff
    set scrolloff=0

    call cursor(topline, 1)
    normal! zt
    call cursor(line, curcol)

    let &scrolloff = scrolloff_save

    redraw
endfunction

" User actions {{{1
" s:HighlightTag() {{{2
function! s:HighlightTag()
    let tagline = 0

    let tag = s:GetNearbyTag()
    if !empty(tag)
        let tagline = tag.tline
    endif

    let eventignore_save = &eventignore
    set eventignore=all

    let tagbarwinnr = bufwinnr('__Tagbar__')
    let prevwinnr   = winnr()
    execute tagbarwinnr . 'wincmd w'

    match none

    " No tag above cursor position so don't do anything
    if tagline == 0
        execute prevwinnr . 'wincmd w'
        let &eventignore = eventignore_save
        redraw
        return
    endif

    if g:tagbar_autoshowtag
        call s:OpenParents(tag)
    endif

    " Check whether the tag is inside a closed fold and highlight the parent
    " instead in that case
    let tagline = tag.getClosedParentTline()

    " Go to the line containing the tag
    execute tagline

    " Make sure the tag is visible in the window
    call winline()

    let foldpat = '[' . s:icon_open . s:icon_closed . ' ]'
    let pattern = '/^\%' . tagline . 'l\s*' . foldpat . '[-+# ]\zs[^( ]\+\ze/'
    execute 'match TagbarHighlight ' . pattern

    execute prevwinnr . 'wincmd w'

    let &eventignore = eventignore_save

    redraw
endfunction

" s:JumpToTag() {{{2
function! s:JumpToTag(stay_in_tagbar)
    let taginfo = s:GetTagInfo(line('.'), 1)

    let autoclose = w:autoclose

    if empty(taginfo) || has_key(taginfo, 'numtags')
        return
    endif

    let tagbarwinnr = winnr()

    " This elaborate construct will try to switch to the correct
    " buffer/window; if the buffer isn't currently shown in a window it will
    " open it in the first window with a non-special buffer in it
    execute 'wincmd p'
    let filebufnr = bufnr(taginfo.fileinfo.fpath)
    if bufnr('%') != filebufnr
        let filewinnr = bufwinnr(filebufnr)
        if filewinnr != -1
            execute filewinnr . 'wincmd w'
        else
            for i in range(1, winnr('$'))
                execute i . 'wincmd w'
                if &buftype == ''
                    execute 'buffer ' . filebufnr
                    break
                endif
            endfor
        endif
        " To make ctrl-w_p work we switch between the Tagbar window and the
        " correct window once
        execute tagbarwinnr . 'wincmd w'
        execute 'wincmd p'
    endif

    " Mark current position so it can be jumped back to
    mark '

    " Jump to the line where the tag is defined. Don't use the search pattern
    " since it doesn't take the scope into account and thus can fail if tags
    " with the same name are defined in different scopes (e.g. classes)
    execute taginfo.fields.line

    " Center the tag in the window
    normal! z.

    if foldclosed('.') != -1
        .foldopen!
    endif

    redraw

    if a:stay_in_tagbar
        call s:HighlightTag()
        execute tagbarwinnr . 'wincmd w'
    elseif g:tagbar_autoclose || autoclose
        call s:CloseWindow()
    else
        call s:HighlightTag()
    endif
endfunction

" s:ShowPrototype() {{{2
function! s:ShowPrototype()
    let taginfo = s:GetTagInfo(line('.'), 1)

    if empty(taginfo)
        return
    endif

    echo taginfo.getPrototype()
endfunction

" s:ToggleHelp() {{{2
function! s:ToggleHelp()
    let s:short_help = !s:short_help

    " Prevent highlighting from being off after adding/removing the help text
    match none

    call s:RenderContent()

    execute 1
    redraw
endfunction

" s:GotoNextToplevelTag() {{{2
function! s:GotoNextToplevelTag(direction)
    let curlinenr = line('.')
    let newlinenr = line('.')

    if a:direction == 1
        let range = range(line('.') + 1, line('$'))
    else
        let range = range(line('.') - 1, 1, -1)
    endif

    for tmplinenr in range
        let taginfo = s:GetTagInfo(tmplinenr, 0)

        if empty(taginfo)
            continue
        elseif empty(taginfo.parent)
            let newlinenr = tmplinenr
            break
        endif
    endfor

    if curlinenr != newlinenr
        execute newlinenr
        call winline()
    endif

    redraw
endfunction

" Folding {{{1
" s:OpenFold() {{{2
function! s:OpenFold()
    let fileinfo = s:known_files.getCurrent()
    if empty(fileinfo)
        return
    endif

    let curline = line('.')

    let tag = s:GetTagInfo(curline, 0)
    if empty(tag)
        return
    endif

    call tag.openFold()

    call s:RenderKeepView()
endfunction

" s:CloseFold() {{{2
function! s:CloseFold()
    let fileinfo = s:known_files.getCurrent()
    if empty(fileinfo)
        return
    endif

    match none

    let curline = line('.')

    let curtag = s:GetTagInfo(curline, 0)
    if empty(curtag)
        return
    endif

    let newline = curtag.closeFold()

    call s:RenderKeepView(newline)
endfunction

" s:ToggleFold() {{{2
function! s:ToggleFold()
    let fileinfo = s:known_files.getCurrent()
    if empty(fileinfo)
        return
    endif

    match none

    let curtag = s:GetTagInfo(line('.'), 0)
    if empty(curtag)
        return
    endif

    let newline = line('.')

    if curtag.isKindheader()
        call curtag.toggleFold()
    elseif curtag.isFoldable()
        if curtag.isFolded()
            call curtag.openFold()
        else
            let newline = curtag.closeFold()
        endif
    else
        let newline = curtag.closeFold()
    endif

    call s:RenderKeepView(newline)
endfunction

" s:SetFoldLevel() {{{2
function! s:SetFoldLevel(level)
    if a:level < 0
        echoerr 'Foldlevel can''t be negative'
        return
    endif

    let fileinfo = s:known_files.getCurrent()
    if empty(fileinfo)
        return
    endif

    call s:SetFoldLevelRecursive(fileinfo, fileinfo.tags, a:level)

    let typeinfo = s:known_types[fileinfo.ftype]

    " Apply foldlevel to 'kind's
    if a:level == 0
        for kind in typeinfo.kinds
            call fileinfo.closeKindFold(kind)
        endfor
    else
        for kind in typeinfo.kinds
            call fileinfo.openKindFold(kind)
        endfor
    endif

    let fileinfo.foldlevel = a:level

    call s:RenderContent()
endfunction

" s:SetFoldLevelRecursive() {{{2
" Apply foldlevel to normal tags
function! s:SetFoldLevelRecursive(fileinfo, tags, level)
    for tag in a:tags
        if tag.depth >= a:level
            call tag.setFolded(1)
        else
            call tag.setFolded(0)
        endif

        if has_key(tag, 'children')
            call s:SetFoldLevelRecursive(a:fileinfo, tag.children, a:level)
        endif
    endfor
endfunction

" s:OpenParents() {{{2
function! s:OpenParents(...)
    let tagline = 0

    if a:0 == 1
        let tag = a:1
    else
        let tag = s:GetNearbyTag()
    endif

    call tag.openParents()

    call s:RenderKeepView()
endfunction

" Helper functions {{{1
" s:CleanUp() {{{2
function! s:CleanUp()
    silent autocmd! TagbarAutoCmds

    unlet s:is_maximized
    unlet s:compare_typeinfo
    unlet s:short_help
endfunction

" s:CleanupFileinfo() {{{2
function! s:CleanupFileinfo(fname)
    call s:known_files.rm(a:fname)
endfunction

" s:QuitIfOnlyWindow() {{{2
function! s:QuitIfOnlyWindow()
    " Before quitting Vim, delete the tagbar buffer so that
    " the '0 mark is correctly set to the previous buffer.
    if winbufnr(2) == -1
        " Check if there is more than one tab page
        if tabpagenr('$') == 1
            bdelete
            quit
        else
            close
        endif
    endif
endfunction

" s:AutoUpdate() {{{2
function! s:AutoUpdate(fname)
    " Don't do anything if tagbar is not open or if we're in the tagbar window
    let tagbarwinnr = bufwinnr('__Tagbar__')
    if tagbarwinnr == -1 || &filetype == 'tagbar'
        return
    endif

    " Only consider the main filetype in cases like 'python.django'
    let ftype = get(split(&filetype, '\.'), 0, '')

    " Don't do anything if the file isn't supported
    if !s:IsValidFile(a:fname, ftype)
        return
    endif

    " Process the file if it's unknown or the information is outdated
    " Also test for entries that exist but are empty, which will be the case
    " if there was an error during the ctags execution
    if s:known_files.has(a:fname) && !empty(s:known_files.get(a:fname))
        if s:known_files.get(a:fname).mtime != getftime(a:fname)
            call s:ProcessFile(a:fname, ftype)
        endif
    elseif !s:known_files.has(a:fname)
        call s:ProcessFile(a:fname, ftype)
    endif

    let fileinfo = s:known_files.get(a:fname)

    " If we don't have an entry for the file by now something must have gone
    " wrong, so don't change the tagbar content
    if empty(fileinfo)
        return
    endif

    " Display the tagbar content
    call s:RenderContent(fileinfo)

    " Call setCurrent after rendering so RenderContent can check whether the
    " same file is redisplayed
    if !empty(fileinfo)
        call s:known_files.setCurrent(fileinfo)
    endif

    call s:HighlightTag()
endfunction

" s:IsValidFile() {{{2
function! s:IsValidFile(fname, ftype)
    if a:fname == '' || a:ftype == ''
        return 0
    endif

    if !filereadable(a:fname)
        return 0
    endif

    if !has_key(s:known_types, a:ftype)
        return 0
    endif

    return 1
endfunction

" s:EscapeCtagsCmd() {{{2
" Assemble the ctags command line in a way that all problematic characters are
" properly escaped and converted to the system's encoding
" Optional third parameter is a file name to run ctags on
function! s:EscapeCtagsCmd(ctags_bin, args, ...)
    if exists('+shellslash')
        let shellslash_save = &shellslash
        set noshellslash
    endif

    if a:0 == 1
        let fname = shellescape(a:1)
    else
        let fname = ''
    endif

    let ctags_cmd = shellescape(a:ctags_bin) . ' ' . a:args . ' ' . fname

    if exists('+shellslash')
        let &shellslash = shellslash_save
    endif

    " Needed for cases where 'encoding' is different from the system's
    " encoding
    if g:tagbar_systemenc != &encoding
        let ctags_cmd = iconv(ctags_cmd, &encoding, g:tagbar_systemenc)
    elseif $LANG != ''
        let ctags_cmd = iconv(ctags_cmd, &encoding, $LANG)
    endif

    if ctags_cmd == ''
        echoerr 'Tagbar: Encoding conversion failed!'
              \ 'Please make sure your system is set up correctly'
              \ 'and that Vim is compiled with the "iconv" feature.'
    endif

    return ctags_cmd
endfunction

" s:ExecuteCtags() {{{2
" Execute ctags with necessary shell settings
" Partially based on the discussion at
" http://vim.1045645.n5.nabble.com/bad-default-shellxquote-in-Widows-td1208284.html
function! s:ExecuteCtags(ctags_cmd)
    if exists('+shellslash')
        let shellslash_save = &shellslash
        set noshellslash
    endif

    if &shell =~ 'cmd\.exe'
        let shellxquote_save = &shellxquote
        set shellxquote=\"
        let shellcmdflag_save = &shellcmdflag
        set shellcmdflag=/s\ /c
    endif

    let ctags_output = system(a:ctags_cmd)

    if &shell =~ 'cmd\.exe'
        let &shellxquote  = shellxquote_save
        let &shellcmdflag = shellcmdflag_save
    endif

    if exists('+shellslash')
        let &shellslash = shellslash_save
    endif

    return ctags_output
endfunction

" s:GetTagInfo() {{{2
" Return the info dictionary of the tag on the specified line. If the line
" does not contain a valid tag (for example because it is empty or only
" contains a pseudo-tag) return an empty dictionary.
function! s:GetTagInfo(linenr, ignorepseudo)
    let fileinfo = s:known_files.getCurrent()

    if empty(fileinfo)
        return {}
    endif

    " Don't do anything in empty and comment lines
    let curline = getline(a:linenr)
    if curline =~ '^\s*$' || curline[0] == '"'
        return {}
    endif

    " Check if there is a tag on the current line
    if !has_key(fileinfo.tline, a:linenr)
        return {}
    endif

    let taginfo = fileinfo.tline[a:linenr]

    " Check if the current tag is not a pseudo-tag
    if a:ignorepseudo && taginfo.isPseudoTag()
        return {}
    endif

    return taginfo
endfunction

" s:GetNearbyTag() {{{2
" Get the tag info for a file near the cursor in the current file
function! s:GetNearbyTag()
    let fileinfo = s:known_files.getCurrent()

    let curline = line('.')
    let tag = {}

    " If a tag appears in a file more than once (for example namespaces in
    " C++) only one of them has a 'tline' entry and can thus be highlighted.
    " The only way to solve this would be to go over the whole tag list again,
    " making everything slower. Since this should be a rare occurence and
    " highlighting isn't /that/ important ignore it for now.
    for line in range(curline, 1, -1)
        if has_key(fileinfo.fline, line)
            let tag = fileinfo.fline[line]
            break
        endif
    endfor

    return tag
endfunction

" s:CheckMouseClick() {{{2
function! s:CheckMouseClick()
    let line   = getline('.')
    let curcol = col('.')

    if (match(line, s:icon_open . '[-+ ]') + 1) == curcol
        call s:CloseFold()
    elseif (match(line, s:icon_closed . '[-+ ]') + 1) == curcol
        call s:OpenFold()
    endif
endfunction

" TagbarBalloonExpr() {{{2
function! TagbarBalloonExpr()
    let taginfo = s:GetTagInfo(v:beval_lnum, 1)

    if empty(taginfo)
        return
    endif

    return taginfo.getPrototype()
endfunction

" TagbarGenerateStatusline() {{{2
function! TagbarGenerateStatusline()
    if g:tagbar_sort
        let text = '[Name]'
    else
        let text = '[Order]'
    endif

    if !empty(s:known_files.getCurrent())
        let filename = fnamemodify(s:known_files.getCurrent().fpath, ':t')
        let text .= ' ' . filename
    endif

    return text
endfunction

" Commands {{{1
command! -nargs=0 TagbarToggle        call s:ToggleWindow()
command! -nargs=0 TagbarOpen          call s:OpenWindow(0)
command! -nargs=0 TagbarOpenAutoClose call s:OpenWindow(1)
command! -nargs=0 TagbarClose         call s:CloseWindow()
command! -nargs=1 TagbarSetFoldlevel  call s:SetFoldLevel(<args>)
command! -nargs=0 TagbarShowTag       call s:OpenParents()

" Modeline {{{1
" vim: ts=8 sw=4 sts=4 et foldenable foldmethod=marker foldcolumn=1
syntax/tagbar.vim	[[[1
60
" File:        tagbar.vim
" Description: Tagbar syntax settings
" Author:      Jan Larres <jan@majutsushi.net>
" Licence:     Vim licence
" Website:     http://majutsushi.github.com/tagbar/
" Version:     2.1

if exists("b:current_syntax")
  finish
endif

if has('multi_byte') && has('unix') && &encoding == 'utf-8' &&
 \ (empty(&termencoding) || &termencoding == 'utf-8')
    syntax match TagbarKind  '\([▶▼] \)\@<=[^-+: ]\+[^:]\+$'
    syntax match TagbarScope '\([▶▼][-+# ]\)\@<=[^*]\+\(\*\?\(([^)]\+)\)\? :\)\@='

    syntax match TagbarFoldIcon '[▶▼]\([-+# ]\)\@='

    syntax match TagbarAccessPublic    '\([▶▼ ]\)\@<=+\([^-+# ]\)\@='
    syntax match TagbarAccessProtected '\([▶▼ ]\)\@<=#\([^-+# ]\)\@='
    syntax match TagbarAccessPrivate   '\([▶▼ ]\)\@<=-\([^-+# ]\)\@='
elseif has('multi_byte') && (has('win32') || has('win64')) && g:tagbar_usearrows
    syntax match TagbarKind  '\([▷◢] \)\@<=[^-+: ]\+[^:]\+$'
    syntax match TagbarScope '\([▷◢][-+# ]\)\@<=[^*]\+\(\*\?\(([^)]\+)\)\? :\)\@='

    syntax match TagbarFoldIcon '[▷◢]\([-+# ]\)\@='

    syntax match TagbarAccessPublic    '\([▷◢ ]\)\@<=+\([^-+# ]\)\@='
    syntax match TagbarAccessProtected '\([▷◢ ]\)\@<=#\([^-+# ]\)\@='
    syntax match TagbarAccessPrivate   '\([▷◢ ]\)\@<=-\([^-+# ]\)\@='
else
    syntax match TagbarKind  '\([-+] \)\@<=[^-+: ]\+[^:]\+$'
    syntax match TagbarScope '\([-+][-+# ]\)\@<=[^*]\+\(\*\?\(([^)]\+)\)\? :\)\@='

    syntax match TagbarFoldIcon '[-+]\([-+# ]\)\@='

    syntax match TagbarAccessPublic    '\([-+ ]\)\@<=+\([^-+# ]\)\@='
    syntax match TagbarAccessProtected '\([-+ ]\)\@<=#\([^-+# ]\)\@='
    syntax match TagbarAccessPrivate   '\([-+ ]\)\@<=-\([^-+# ]\)\@='
endif

syntax match TagbarComment   '^".*'
syntax match TagbarType      ' : \zs.*'
syntax match TagbarSignature '(.*)'
syntax match TagbarPseudoID  '\*\ze :'

highlight default link TagbarComment   Comment
highlight default link TagbarKind      Identifier
highlight default link TagbarScope     Title
highlight default link TagbarType      Type
highlight default link TagbarSignature SpecialKey
highlight default link TagbarPseudoID  NonText
highlight default link TagbarFoldIcon  Statement
highlight default link TagbarHighlight Search

highlight default TagbarAccessPublic    guifg=Green ctermfg=Green
highlight default TagbarAccessProtected guifg=Blue  ctermfg=Blue
highlight default TagbarAccessPrivate   guifg=Red   ctermfg=Red

let b:current_syntax = "tagbar"
doc/tagbar.txt	[[[1
895
*tagbar.txt*	Display tags of a file in their correct scope

Author:		Jan Larres <jan@majutsushi.net>
Licence:	Vim licence, see |license|
Homepage:	http://majutsushi.github.com/tagbar/
Version:	2.1

==============================================================================
Contents					*tagbar* *tagbar-contents*

	 1. Intro ........................... |tagbar-intro|
	      Pseudo-tags ................... |tagbar-pseudotags|
	      Supported features ............ |tagbar-features|
	      Other ctags-compatible programs |tagbar-other|
	 2. Requirements .................... |tagbar-requirements|
	 3. Installation .................... |tagbar-installation|
	 4. Usage ........................... |tagbar-usage|
	      Commands ...................... |tagbar-commands|
	      Key mappings .................. |tagbar-keys|
	 5. Configuration ................... |tagbar-configuration|
	      Highlight colours ............. |tagbar-highlight|
	      Automatically opening Tagbar .. |tagbar-autoopen|
	 6. Extending Tagbar ................ |tagbar-extend|
	 7. Bugs and limitations ............ |tagbar-bugs|
	 8. History ......................... |tagbar-history|
	 9. Todo ............................ |tagbar-todo|
	10. Credits ......................... |tagbar-credits|

==============================================================================
1. Intro						*tagbar-intro*

Tagbar is a plugin for browsing the tags of source code files. It provides a
sidebar that displays the ctags-generated tags of the current file, ordered by
their scope. This means that for example methods in C++ are displayed under
the class they are defined in.

Let's say we have the following code inside of a C++ file:
>
    namespace {
        char a;

        class Foo
        {
        public:
            Foo();
            ~Foo();
        private:
            int var;
        };
    };
<
Then Tagbar would display the tag information like so:
>
    __anon1* : namespace
      Foo : class
       +Foo()
       +~Foo()
       -var
      a
<
This example shows several important points. First, the tags are listed
indented below the scope they are defined in. Second, the type of a scope is
listed after its name and a colon. Third, tags for which the access/visibility
information is known are prefixed with a symbol indicating that.

------------------------------------------------------------------------------
PSEUDO-TAGS						*tagbar-pseudotags*

The example also introduces the concept of "pseudo-tags". Pseudo-tags are tags
that are not explicitly defined in the file but have children in it. In this
example the namespace doesn't have a name and thus ctags doesn't generate a
tag for it, but since it has children it still needs to be displayed using an
auto-generated name.

Another case where pseudo-tags appear is in C++ implementation files. Since
classes are usually defined in a header file but the member methods and
variables in the implementation file the class itself won't generate a tag
in that file.

Since pseudo-tags don't really exist they cannot be jumped to from the Tagbar
window.

Pseudo-tags are denoted with an asterisk ('*') at the end of their name.

------------------------------------------------------------------------------
SUPPORTED FEATURES					*tagbar-features*

The following features are supported by Tagbar:

  - Display tags under their correct scope.
  - Automatically update the tags when switching between buffers and editing
    files.
  - Display visibility information of tags if available.
  - Highlight the tag near the cursor while editing files.
  - Jump to a tag from the Tagbar window.
  - Display the complete prototype of a tag.
  - Tags can be sorted either by name or order of appearance in the file.
  - Scopes can be folded to hide uninteresting information.
  - Supports all of the languages that ctags does, i.e. Ant, Assembler, ASP,
    Awk, Basic, BETA, C, C++, C#, COBOL, DosBatch, Eiffel, Erlang, Flex,
    Fortran, HTML, Java, JavaScript, Lisp, Lua, Make, MatLab, OCaml, Pascal,
    Perl, PHP, Python, REXX, Ruby, Scheme, Shell script, SLang, SML, SQL, Tcl,
    Tex, Vera, Verilog, VHDL, Vim and YACC.
  - Can be extended to support arbitrary new types.

------------------------------------------------------------------------------
OTHER CTAGS-COMPATIBLE PROGRAMS				*tagbar-other*

Tagbar theoretically also supports filetype-specific programs that can output
tag information that is compatible with ctags. However due to potential
incompatibilities this may not always completely work. Tagbar has been tested
with doctorjs/jsctags and will use that if present, other programs require
some configuration (see |tagbar-extend|). If a program does not work even with
correct configuration please contact me.

Note: jsctags has to be newer than 2011-01-06 since it needs the "-f" option
to work. Also, the output of jsctags seems to be a bit unreliable at the
moment (especially regarding line numbers), so if you notice some strange
behaviour with it please run it manually in a terminal to check whether the
bug is in jsctags or Tagbar.

==============================================================================
2. Requirements						*tagbar-requirements*

The following requirements have to be met in order to be able to use tagbar:

  - Vim 7.0 or higher. Older versions will not work since Tagbar uses data
    structures that were only introduced in Vim 7.
  - Exuberant ctags 5.5 or higher. Ctags is the program that generates the
    tag information that Tagbar uses. It is shipped with most Linux
    distributions, otherwise it can be downloaded from the following
    website:

        http://ctags.sourceforge.net/

    Tagbar will work on any platform that ctags runs on -- this includes
    UNIX derivatives, Mac OS X and Windows. Note that other versions like
    GNU ctags will not work.
    Tagbar generates the tag information by itself and doesn't need (or use)
    already existing tag files.
  - File type detection must be turned on in vim. This can be done with the
    following command in your vimrc:
>
        filetype on
<
    See |filetype| for more information.
  - Tagbar will not work in |restricted-mode| or with 'compatible' set.

==============================================================================
3. Installation						*tagbar-installation*

Use the normal Vimball install method for installing tagbar.vba:
>
	vim tagbar.vba
	:so %
	:q
<
Alternatively you can clone the git repository and then add the path to
'runtimepath' or use the pathogen plugin. Don't forget to run |:helptags| if
you're not using pathogen.

If the ctags executable is not installed in one of the directories in your
$PATH environment variable you have to set the g:tagbar_ctags_bin variable,
see |g:tagbar_ctags_bin|.

==============================================================================
4. Usage						*tagbar-usage*

There are essentially two ways to use Tagbar:

  1. Have it running all the time in a window on the side of the screen. In
     this case Tagbar will update its contents whenever the source file is
     changed and highlight the tag the cursor is currently on in the file. If
     a tag is selected in Tagbar the file window will jump to the tag and the
     Tagbar window will stay open. |g:tagbar_autoclose| has to be unset for
     this mode.
  2. Only open Tagbar when you want to jump to a specific tag and have it
     close automatically once you have selected one. This can be useful for
     example for small screens where a permanent window would take up too much
     space. You have to set the option |g:tagbar_autoclose| in this case. The
     cursor will also automatically jump to the Tagbar window when opening it.

Opening and closing the Tagbar window~
Use |:TagbarOpen| or |:TagbarToggle| to open the Tagbar window if it is
closed. By default the window is opened on the right side, set the option
|g:tagbar_left| to open it on the left instead. If the window is already open,
|:TagbarOpen| will jump to it and |:TagbarToggle| will close it again.
|:TagbarClose| will simply close the window if it is open.

It is probably a good idea to assign a key to these commands. For example, put
this in your |vimrc|:
>
	nnoremap <silent> <F9> :TagbarToggle<CR>
<
You can then open and close Tagbar by simply pressing the <F9> key.

You can also use |:TagbarOpenAutoClose| to open the Tagbar window, jump to it
and have it close automatically on tag selection regardless of the
|g:tagbar_autoclose| setting.

Jumping to tags~
When you're inside the Tagbar window you can jump to the definition of a tag
by moving the cursor to a tag and pressing <Enter> or double-clicking on it
with the mouse. The source file will then move to the definition and put the
cursor in the corresponding line. This won't work for pseudo-tags.

Sorting~
You can sort the tags in the Tagbar window in two ways: by name or by file
order. Sorting them by name simply displays the tags in their alphabetical
order under their corresponding scope. Sorting by file order means that the
tags keep the order they have in the source file, but are still associated
with the correct scope. You can change the sort order by pressing the "s" key
in the Tagbar window. The current sort order is displayed in the statusbar of
the Tagbar window.

Folding~
The displayed scopes (and unscoped types) can be folded to hide uninteresting
information. Mappings similar to Vim's built-in ones are provided. Folds can
also be opened and closed by clicking on the fold icon with the mouse.

Displaying the prototype of a tag~
Tagbar can display the prototype of a tag. More precisely it can display the
line in which the tag is defined. This can be done by either pressing <Space>
when on a tag or hovering over a tag with the mouse. In the former case the
prototype will be displayed in the command line |Command-line|, in the latter
case it will be displayed in a pop-up window. The prototype will also be
displayed when the cursor stays on a tag for 'updatetime' milliseconds.

------------------------------------------------------------------------------
COMMANDS						*tagbar-commands*

:TagbarOpen
    Open the Tagbar if it is closed. In case it is already open jump to it.

:TagbarClose
    Close the Tagbar window if it is open.

:TagbarToggle
    Open the Tagbar window if it is closed or close it if it is open.

:TagbarOpenAutoClose
    Open the Tagbar window and close it on tag selection, regardless of the
    setting of |g:tagbar_autoclose|. If it was already open jump to it.

:TagbarSetFoldlevel [number]
    Set the foldlevel of the tags of the current file to [number]. The
    foldlevel of tags in other files remains unaffected. Works in the same way
    as 'foldlevel'.

:TagbarShowTag
    Open the parent folds of the current tag in the file window as much as
    needed for the tag to be visible in the Tagbar window.

------------------------------------------------------------------------------
KEY MAPPINGS						*tagbar-keys*

These mappings are valid in the Tagbar window:

<F1>          Display key mapping help.
<CR>/<Enter>  Jump to the tag under the cursor. Doesn't work for pseudo-tags
              or generic headers.
p             Jump to the tag under the cursor, but stay in the Tagbar window.
<LeftMouse>   When on a fold icon, open or close the fold depending on the
              current state.
<2-LeftMouse> Same as <CR>.
<Space>       Display the prototype of the current tag (i.e. the line defining
              it) in the command line.
+/zo          Open the fold under the cursor.
-/zc          Close the fold under the cursor or the current one if there is
              no fold under the cursor.
o/za          Toggle the fold under the cursor or the current one if there is
              no fold under the cursor.
*/zR          Open all folds by setting foldlevel to 99.
=/zM          Close all folds by setting foldlevel to 0.
<C-N>         Go to the next top-level tag.
<C-P>         Go to the previous top-level tag.
s             Toggle sort order between name and file order.
x             Toggle zooming the window.
q             Close the Tagbar window.

==============================================================================
5. Configuration					*tagbar-configuration*

							*g:tagbar_ctags_bin*
g:tagbar_ctags_bin~
Default: empty

Use this option to specify the location of your ctags executable. Only needed
if it is not in one of the directories in your $PATH environment variable.

Example:
>
	let g:tagbar_ctags_bin = 'C:\Ctags5.8\ctags.exe'
<

							*g:tagbar_left*
g:tagbar_left~
Default: 0

By default the Tagbar window will be opened on the right-hand side of vim. Set
this option to open it on the left instead.

Example:
>
	let g:tagbar_left = 1
<

							*g:tagbar_width*
g:tagbar_width~
Default: 40

Width of the Tagbar window in characters.

Example:
>
	let g:tagbar_width = 30
<

							*g:tagbar_autoclose*
g:tagbar_autoclose~
Default: 0

If you set this option the Tagbar window will automatically close when you
jump to a tag.

Example:
>
	let g:tagbar_autoclose = 1
<

							*g:tagbar_autofocus*
g:tagbar_autofocus~
Default: 0

If you set this option the cursor will move to the Tagbar window when it is
opened.

Example:
>
	let g:tagbar_autofocus = 1
<

							*g:tagbar_sort*
g:tagbar_sort~
Default: 1

If this option is set the tags are sorted according to their name. If it is
unset they are sorted according to their order in the source file. Note that
in the second case Pseudo-tags are always sorted before normal tags of the
same kind since they don't have a real position in the file.

Example:
>
	let g:tagbar_sort = 0
<

							*g:tagbar_compact*
g:tagbar_compact~
Default: 0

Setting this option will result in Tagbar omitting the short help at the
top of the window and the blank lines in between top-level scopes in order to
save screen real estate.

Example:
>
	let g:tagbar_compact = 1
<

							*g:tagbar_expand*
g:tagbar_expand~
Default: 0

If this option is set the Vim window will be expanded by the width of the
Tagbar window if using a GUI version of Vim.

Example:
>
	let g:tagbar_expand = 1
<

							*g:tagbar_foldlevel*
g:tagbar_foldlevel~
Default: 99

The initial foldlevel for folds in the Tagbar window. Fold with a level higher
than this number will be closed.

Example:
>
	let g:tagbar_foldlevel = 2
<

							*g:tagbar_usearrows*
g:tagbar_usearrows~
{Windows only}
Default: 0

Tagbar can display nice Unicode arrows instead of +/- characters as fold icons.
However, Windows doesn't seem to be able to substitute in characters from
other fonts if the current font doesn't support them. This means that you have
to use a font that supports those arrows. Unfortunately there is no way to
detect whether specific characters are supported in the current font. So if
your font supports those arrows you have to set this option to make it work.

Example:
>
	let g:tagbar_usearrows = 1
<

							*g:tagbar_autoshowtag*
g:tagbar_autoshowtag~
Default: 0

If this variable is set and the current tag is inside of a closed fold then
the folds will be opened as much as needed for the tag to be visible so it can
be highlighted. If it is not set then the folds won't be opened and the parent
tag will be highlighted instead. You can use the TagbarShowTag command to open
the folds manually.

Example:
>
	let g:tagbar_autoshowtag = 1
<

							*g:tagbar_systemenc*
g:tagbar_systemenc~
Default: value of 'encoding'

This variable is for cases where the character encoding of your operating
system is different from the one set in Vim, i.e. the 'encoding' option. For
example, if you use a Simplified Chinese Windows version that has a system
encoding of "cp936", and you have set 'encoding' to "utf-8", then you would
have to set this variable to "cp936".

Example:
>
	let g:tagbar_systemenc = 'cp936'
<

------------------------------------------------------------------------------
HIGHLIGHT COLOURS					*tagbar-highlight*

All of the colours used by Tagbar can be customized. Here is a list of the
highlight groups that are defined by Tagbar:

TagbarComment
    The help at the top of the buffer.

TagbarKind
    The header of generic "kinds" like "functions" and "variables".

TagbarScope
    Tags that define a scope like classes, structs etc.

TagbarType
    The type of a tag or scope if available.

TagbarSignature
    Function signatures.

TagbarPseudoID
    The asterisk (*) that signifies a pseudo-tag.

TagbarFoldIcon
    The fold icon on the left of foldable tags.

TagbarHighlight
    The colour that is used for automatically highlighting the current tag.

TagbarAccessPublic
    The "public" visibility/access symbol.

TagbarAccessProtected
    The "protected" visibility/access symbol.

TagbarAccessPrivate
    The "private" visibility/access symbol.

If you want to change any of those colours put a line like the following in
your vimrc:
>
	highlight TagbarScope guifg=Green ctermfg=Green
<
See |:highlight| for more information.

------------------------------------------------------------------------------
AUTOMATICALLY OPENING TAGBAR				*tagbar-autoopen*

If you want Tagbar to open automatically, for example on Vim startup or for
specific filetypes, there are various ways to do it. For example, to always
open Tagbar on Vim startup you can put this into your vimrc file:
>
    autocmd VimEnter * nested TagbarOpen
<
If you want to have it start for specific filetypes put
>
    TagbarOpen
<
into a corresponding filetype plugin (see |filetype-plugin|).

Check out |autocmd.txt| if you want it to automatically open in more
complicated cases.

==============================================================================
6. Extending Tagbar					*tagbar-extend*

Tagbar has a flexible mechanism for extending the existing file type (i.e.
language) definitions. This can be used both to change the settings of the
existing types and to add completely new types. A complete configuration
consists of a type definition for Tagbar in your |vimrc| and optionally a
language definition for ctags in case you want to add a new language.

Every type definition in Tagbar is a dictionary with the following keys:

ctagstype:  The name of the language as recognized by ctags. Use the command >
                ctags --list-languages
<           to get a list of the languages ctags supports. The case doesn't
            matter.
kinds:      A list of the "language kinds" that should be listed in Tagbar,
            ordered by the order they should appear in in the Tagbar window.
            Use the command >
                ctags --list-kinds={language name}
<           to get a list of the kinds ctags supports for a given language. An
            entry in this list is a string with two or three parts separated
            by a colon: the first part is the one-character abbreviation that
            ctags uses, and the second part is an arbitrary string that will
            be used in Tagbar as the header for the tags of this kind that are
            not listed under a specific scope. The optional third part
            determines whether tags of this kind should be folded by default,
            with 1 meaning they should be folded and 0 they should not. If
            this part is omitted the tags will not be folded by default. For
            example, the string >
                "f:functions:1"
<           would list all the function definitions in a file under the header
            "functions" and fold them.
sro:        The scope resolution operator. For example, in C++ it is "::" and
            in Java it is ".". If in doubt run ctags as shown above and check
            the output.
kind2scope: A dictionary describing the mapping of tag kinds (in their
            one-character representation) to the scopes their children will
            appear in, for example classes, structs etc.
            Unfortunately there is no ctags option to list the scopes, you
            have to look at the tags ctags generates manually. For example,
            let's say we have a C++ file "test.cpp" with the following
            contents: >
                class Foo
                {
                public:
                    Foo();
                    ~Foo();
                private:
                    int var;
                };
<           We then run ctags in the followin way: >
                ctags -f - --format=2 --excmd=pattern --fields=nksazSmt --extra= test.cpp
<           Then the output for the variable "var" would look like this: >
                var	tmp.cpp /^    int var;$/;"	kind:m	line:11	class:Foo	access:private
<           This shows that the scope name for an entry in a C++ class is
            simply "class". So this would be the word that the "kind"
            character of a class has to be mapped to.
scope2kind: The opposite of the above, mapping scopes to the kinds of their
            parents. Most of the time it is the exact inverse of the above,
            but in some cases it can be different, for example when more than
            one kind maps to the same scope. If it is the exact inverse for
            your language you only need to specify one of the two keys.
replace:    If you set this entry to 1 your definition will completely replace
{optional}  an existing default definition. This is useful if you want to
            disable scopes for a file type for some reason. Note that in this
            case you have to provide all the needed entries yourself!
sort:       This entry can be used to override the global sort setting for
{optional}  this specific file type. The meaning of the value is the same as
            with the global setting, that is if you want to sort tags by name
            set it to 1 and if you want to sort them according to their order
            in the file set it to 0.
deffile:    The path to a file with additional ctags definitions (see the
{optional}  section below on adding a new definition for what exactly that
            means). This is especially useful for ftplugins since they can
            provide a complete type definition with ctags and Tagbar
            configurations without requiring user intervention.
            Let's say you have an ftplugin that adds support for the language
            "mylang", and your directory structure looks like this: >
                ctags/mylang.cnf
                ftplugin/mylang.vim
<           Then the "deffile" entry would look like this to allow for the
            plugin to be installed in an arbitray location (for example
            with pathogen): >

                'deffile' : expand('<sfile>:p:h:h') . '/ctags/mylang.cnf'
<
ctagsbin:  The path to a filetype-specific ctags-compatible program like
{optional} jsctags. Set it in the same way as |g:tagbar_ctags_bin|. jsctags is
           used automatically if found in your $PATH and does not have to be
           set in that case. If it is not in your path you have to provide the
           complete configuration and use the "replace" key (see the
           Tagbar source code for the suggested configuration).
ctagsargs: The arguments to be passed to the filetype-specific ctags program
{optional} (without the filename). Make sure you set an option that makes the
           program output its data on stdout. Not used for the normal ctags
           program.


You then have to assign this dictionary to a variable in your vimrc with the
name
>
	g:tagbar_type_{vim filetype}
<
For example, for C++ the name would be "g:tagbar_type_cpp". If you don't know
the vim file type then run the following command:
>
	:set filetype?
<
and vim will display the file type of the current buffer.

Example: C++~
Here is a complete example that shows the default configuration for C++ as
used in Tagbar.
>
	let g:tagbar_type_cpp = {
	    \ 'ctagstype' : 'c++',
	    \ 'kinds'     : [
	        \ 'd:macros:1',
	        \ 'p:prototypes:1',
	        \ 'g:enums',
	        \ 'e:enumerators',
	        \ 't:typedefs',
	        \ 'n:namespaces',
	        \ 'c:classes',
	        \ 's:structs',
	        \ 'u:unions',
	        \ 'f:functions',
	        \ 'm:members',
	        \ 'v:variables'
	    \ ],
	    \ 'sro'        : '::',
	    \ 'kind2scope' : {
	        \ 'g' : 'enum',
	        \ 'n' : 'namespace',
	        \ 'c' : 'class',
	        \ 's' : 'struct',
	        \ 'u' : 'union'
	    \ },
	    \ 'scope2kind' : {
	        \ 'enum'      : 'g',
	        \ 'namespace' : 'n',
	        \ 'class'     : 'c',
	        \ 'struct'    : 's',
	        \ 'union'     : 'u'
	    \ }
	\ }
<

Which of the keys you have to specify depends on what you want to do.

Changing an existing definition~
If you want to change an existing definition you only need to specify the
parts that you want to change. It probably only makes sense to change "kinds"
and/or "scopes", which would be the case if you wanted to exclude certain
kinds from appearing in Tagbar or if you want to change their order. As an
example, if you didn't want Tagbar to show prototypes for C++ files and switch
the order of enums and typedefs, you would do it like this:
>
	let g:tagbar_type_cpp = {
	    \ 'kinds' : [
	        \ 'd:macros:1',
	        \ 'g:enums',
	        \ 't:typedefs',
	        \ 'e:enumerators',
	        \ 'n:namespaces',
	        \ 'c:classes',
	        \ 's:structs',
	        \ 'u:unions',
	        \ 'f:functions',
	        \ 'm:members',
	        \ 'v:variables'
	    \ ]
	\ }
<
Compare with the complete example above to see the exact change.

Adding a definition for a new language/file type~
In order to be able to add a new language to Tagbar you first have to create a
configuration for ctags that it can use to parse the files. This can be done
in two ways:

  1. Use the --regex argument for specifying regular expressions that are used
     to parse the files. An example of this is given below. A disadvantage of
     this approach is that you can't specify scopes.
  2. Write a parser plugin in C for ctags. This approach is much more powerful
     than the regex approach since you can make use of all of ctags'
     functionality but it also requires much more work. Read the ctags
     documentation for more information about how to do this.

For the first approach the only keys that are needed in the Tagbar definition
are "ctagstype" and "kinds". A definition that supports scopes has to define
those two and in addition "scopes", "sro" and at least one of "kind2scope" and
"scope2kind".

Let's assume we want to add support for LaTeX to Tagbar using the regex
approach. First we put the following text into ~/.ctags or a file pointed to
by the "deffile" definition entry:
>
	--langdef=latex
	--langmap=latex:.tex
	--regex-latex=/^\\tableofcontents/TABLE OF CONTENTS/s,toc/
	--regex-latex=/^\\frontmatter/FRONTMATTER/s,frontmatter/
	--regex-latex=/^\\mainmatter/MAINMATTER/s,mainmatter/
	--regex-latex=/^\\backmatter/BACKMATTER/s,backmatter/
	--regex-latex=/^\\bibliography\{/BIBLIOGRAPHY/s,bibliography/
	--regex-latex=/^\\part[[:space:]]*(\[[^]]*\])?[[:space:]]*\{([^}]+)\}/PART \2/s,part/
	--regex-latex=/^\\part[[:space:]]*\*[[:space:]]*\{([^}]+)\}/PART \1/s,part/
	--regex-latex=/^\\chapter[[:space:]]*(\[[^]]*\])?[[:space:]]*\{([^}]+)\}/CHAP \2/s,chapter/
	--regex-latex=/^\\chapter[[:space:]]*\*[[:space:]]*\{([^}]+)\}/CHAP \1/s,chapter/
	--regex-latex=/^\\section[[:space:]]*(\[[^]]*\])?[[:space:]]*\{([^}]+)\}/\. \2/s,section/
	--regex-latex=/^\\section[[:space:]]*\*[[:space:]]*\{([^}]+)\}/\. \1/s,section/
	--regex-latex=/^\\subsection[[:space:]]*(\[[^]]*\])?[[:space:]]*\{([^}]+)\}/\.\. \2/s,subsection/
	--regex-latex=/^\\subsection[[:space:]]*\*[[:space:]]*\{([^}]+)\}/\.\. \1/s,subsection/
	--regex-latex=/^\\subsubsection[[:space:]]*(\[[^]]*\])?[[:space:]]*\{([^}]+)\}/\.\.\. \2/s,subsubsection/
	--regex-latex=/^\\subsubsection[[:space:]]*\*[[:space:]]*\{([^}]+)\}/\.\.\. \1/s,subsubsection/
	--regex-latex=/^\\includegraphics[[:space:]]*(\[[^]]*\])?[[:space:]]*(\[[^]]*\])?[[:space:]]*\{([^}]+)\}/\3/g,graphic+listing/
	--regex-latex=/^\\lstinputlisting[[:space:]]*(\[[^]]*\])?[[:space:]]*(\[[^]]*\])?[[:space:]]*\{([^}]+)\}/\3/g,graphic+listing/
	--regex-latex=/\\label[[:space:]]*\{([^}]+)\}/\1/l,label/
	--regex-latex=/\\ref[[:space:]]*\{([^}]+)\}/\1/r,ref/
	--regex-latex=/\\pageref[[:space:]]*\{([^}]+)\}/\1/p,pageref/
<
This will create a new language definition with the name "latex" and associate
it with files with the extension ".tex". It will also define the kinds "s" for
sections, chapters and the like, "g" for included graphics, "l" for labels,
"r" for references and "p" for page references. See the ctags documentation
for more information about the exact syntax.

Now we have to create the Tagbar language definition in our vimrc:
>
	let g:tagbar_type_tex = {
	    \ 'ctagstype' : 'latex',
	    \ 'kinds'     : [
	        \ 's:sections',
	        \ 'g:graphics',
	        \ 'l:labels',
	        \ 'r:refs:1',
	        \ 'p:pagerefs:1'
	    \ ],
	    \ 'sort'    : 0,
	    \ 'deffile' : expand('<sfile>:p:h:h') . '/ctags/latex.cnf'
	\ }
<
The "deffile" field is of course only needed if the ctags definition actually
is in that file and not in ~/.ctags.

Sort has been disabled for LaTeX so that the sections appear in their correct
order. They unfortunately can't be shown nested with their correct scopes
since as already mentioned the regular expression approach doesn't support
that.

Tagbar should now be able to show the sections and other tags from LaTeX
files.

==============================================================================
7. Bugs and limitations					*tagbar-bugs*

  - Nested pseudo-tags cannot be properly parsed since only the direct parent
    scope of a tag gets assigned a type, the type of the grandparents is not
    reported by ctags (assuming the grandparents don't have direct, real
    children).

    For example, if we have a C++ with the following content:
>
        foo::Bar::init()
        {
            // ...
        }
        foo::Baz::method()
        {
            // ...
        }
<
    In this case the type of "foo" is not known. Is it a namespace? A class?
    For this reason the methods are displayed in Tagbar like this:
>
        foo::Bar* : class
          init()
        foo::Baz* : class
          method()
<
  - Scope-defining tags at the top level that have the same name but a
    different kind/scope type can lead to an incorrect display. For example,
    the following Python code will incorrectly insert a pseudo-tag "Inner2"
    into the "test" class:
>
        class test:
            class Inner:
                def foo(self):
                    pass

        def test():
            class Inner2:
                def bar(self):
                    pass
<
    I haven't found a clean way around this yet, but it shouldn't be much of a
    problem in practice anyway. Tags with the same name at any other level are
    no problem, though.

==============================================================================
8. History						*tagbar-history*

2.1 (2011-05-29)
    - Make Tagbar work in (hopefully) all cases under Windows
    - Handle cases where 'encoding' is different from system encoding, for
      example on a Chinese Windows with 'encoding' set to "utf-8" (see manual
      for details in case it doesn't work out-of-the-box)
    - Fixed a bug with the handling of subtypes like "python.django"
    - If a session got saved with Tagbar open it now gets restored properly
    - Locally reset foldmethod/foldexpr in case foldexpr got set to something
      expensive globally
    - Tagbar now tries hard to go to the correct window when jumping to a tag
    - Explain some possible issues with the current jsctags version in the
      manual
    - Explicitly check for some possible configuration problems to be able to
      give better feedback
    - A few other small fixes

2.0.1 (2011-04-26)
    - Fix sorting bug when 'ignorecase' is set

2.0 (2011-04-26)
    - Folding now works correctly. Folds will be preserved when leaving the
      Tagbar window and when switching between files. Also tag types can be
      configured to be folded by default, which is useful for things like
      includes and imports.
    - DoctorJS/jsctags and other compatible programs are now supported.
    - All of the highlight groups can now be overridden.
    - Added keybinding to quickly jump to next/previous top-level tag.
    - Added Taglist's "p" keybinding for jumping to a tag without leaving the
      Tagbar window.
    - Several bugfixes and other small improvements.

1.5 (2011-03-06)
    - Type definitions can now include a path to a file with the ctags
      definition. This is especially useful for ftplugins that can now ship
      with a complete ctags and Tagbar configuration without requiring user
      intervention. Thanks to Jan Christoph Ebersbach for the suggestion.
    - Added autofocus setting by Taybin Rutkin. This will put the cursor in
      the Tagbar window when it is opened.
    - The "scopes" field is no longer needed in type definitions, the
      information is already there in "scope2kind". Existing definitions will
      be ignored.
    - Some fixes and improvements related to redrawing and window switching.

1.2 (2011-02-28)
    - Fix typo in Ruby definition

1.1 (2011-02-26)
    - Don't lose syntax highlighting when ':syntax enable' is called
    - Allow expanding the Vim window when Tagbar is opened

1.0 (2011-02-23)
    - Initial release

==============================================================================
9. Todo							*tagbar-todo*

  - Allow filtering the Tagbar content by some criteria like tag name,
    visibility, kind ...
  - Integrate Tagbar with the FSwitch plugin to provide header file
    information in C/C++.
  - Allow jumping to a tag in the preview window, a split window or a new tab.

==============================================================================
10. Credits						*tagbar-credits*

Tagbar was written by Jan Larres and is released under the Vim licence, see
|license|. It was heavily inspired by the Taglist plugin by Yegappan
Lakshmanan and uses a small amount of code from it.

Original taglist copyright notice:
Permission is hereby granted to use and distribute this code, with or without
modifications, provided that this copyright notice is copied with it. Like
anything else that's free, taglist.vim is provided *as is* and comes with no
warranty of any kind, either expressed or implied. In no event will the
copyright holder be liable for any damamges resulting from the use of this
software.

The folding technique was inspired by NERDTree by Martin Grenfell.

Taybin Rutkin:
  - Contributed tagbar_autofocus option
Seth Milliken:
  - Contributed folding keybindings that resemble the built-in ones

Thanks to the following people for feature suggestions etc: Jan Christoph
Ebersbach, pielgrzym

==============================================================================
 vim: tw=78 ts=8 sw=8 sts=8 noet ft=help
