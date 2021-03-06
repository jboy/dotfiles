" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" Keep user-supplied options
if !exists("nim_highlight_numbers")
  let nim_highlight_numbers = 1
endif
if !exists("nim_highlight_builtins")
  let nim_highlight_builtins = 1
endif
if !exists("nim_highlight_exceptions")
  let nim_highlight_exceptions = 1
endif
if !exists("nim_highlight_space_errors")
  let nim_highlight_space_errors = 1
endif

if exists("nim_highlight_all")
  let nim_highlight_numbers      = 1
  let nim_highlight_builtins     = 1
  let nim_highlight_exceptions   = 1
  let nim_highlight_space_errors = 1
endif

syn region nimBrackets       contained extend keepend matchgroup=Bold start=+\(\\\)\@<!\[+ end=+]\|$+ skip=+\\\s*$\|\(\\\)\@<!\\]+ contains=@tclCommandCluster

syn keyword nimKeyword       addr and as asm atomic
syn keyword nimKeyword       bind block break
syn keyword nimKeyword       case cast continue converter
syn keyword nimStaticKeyword       const
syn keyword nimKeyword       discard distinct div do
syn keyword nimKeyword       elif else end enum except export
syn keyword nimKeyword       finally from
syn keyword nimIdentDefKeyword       for
syn keyword nimKeyword       generic
syn keyword nimKeyword       if in interface is isnot
syn keyword nimIdentDefKeyword       import include iterator
syn keyword nimKeyword       lambda
syn keyword nimIdentDefKeyword       let
syn keyword nimKeyword       mixin using mod
syn keyword nimKeyword       not notin
syn keyword nimKeyword       object of or out
syn keyword nimIdentDefKeyword       proc method macro template nextgroup=nimFunction skipwhite
syn keyword nimKeyword       ptr
syn keyword nimKeyword       raise ref return
syn keyword nimKeyword       shared shl shr
syn keyword nimStaticKeyword  static
syn keyword nimKeyword       try tuple
syn keyword nimIdentDefKeyword       type nextgroup=nimTypename skipwhite
syn keyword nimIdentDefKeyword       var
syn keyword nimKeyword       with without
syn keyword nimKeyword       xor
syn keyword nimKeyword       yield

syn match   nimFunction      "[a-zA-Z_][a-zA-Z0-9_]*" contained
syn match   nimClass         "[a-zA-Z_][a-zA-Z0-9_]*" contained
syn match   nimTypename      "[a-zA-Z_][a-zA-Z0-9_]*" contained
syn keyword nimRepeat        while
syn keyword nimConditional   if elif else case of
syn keyword nimStaticConditional   when
syn keyword nimOperator      and in is not or xor shl shr div
syn match   nimComment       "#.*$" contains=nimTodo,@Spell
syn keyword nimTodo          TODO FIXME XXX contained
syn keyword nimBoolean       true false
syn keyword nimNil           nil

" Added by JB:
syn match   nimDotOperator   "\>[.]\<"
syn match   nimDerefOperator   "\m[[][]]\([.]\<\)\?"
syn match   nimDerefOperator   "[[][]]"
syn match   nimRangeOperator   "[.][.]\s*[<]"
syn match   nimColonOperator   "\m[:]\(\s*\<\|\_$\)"
syn match   nimSemicolonOperator   "\m[;]\(\s*\<\|\_$\)"



" Strings
syn region nimString start=+[^0-9._]\zs'+ skip=+\\\\\|\\'\|\\$+ excludenl end=+'+ end=+$+ keepend contains=nimEscape,nimEscapeError,@Spell
syn region nimString start=+"+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end=+$+ keepend contains=nimEscape,nimEscapeError,@Spell
syn region nimString start=+"""+ end=+"""+ keepend contains=nimEscape,nimEscapeError,@Spell
syn region nimRawString matchgroup=Normal start=+[rR]"+ end=+"+ skip=+\\\\\|\\"+ contains=@Spell

syn match  nimEscape		+\\[abfnrtv'"\\]+ contained
syn match  nimEscape		"\\\o\{1,3}" contained
syn match  nimEscape		"\\x\x\{2}" contained
syn match  nimEscape		"\(\\u\x\{4}\|\\U\x\{8}\)" contained
syn match  nimEscape		"\\$"

syn match nimEscapeError "\\x\x\=\X" display contained

if nim_highlight_numbers == 1
  " numbers (including longs and complex)
  syn match   nimNumber	"\v<0x\x+('[iIfFuU](8|16|32|64))?>"
  syn match   nimNumber	"\v<[0-9_]+('[iIfFuU](8|16|32|64))?>"
  syn match   nimNumber	"\v[0-9]\.[0-9_]+([eE][+-]=[0-9_]+)=>"
  syn match   nimNumber	"\v<[0-9_]+\.([0-9_]+)?([eE][+-]?[0-9_]+)?('(f|F)(32|64))?>"
endif

if nim_highlight_builtins == 1
  " builtin functions, types and objects, not really part of the syntax
  syn keyword nimBuiltin int int8 int16 int32 int64 uint uint8 uint16 uint32 uint64 float float32 float64 bool
  syn keyword nimBuiltin char string cstring pointer range array openarray seq
  syn keyword nimBuiltin set Byte Natural Positive TObject PObject Conversion TResult TAddress
  syn keyword nimBuiltin BiggestInt BiggestFloat cchar cschar cshort cint csize cuchar cushort
  syn keyword nimBuiltin clong clonglong cfloat cdouble clongdouble cuint culong culonglong cchar
  syn keyword nimBuiltin cstringArray TEndian PFloat32 PFloat64 PInt64 PInt32
"  syn keyword nimBuiltin TGC_Strategy TFile TFileMode TFileHandle isMainModule
"  syn keyword nimBuiltin CompileDate CompileTime nimVersion nimMajor
"  syn keyword nimBuiltin nimMinor nimPatch cpuEndian hostOS hostCPU inf
"  syn keyword nimBuiltin neginf nan QuitSuccess QuitFailure dbgLineHook stdin
"  syn keyword nimBuiltin stdout stderr defined new high low sizeof succ pred
"  syn keyword nimBuiltin inc dec newSeq len incl excl card ord chr ze ze64
"  syn keyword nimBuiltin toU8 toU16 toU32 abs min max add repr
"  syn match   nimBuiltin "\<contains\>"
"  syn keyword nimBuiltin toFloat toBiggestFloat toInt toBiggestInt addQuitProc
"  syn keyword nimBuiltin copy setLen newString zeroMem copyMem moveMem
"  syn keyword nimBuiltin equalMem alloc alloc0 realloc dealloc setLen assert
"  syn keyword nimBuiltin swap getRefcount getCurrentException Msg
"  syn keyword nimBuiltin getOccupiedMem getFreeMem getTotalMem isNil seqToPtr
"  syn keyword nimBuiltin find pop GC_disable GC_enable GC_fullCollect
"  syn keyword nimBuiltin GC_setStrategy GC_enableMarkAnd Sweep
"  syn keyword nimBuiltin GC_disableMarkAnd Sweep GC_getStatistics GC_ref
"  syn keyword nimBuiltin GC_ref GC_ref GC_unref GC_unref GC_unref quit
"  syn keyword nimBuiltin OpenFile OpenFile CloseFile EndOfFile readChar
"  syn keyword nimBuiltin FlushFile readFile write readLine writeln writeln
"  syn keyword nimBuiltin getFileSize ReadBytes ReadChars readBuffer writeBytes
"  syn keyword nimBuiltin writeChars writeBuffer setFilePos getFilePos
"  syn keyword nimBuiltin fileHandle countdown countup items lines
endif

if nim_highlight_exceptions == 1
  " builtin exceptions and warnings
  syn keyword nimException E_Base EAsynch ESynch ESystem EIO EOS
  syn keyword nimException ERessourceExhausted EArithmetic EDivByZero
  syn keyword nimException EOverflow EAccessViolation EAssertionFailed
  syn keyword nimException EControlC EInvalidValue EOutOfMemory EInvalidIndex
  syn keyword nimException EInvalidField EOutOfRange EStackOverflow
  syn keyword nimException ENoExceptionToReraise EInvalidObjectAssignment
  syn keyword nimException EInvalidObject EInvalidLibrary EInvalidKey
  syn keyword nimException EInvalidObjectConversion EFloatingPoint
  syn keyword nimException EFloatInvalidOp EFloatDivByZero EFloatOverflow
  syn keyword nimException EFloatInexact EDeadThread EResourceExhausted
  syn keyword nimException EFloatUnderflow
endif

if nim_highlight_space_errors == 1
  " trailing whitespace
  syn match   nimSpaceError   display excludenl "\S\s\+$"ms=s+1
  " any tabs are illegal in nim
  syn match   nimSpaceError   display "\t"
endif

syn sync match nimSync grouphere NONE "):$"
syn sync maxlines=200
syn sync minlines=2000

if version >= 508 || !exists("did_nim_syn_inits")
  if version <= 508
    let did_nim_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  " The default methods for highlighting.  Can be overridden later
  HiLink nimBrackets       Operator
  HiLink nimKeyword	      Keyword
  HiLink nimFunction	    	Function
  HiLink nimTypename	    	Typedef
  HiLink nimConditional	  Conditional
  HiLink nimRepeat		      Repeat
  HiLink nimString		      String
  HiLink nimRawString	    String
  HiLink nimBoolean        Boolean
  HiLink nimEscape		      Special
  HiLink nimOperator		    Operator
  HiLink nimPreCondit	    PreCondit
  HiLink nimComment		    Comment
  HiLink nimTodo		        Todo
  HiLink nimDecorator	    Define
  " Added by JB:
  HiLink nimDotOperator		    	    DotOperator
  HiLink nimDerefOperator	    	    DotOperator
  HiLink nimRangeOperator		    Operator
  HiLink nimColonOperator		    IdentDefOperator
  HiLink nimSemicolonOperator		    Delimiter
  HiLink nimIdentDefKeyword  		    IdentDefKeyword
  HiLink nimStaticKeyword		    StaticKeyword
  HiLink nimStaticConditional  		    StaticKeyword
  HiLink nimNil  		    Boolean

  if nim_highlight_numbers == 1
    HiLink nimNumber	Number
  endif
  
  if nim_highlight_builtins == 1
    HiLink nimBuiltin	Type
  endif
  
  if nim_highlight_exceptions == 1
    HiLink nimException	Exception
  endif
  
  if nim_highlight_space_errors == 1
    HiLink nimSpaceError	Error
  endif

  delcommand HiLink
endif

" Added by JB:
hi Function term=none ctermfg=Blue gui=none
hi Typedef term=none ctermfg=Blue gui=none
hi Keyword term=none ctermfg=Grey gui=none
hi Conditional term=none ctermfg=Grey gui=none
hi Repeat term=none ctermfg=Grey gui=none
hi Operator term=none ctermfg=Grey gui=none
hi DotOperator term=bold ctermfg=Cyan gui=bold
hi Delimiter term=none ctermfg=Red gui=none
hi StaticKeyword term=bold ctermfg=Yellow gui=bold
hi IdentDefOperator term=bold ctermfg=Green gui=bold
hi IdentDefKeyword term=bold ctermfg=Green gui=bold
hi String term=none ctermfg=DarkYellow gui=none
hi Number term=none ctermfg=DarkYellow gui=none
hi Boolean term=none ctermfg=DarkYellow gui=none
hi Type term=none ctermfg=Grey gui=none

let b:current_syntax = "nim"

