" This is a stripped down version of syntax/tex.vim designed for latex
" math in markdown.
"

" Vim syntax file
" Language:	TeX
" Maintainer:	Charles E. Campbell <NdrchipO@ScampbellPfamily.AbizM>
" Last Change:	Dec 11, 2017
" Version:	107
" URL:		http://www.drchip.org/astronaut/vim/index.html#SYNTAX_TEX
"
" Notes: {{{1
"
" 1. If you have a \begin{verbatim} that appears to overrun its boundaries,
"    use %stopzone.
"
" 2. Run-on equations ($..$ and $$..$$, particularly) can also be stopped
"    by suitable use of %stopzone.
"
" 3. If you have a slow computer, you may wish to modify
"
"	syn sync maxlines=200
"	syn sync minlines=50
"
"    to values that are more to your liking.
"
" 4. There is no match-syncing for $...$ and $$...$$; hence large
"    equation blocks constructed that way may exhibit syncing problems.
"    (there's no difference between begin/end patterns)
"
" 5. If you have the variable "g:tex_no_error" defined then none of the
"    lexical error-checking will be done.
"
"    ie. let g:tex_no_error=1
"
" 6. Please see  :help latex-syntax  for information on
"      syntax folding           :help tex-folding
"      spell checking           :help tex-nospell
"      commands and mathzones   :help tex-runon
"      new command highlighting :help tex-morecommands
"      error highlighting       :help tex-error
"      new math groups          :help tex-math
"      new styles               :help tex-style
"      using conceal mode       :help tex-conceal

" Version Clears: {{{1
" quit when a syntax file was already loaded
if exists("b:current_syntax")
  finish
endif
let s:keepcpo= &cpo
set cpo&vim
scriptencoding utf-8

" by default, enable all region-based highlighting
let s:tex_fast= "bcmMprsSvV"
if exists("g:tex_fast")
 if type(g:tex_fast) != 1
  " g:tex_fast exists and is not a string, so
  " turn off all optional region-based highighting
  let s:tex_fast= ""
 else
  let s:tex_fast= g:tex_fast
 endif
endif

" let user determine which classes of concealment will be supported
"   a=accents/ligatures d=delimiters m=math symbols  g=Greek  s=superscripts/subscripts
if !exists("g:tex_conceal")
 let s:tex_conceal= 'abdmgsS'
else
 let s:tex_conceal= g:tex_conceal
endif
if !exists("g:tex_superscripts")
 let s:tex_superscripts= '[0-9a-zA-W.,:;+-<>/()=]'
else
 let s:tex_superscripts= g:tex_superscripts
endif
if !exists("g:tex_subscripts")
 let s:tex_subscripts= '[0-9aehijklmnoprstuvx,+-/().]'
else
 let s:tex_subscripts= g:tex_subscripts
endif

" Determine whether or not to use "*.sty" mode {{{1
" The user may override the normal determination by setting
"   g:tex_stylish to 1      (for    "*.sty" mode)
"    or to           0 else (normal "*.tex" mode)
" or on a buffer-by-buffer basis with b:tex_stylish
let s:extfname=expand("%:e")
if exists("g:tex_stylish")
 let b:tex_stylish= g:tex_stylish
elseif !exists("b:tex_stylish")
 if s:extfname == "sty" || s:extfname == "cls" || s:extfname == "clo" || s:extfname == "dtx" || s:extfname == "ltx"
  let b:tex_stylish= 1
 else
  let b:tex_stylish= 0
 endif
endif

" handle folding {{{1
if !exists("g:tex_fold_enabled")
 let s:tex_fold_enabled= 0
elseif g:tex_fold_enabled && !has("folding")
 let s:tex_fold_enabled= 0
 echomsg "Ignoring g:tex_fold_enabled=".g:tex_fold_enabled."; need to re-compile vim for +fold support"
else
 let s:tex_fold_enabled= 1
endif
if s:tex_fold_enabled && &fdm == "manual"
 setl fdm=syntax
endif
if s:tex_fold_enabled && has("folding")
 com! -nargs=* TexFold <args> fold 
else
 com! -nargs=* TexFold <args> 
endif

" (La)TeX keywords: uses the characters 0-9,a-z,A-Z,192-255 only... {{{1
" but _ is the only one that causes problems.
" One may override this iskeyword setting by providing
" g:tex_isk
if exists("g:tex_isk")
 if b:tex_stylish && g:tex_isk !~ '@'
  let b:tex_isk= '@,'.g:tex_isk
 else
  let b:tex_isk= g:tex_isk
 endif
elseif b:tex_stylish
 let b:tex_isk="@,48-57,a-z,A-Z,192-255"
else
 let b:tex_isk="48-57,a-z,A-Z,192-255"
endif
if v:version > 704 || (v:version == 704 && has("patch-7.4.1142"))
 exe "syn iskeyword ".b:tex_isk
else
 exe "setl isk=".b:tex_isk
endif
if exists("g:tex_no_error") && g:tex_no_error
 let s:tex_no_error= 1
else
 let s:tex_no_error= 0
endif
if exists("g:tex_comment_nospell") && g:tex_comment_nospell
 let s:tex_comment_nospell= 1
else
 let s:tex_comment_nospell= 0
endif
if exists("g:tex_nospell") && g:tex_nospell
 let s:tex_nospell = 1
else
 let s:tex_nospell = 0
endif

" Clusters: {{{1
" --------
syn cluster texCmdGroup			contains=texCmdBody,texComment,texDefParm,texDelimiter,texDocType,texInput,texLength,texLigature,texMathDelim,texMathOper,texNewCmd,texNewEnv,texRefZone,texSection,texBeginEnd,texBeginEndName,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,@texMathZones
if !s:tex_no_error
 syn cluster texCmdGroup		add=texMathError
endif
syn cluster texEnvGroup			contains=texMatcher,texMathDelim,texSpecialChar,texStatement
syn cluster texFoldGroup		contains=texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texInputFile,texLength,texLigature,texMatcher,texMathZoneV,texMathZoneW,texMathZoneX,texMathZoneY,texMathZoneZ,texNewCmd,texNewEnv,texOnlyMath,texOption,texParen,texRefZone,texSection,texBeginEnd,texSectionZone,texSpaceCode,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texZone,@texMathZones,texTitle,texAbstract,texBoldStyle,texItalStyle,texNoSpell
syn cluster texBoldGroup		contains=texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texInputFile,texLength,texLigature,texMatcher,texMathZoneV,texMathZoneW,texMathZoneX,texMathZoneY,texMathZoneZ,texNewCmd,texNewEnv,texOnlyMath,texOption,texParen,texRefZone,texSection,texBeginEnd,texSectionZone,texSpaceCode,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texZone,@texMathZones,texTitle,texAbstract,texBoldStyle,texBoldItalStyle,texNoSpell
syn cluster texItalGroup		contains=texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texInputFile,texLength,texLigature,texMatcher,texMathZoneV,texMathZoneW,texMathZoneX,texMathZoneY,texMathZoneZ,texNewCmd,texNewEnv,texOnlyMath,texOption,texParen,texRefZone,texSection,texBeginEnd,texSectionZone,texSpaceCode,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texZone,@texMathZones,texTitle,texAbstract,texItalStyle,texItalBoldStyle,texNoSpell
if !s:tex_nospell
 syn cluster texMatchGroup		contains=texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texLength,texLigature,texMatcher,texNewCmd,texNewEnv,texOnlyMath,texParen,texRefZone,texSection,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texZone,texInputFile,texOption,@Spell
 syn cluster texMatchNMGroup		contains=texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texLength,texLigature,texMatcherNM,texNewCmd,texNewEnv,texOnlyMath,texParen,texRefZone,texSection,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texZone,texInputFile,texOption,@Spell
 syn cluster texStyleGroup		contains=texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texLength,texLigature,texNewCmd,texNewEnv,texOnlyMath,texParen,texRefZone,texSection,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texZone,texInputFile,texOption,texStyleStatement,@Spell,texStyleMatcher
else
 syn cluster texMatchGroup		contains=texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texLength,texLigature,texMatcher,texNewCmd,texNewEnv,texOnlyMath,texParen,texRefZone,texSection,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texZone,texInputFile,texOption
 syn cluster texMatchNMGroup		contains=texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texLength,texLigature,texMatcherNM,texNewCmd,texNewEnv,texOnlyMath,texParen,texRefZone,texSection,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texZone,texInputFile,texOption
 syn cluster texStyleGroup		contains=texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texLength,texLigature,texNewCmd,texNewEnv,texOnlyMath,texParen,texRefZone,texSection,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texZone,texInputFile,texOption,texStyleStatement,texStyleMatcher
endif
syn cluster texPreambleMatchGroup	contains=texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texLength,texLigature,texMatcherNM,texNewCmd,texNewEnv,texOnlyMath,texParen,texRefZone,texSection,texSpecialChar,texStatement,texString,texTitle,texTypeSize,texTypeStyle,texZone,texInputFile,texOption,texMathZoneZ
syn cluster texRefGroup			contains=texMatcher,texComment,texDelimiter
if !exists("g:tex_no_math")
 syn cluster texPreambleMatchGroup	contains=texAccent,texBadMath,texComment,texDefCmd,texDelimiter,texDocType,texInput,texLength,texLigature,texMatcherNM,texNewCmd,texNewEnv,texOnlyMath,texParen,texRefZone,texSection,texSpecialChar,texStatement,texString,texTitle,texTypeSize,texTypeStyle,texZone,texInputFile,texOption,texMathZoneZ
 syn cluster texMathZones		contains=texMathZoneV,texMathZoneW,texMathZoneX,texMathZoneY,texMathZoneZ
 syn cluster texMatchGroup		add=@texMathZones
 syn cluster texMathDelimGroup		contains=texMathDelimBad,texMathDelimKey,texMathDelimSet1,texMathDelimSet2
 syn cluster texMathMatchGroup		contains=@texMathZones,texComment,texDefCmd,texDelimiter,texDocType,texInput,texLength,texLigature,texMathDelim,texMathMatcher,texMathOper,texNewCmd,texNewEnv,texRefZone,texSection,texSpecialChar,texStatement,texString,texTypeSize,texTypeStyle,texZone
 syn cluster texMathZoneGroup		contains=texComment,texDelimiter,texLength,texMathDelim,texMathMatcher,texMathOper,texMathSymbol,texMathText,texRefZone,texSpecialChar,texStatement,texTypeSize,texTypeStyle
 if !s:tex_no_error
  syn cluster texMathMatchGroup		add=texMathError
  syn cluster texMathZoneGroup		add=texMathError
 endif
 syn cluster texMathZoneGroup		add=@NoSpell
 " following used in the \part \chapter \section \subsection \subsubsection
 " \paragraph \subparagraph \author \title highlighting
 syn cluster texDocGroup		contains=texPartZone,@texPartGroup
 syn cluster texPartGroup		contains=texChapterZone,texSectionZone,texParaZone
 syn cluster texChapterGroup		contains=texSectionZone,texParaZone
 syn cluster texSectionGroup		contains=texSubSectionZone,texParaZone
 syn cluster texSubSectionGroup		contains=texSubSubSectionZone,texParaZone
 syn cluster texSubSubSectionGroup	contains=texParaZone
 syn cluster texParaGroup		contains=texSubParaZone
 if has("conceal") && &enc == 'utf-8'
  syn cluster texMathZoneGroup		add=texGreek,texSuperscript,texSubscript,texMathSymbol
  syn cluster texMathMatchGroup		add=texGreek,texSuperscript,texSubscript,texMathSymbol
 endif
endif

" Try to flag {} and () mismatches: {{{1
if s:tex_fast =~# 'm'
  if !s:tex_no_error
   syn region texMatcher	matchgroup=Delimiter start="{" skip="\\\\\|\\[{}]"	end="}"			transparent contains=@texMatchGroup,texError
   syn region texMatcher	matchgroup=Delimiter start="\["				end="]"			transparent contains=@texMatchGroup,texError,@NoSpell
   syn region texMatcherNM	matchgroup=Delimiter start="{" skip="\\\\\|\\[{}]"	end="}"			transparent contains=@texMatchNMGroup,texError
   syn region texMatcherNM	matchgroup=Delimiter start="\["				end="]"			transparent contains=@texMatchNMGroup,texError,@NoSpell
  else
   syn region texMatcher	matchgroup=Delimiter start="{" skip="\\\\\|\\[{}]"	end="}"			transparent contains=@texMatchGroup
   syn region texMatcher	matchgroup=Delimiter start="\["				end="]"			transparent contains=@texMatchGroup
   syn region texMatcherNM	matchgroup=Delimiter start="{" skip="\\\\\|\\[{}]"	end="}"			transparent contains=@texMatchNMGroup
   syn region texMatcherNM	matchgroup=Delimiter start="\["				end="]"			transparent contains=@texMatchNMGroup
  endif
  if !s:tex_nospell
   syn region texParen		start="("	end=")"								transparent contains=@texMatchGroup,@Spell
  else
   syn region texParen		start="("	end=")"								transparent contains=@texMatchGroup
  endif
endif
if !s:tex_no_error
 syn match  texError		"[}\])]"
endif
if s:tex_fast =~# 'M'
  if !exists("g:tex_no_math")
   if !s:tex_no_error
    syn match  texMathError	"}"	contained
   endif
   syn region texMathMatcher	matchgroup=Delimiter	start="{"          skip="\%(\\\\\)*\\}"     end="}" end="%stopzone\>"	contained contains=@texMathMatchGroup
  endif
endif

" TeX/LaTeX keywords: {{{1
" Instead of trying to be All Knowing, I just match \..alphameric..
" Note that *.tex files may not have "@" in their \commands
if exists("g:tex_tex") || b:tex_stylish
  syn match texStatement	"\\[a-zA-Z@]\+"
else
  syn match texStatement	"\\\a\+"
  if !s:tex_no_error
   syn match texError		"\\\a*@[a-zA-Z@]*"
  endif
endif

" TeX/LaTeX delimiters: {{{1
syn match texDelimiter		"&"
syn match texDelimiter		"\\\\"

" Type Styles (LaTeX 2.09): {{{1
syn match texTypeStyle		"\\rm\>"
syn match texTypeStyle		"\\em\>"
syn match texTypeStyle		"\\bf\>"
syn match texTypeStyle		"\\it\>"
syn match texTypeStyle		"\\sl\>"
syn match texTypeStyle		"\\sf\>"
syn match texTypeStyle		"\\sc\>"
syn match texTypeStyle		"\\tt\>"

" Type Styles: attributes, commands, families, etc (LaTeX2E): {{{1
if s:tex_conceal !~# 'b'
 syn match texTypeStyle		"\\textbf\>"
 syn match texTypeStyle		"\\textit\>"
endif
syn match texTypeStyle		"\\textmd\>"
syn match texTypeStyle		"\\textrm\>"
syn match texTypeStyle		"\\textsc\>"
syn match texTypeStyle		"\\textsf\>"
syn match texTypeStyle		"\\textsl\>"
syn match texTypeStyle		"\\texttt\>"
syn match texTypeStyle		"\\textup\>"
syn match texTypeStyle		"\\emph\>"

syn match texTypeStyle		"\\mathbb\>"
syn match texTypeStyle		"\\mathbf\>"
syn match texTypeStyle		"\\mathcal\>"
syn match texTypeStyle		"\\mathfrak\>"
syn match texTypeStyle		"\\mathit\>"
syn match texTypeStyle		"\\mathnormal\>"
syn match texTypeStyle		"\\mathrm\>"
syn match texTypeStyle		"\\mathsf\>"
syn match texTypeStyle		"\\mathtt\>"

syn match texTypeStyle		"\\rmfamily\>"
syn match texTypeStyle		"\\sffamily\>"
syn match texTypeStyle		"\\ttfamily\>"

syn match texTypeStyle		"\\itshape\>"
syn match texTypeStyle		"\\scshape\>"
syn match texTypeStyle		"\\slshape\>"
syn match texTypeStyle		"\\upshape\>"

syn match texTypeStyle		"\\bfseries\>"
syn match texTypeStyle		"\\mdseries\>"

" Some type sizes: {{{1
syn match texTypeSize		"\\tiny\>"
syn match texTypeSize		"\\scriptsize\>"
syn match texTypeSize		"\\footnotesize\>"
syn match texTypeSize		"\\small\>"
syn match texTypeSize		"\\normalsize\>"
syn match texTypeSize		"\\large\>"
syn match texTypeSize		"\\Large\>"
syn match texTypeSize		"\\LARGE\>"
syn match texTypeSize		"\\huge\>"
syn match texTypeSize		"\\Huge\>"

" Spacecodes (TeX'isms): {{{1
" \mathcode`\^^@="2201  \delcode`\(="028300  \sfcode`\)=0 \uccode`X=`X  \lccode`x=`x
syn match texSpaceCode		"\\\(math\|cat\|del\|lc\|sf\|uc\)code`"me=e-1 nextgroup=texSpaceCodeChar
syn match texSpaceCodeChar    "`\\\=.\(\^.\)\==\(\d\|\"\x\{1,6}\|`.\)"	contained

" particular support for bold and italic {{{1
if s:tex_fast =~# 'b'
  if s:tex_conceal =~# 'b'
   if !exists("g:tex_nospell") || !g:tex_nospell
    syn region texBoldStyle	matchgroup=texTypeStyle start="\\textbf\s*{" matchgroup=texTypeStyle  end="}" concealends contains=@texBoldGroup,@Spell
    syn region texBoldItalStyle	matchgroup=texTypeStyle start="\\textit\s*{" matchgroup=texTypeStyle  end="}" concealends contains=@texItalGroup,@Spell
    syn region texItalStyle	matchgroup=texTypeStyle start="\\textit\s*{" matchgroup=texTypeStyle  end="}" concealends contains=@texItalGroup,@Spell
    syn region texItalBoldStyle	matchgroup=texTypeStyle start="\\textbf\s*{" matchgroup=texTypeStyle  end="}" concealends contains=@texBoldGroup,@Spell
   else                                                                                              
    syn region texBoldStyle	matchgroup=texTypeStyle start="\\textbf\s*{" matchgroup=texTypeStyle  end="}" concealends contains=@texBoldGroup
    syn region texBoldItalStyle	matchgroup=texTypeStyle start="\\textit\s*{" matchgroup=texTypeStyle  end="}" concealends contains=@texItalGroup
    syn region texItalStyle	matchgroup=texTypeStyle start="\\textit\s*{" matchgroup=texTypeStyle  end="}" concealends contains=@texItalGroup
    syn region texItalBoldStyle	matchgroup=texTypeStyle start="\\textbf\s*{" matchgroup=texTypeStyle  end="}" concealends contains=@texBoldGroup
   endif
  endif
endif

" Bad Math (mismatched): {{{1
if !exists("g:tex_no_math") && !s:tex_no_error
 syn match texBadMath		"\\end\s*{\s*\(array\|bBpvV]matrix\|split\|smallmatrix\)\s*}"
 syn match texBadMath		"\\end\s*{\s*\(displaymath\|equation\|eqnarray\|math\)\*\=\s*}"
 syn match texBadMath		"\\[\])]"
endif

" Math Zones: {{{1
if !exists("g:tex_no_math")
 " TexNewMathZone: function creates a mathzone with the given suffix and mathzone name. {{{2
 "                 Starred forms are created if starform is true.  Starred
 "                 forms have syntax group and synchronization groups with a
 "                 "S" appended.  Handles: cluster, syntax, sync, and highlighting.
 fun! TexNewMathZone(sfx,mathzone,starform)
   let grpname  = "texMathZone".a:sfx
   let syncname = "texSyncMathZone".a:sfx
   if s:tex_fold_enabled
    let foldcmd= " fold"
   else
    let foldcmd= ""
   endif
   exe "syn cluster texMathZones add=".grpname
   if s:tex_fast =~# 'M'
    exe 'syn region '.grpname.' start='."'".'\\begin\s*{\s*'.a:mathzone.'\s*}'."'".' end='."'".'\\end\s*{\s*'.a:mathzone.'\s*}'."'".' keepend contains=@texMathZoneGroup'.foldcmd
    exe 'syn sync match '.syncname.' grouphere '.grpname.' "\\begin\s*{\s*'.a:mathzone.'\*\s*}"'
    exe 'syn sync match '.syncname.' grouphere '.grpname.' "\\begin\s*{\s*'.a:mathzone.'\*\s*}"'
   endif
   exe 'hi def link '.grpname.' texMath'
   if a:starform
    let grpname  = "texMathZone".a:sfx.'S'
    let syncname = "texSyncMathZone".a:sfx.'S'
    exe "syn cluster texMathZones add=".grpname
    if s:tex_fast =~# 'M'
     exe 'syn region '.grpname.' start='."'".'\\begin\s*{\s*'.a:mathzone.'\*\s*}'."'".' end='."'".'\\end\s*{\s*'.a:mathzone.'\*\s*}'."'".' keepend contains=@texMathZoneGroup'.foldcmd
     exe 'syn sync match '.syncname.' grouphere '.grpname.' "\\begin\s*{\s*'.a:mathzone.'\*\s*}"'
     exe 'syn sync match '.syncname.' grouphere '.grpname.' "\\begin\s*{\s*'.a:mathzone.'\*\s*}"'
    endif
    exe 'hi def link '.grpname.' texMath'
   endif
 endfun

 " Inline Math Zones: {{{2
 if s:tex_fast =~# 'M'
  if has("conceal") && &enc == 'utf-8' && s:tex_conceal =~# 'd'
   syn region texMathZoneV	matchgroup=Delimiter start="\\("			matchgroup=Delimiter	end="\\)\|%stopzone\>"			keepend concealends contains=@texMathZoneGroup
   syn region texMathZoneW	matchgroup=Delimiter start="\\\["			matchgroup=Delimiter	end="\\]\|%stopzone\>"			keepend concealends contains=@texMathZoneGroup
   syn region texMathZoneX	matchgroup=Delimiter start="\$" skip="\\\\\|\\\$"	matchgroup=Delimiter	end="\$"	end="%stopzone\>"		concealends contains=@texMathZoneGroup
   syn region texMathZoneY	matchgroup=Delimiter start="\$\$" 			matchgroup=Delimiter	end="\$\$"	end="%stopzone\>"	keepend concealends contains=@texMathZoneGroup
  else
   syn region texMathZoneV	matchgroup=Delimiter start="\\("			matchgroup=Delimiter	end="\\)\|%stopzone\>"			keepend contains=@texMathZoneGroup
   syn region texMathZoneW	matchgroup=Delimiter start="\\\["			matchgroup=Delimiter	end="\\]\|%stopzone\>"			keepend contains=@texMathZoneGroup
   syn region texMathZoneX	matchgroup=Delimiter start="\$" skip="\%(\\\\\)*\\\$"	matchgroup=Delimiter	end="\$"	end="%stopzone\>"		contains=@texMathZoneGroup
   syn region texMathZoneY	matchgroup=Delimiter start="\$\$" 			matchgroup=Delimiter	end="\$\$"	end="%stopzone\>"	keepend	contains=@texMathZoneGroup
  endif
  syn region texMathZoneZ	matchgroup=texStatement start="\\ensuremath\s*{"	matchgroup=texStatement	end="}"		end="%stopzone\>"	contains=@texMathZoneGroup
 endif

 syn match texMathOper		"[_^=]" contained

 " Text Inside Math Zones: {{{2
 if s:tex_fast =~# 'M'
  if !exists("g:tex_nospell") || !g:tex_nospell
   syn region texMathText matchgroup=texStatement start='\\\(\(inter\)\=text\|mbox\)\s*{'	end='}'	contains=@texFoldGroup,@Spell
  else
   syn region texMathText matchgroup=texStatement start='\\\(\(inter\)\=text\|mbox\)\s*{'	end='}'	contains=@texFoldGroup
  endif
 endif

 " \left..something.. and \right..something.. support: {{{2
 syn match   texMathDelimBad	contained		"\S"
 if has("conceal") && &enc == 'utf-8' && s:tex_conceal =~# 'm'
  syn match   texMathDelim	contained		"\\left\["
  syn match   texMathDelim	contained		"\\left\\{"	skipwhite nextgroup=texMathDelimSet1,texMathDelimSet2,texMathDelimBad contains=texMathSymbol cchar={
  syn match   texMathDelim	contained		"\\right\\}"	skipwhite nextgroup=texMathDelimSet1,texMathDelimSet2,texMathDelimBad contains=texMathSymbol cchar=}
  let s:texMathDelimList=[
     \ ['<'            , '<'] ,
     \ ['>'            , '>'] ,
     \ ['('            , '('] ,
     \ [')'            , ')'] ,
     \ ['\['           , '['] ,
     \ [']'            , ']'] ,
     \ ['\\{'          , '{'] ,
     \ ['\\}'          , '}'] ,
     \ ['|'            , '|'] ,
     \ ['\\|'          , '‖'] ,
     \ ['\\backslash'  , '\'] ,
     \ ['\\downarrow'  , '↓'] ,
     \ ['\\Downarrow'  , '⇓'] ,
     \ ['\\lbrace'     , '['] ,
     \ ['\\lceil'      , '⌈'] ,
     \ ['\\lfloor'     , '⌊'] ,
     \ ['\\lgroup'     , '⌊'] ,
     \ ['\\lmoustache' , '⎛'] ,
     \ ['\\rbrace'     , ']'] ,
     \ ['\\rceil'      , '⌉'] ,
     \ ['\\rfloor'     , '⌋'] ,
     \ ['\\rgroup'     , '⌋'] ,
     \ ['\\rmoustache' , '⎞'] ,
     \ ['\\uparrow'    , '↑'] ,
     \ ['\\Uparrow'    , '↑'] ,
     \ ['\\updownarrow', '↕'] ,
     \ ['\\Updownarrow', '⇕']]
  if &ambw == "double" || exists("g:tex_usedblwidth")
    let s:texMathDelimList= s:texMathDelimList + [
     \ ['\\langle'     , '〈'] ,
     \ ['\\rangle'     , '〉']]
  else
    let s:texMathDelimList= s:texMathDelimList + [
     \ ['\\langle'     , '<'] ,
     \ ['\\rangle'     , '>']]
  endif
  syn match texMathDelim	'\\[bB]igg\=[lr]' contained nextgroup=texMathDelimBad
  for texmath in s:texMathDelimList
   exe "syn match texMathDelim	'\\\\[bB]igg\\=[lr]\\=".texmath[0]."'	contained conceal cchar=".texmath[1]
  endfor

 else
  syn match   texMathDelim	contained		"\\\(left\|right\)\>"	skipwhite nextgroup=texMathDelimSet1,texMathDelimSet2,texMathDelimBad
  syn match   texMathDelim	contained		"\\[bB]igg\=[lr]\=\>"	skipwhite nextgroup=texMathDelimSet1,texMathDelimSet2,texMathDelimBad
  syn match   texMathDelimSet2	contained	"\\"		nextgroup=texMathDelimKey,texMathDelimBad
  syn match   texMathDelimSet1	contained	"[<>()[\]|/.]\|\\[{}|]"
  syn keyword texMathDelimKey	contained	backslash       lceil           lVert           rgroup          uparrow
  syn keyword texMathDelimKey	contained	downarrow       lfloor          rangle          rmoustache      Uparrow
  syn keyword texMathDelimKey	contained	Downarrow       lgroup          rbrace          rvert           updownarrow
  syn keyword texMathDelimKey	contained	langle          lmoustache      rceil           rVert           Updownarrow
  syn keyword texMathDelimKey	contained	lbrace          lvert           rfloor
 endif
 syn match   texMathDelim	contained		"\\\(left\|right\)arrow\>\|\<\([aA]rrow\|brace\)\=vert\>"
 syn match   texMathDelim	contained		"\\lefteqn\>"
endif

" Special TeX characters  ( \$ \& \% \# \{ \} \_ \S \P ) : {{{1
syn match texSpecialChar	"\\[$&%#{}_]"
if b:tex_stylish
  syn match texSpecialChar	"\\[SP@][^a-zA-Z@]"me=e-1
else
  syn match texSpecialChar	"\\[SP@]\A"me=e-1
endif
syn match texSpecialChar	"\\\\"
if !exists("g:tex_no_math")
 syn match texOnlyMath		"[_^]"
endif
syn match texSpecialChar	"\^\^[0-9a-f]\{2}\|\^\^\S"
if s:tex_conceal !~# 'S'
 syn match texSpecialChar	'\\glq\>'	contained conceal cchar=‚
 syn match texSpecialChar	'\\grq\>'	contained conceal cchar=‘
 syn match texSpecialChar	'\\glqq\>'	contained conceal cchar=„
 syn match texSpecialChar	'\\grqq\>'	contained conceal cchar=“
 syn match texSpecialChar	'\\hyp\>'	contained conceal cchar=-
endif

" Comments: {{{1
"    Normal TeX LaTeX     :   %....
"    Documented TeX Format:  ^^A...	-and-	leading %s (only)
if !s:tex_comment_nospell
 syn cluster texCommentGroup	contains=texTodo,@Spell
else
 syn cluster texCommentGroup	contains=texTodo,@NoSpell
endif
syn case ignore
syn keyword texTodo		contained		combak	fixme	todo	xxx
syn case match
if s:extfname == "dtx"
 syn match texComment		"\^\^A.*$"	contains=@texCommentGroup
 syn match texComment		"^%\+"		contains=@texCommentGroup
else
 if s:tex_fold_enabled
  " allows syntax-folding of 2 or more contiguous comment lines
  " single-line comments are not folded
  syn match  texComment	"%.*$"				contains=@texCommentGroup
  if s:tex_fast =~# 'c'
   TexFold syn region texComment						start="^\zs\s*%.*\_s*%"	skip="^\s*%"	end='^\ze\s*[^%]'	contains=@texCommentGroup
   TexFold syn region texNoSpell	contained	matchgroup=texComment	start="%\s*nospell\s*{"	end="%\s*nospell\s*}"			contains=@texFoldGroup,@NoSpell
  endif
 else
  syn match texComment		"%.*$"			contains=@texCommentGroup
  if s:tex_fast =~# 'c'
   syn region texNoSpell		contained	matchgroup=texComment start="%\s*nospell\s*{"	end="%\s*nospell\s*}"	contains=@texFoldGroup,@NoSpell
  endif
 endif
endif

" %begin-include ... %end-include acts like a texDocZone for \include'd files.  Permits spell checking, for example, in such files.
if !s:tex_nospell
 TexFold syn region texDocZone			matchgroup=texSection start='^\s*%begin-include\>'	 end='^\s*%end-include\>'											contains=@texFoldGroup,@texDocGroup,@Spell
else
 TexFold syn region texDocZone			matchgroup=texSection start='^\s*%begin-include\>'	 end='^\s*%end-include\>'											contains=@texFoldGroup,@texDocGroup
endif

" TeX Lengths: {{{1
syn match  texLength		"\<\d\+\([.,]\d\+\)\=\s*\(true\)\=\s*\(bp\|cc\|cm\|dd\|em\|ex\|in\|mm\|pc\|pt\|sp\)\>"

" TeX String Delimiters: {{{1
syn match texString		"\(``\|''\|,,\)"

" makeatletter -- makeatother sections
if !s:tex_no_error
 if s:tex_fast =~# 'S'
  syn region texStyle			matchgroup=texStatement start='\\makeatletter' end='\\makeatother'	contains=@texStyleGroup contained
 endif
 syn match  texStyleStatement		"\\[a-zA-Z@]\+"	contained
 if s:tex_fast =~# 'S'
  syn region texStyleMatcher		matchgroup=Delimiter start="{" skip="\\\\\|\\[{}]"	end="}"		contains=@texStyleGroup,texError	contained
  syn region texStyleMatcher		matchgroup=Delimiter start="\["				end="]"		contains=@texStyleGroup,texError	contained
 endif
endif

" LaTeX synchronization: {{{1
syn sync maxlines=200
syn sync minlines=50

syn  sync match texSyncStop			groupthere NONE		"%stopzone\>"

" Synchronization: {{{1
" The $..$ and $$..$$ make for impossible sync patterns
" (one can't tell if a "$$" starts or stops a math zone by itself)
" The following grouptheres coupled with minlines above
" help improve the odds of good syncing.
if !exists("g:tex_no_math")
 syn sync match texSyncMathZoneA		groupthere NONE		"\\end{abstract}"
 syn sync match texSyncMathZoneA		groupthere NONE		"\\end{center}"
 syn sync match texSyncMathZoneA		groupthere NONE		"\\end{description}"
 syn sync match texSyncMathZoneA		groupthere NONE		"\\end{enumerate}"
 syn sync match texSyncMathZoneA		groupthere NONE		"\\end{itemize}"
 syn sync match texSyncMathZoneA		groupthere NONE		"\\end{table}"
 syn sync match texSyncMathZoneA		groupthere NONE		"\\end{tabular}"
 syn sync match texSyncMathZoneA		groupthere NONE		"\\\(sub\)*section\>"
endif

" ---------------------------------------------------------------------
" Highlighting: {{{1

" Define the default highlighting. {{{1
if !exists("skip_tex_syntax_inits")

  " TeX highlighting groups which should share similar highlighting
  if !exists("g:tex_no_error")
   if !exists("g:tex_no_math")
    hi def link texBadMath		texError
    hi def link texMathDelimBad		texError
    hi def link texMathError		texError
    if !b:tex_stylish
      hi def link texOnlyMath		texError
    endif
   endif
   hi def link texError			Error
  endif

  hi texBoldStyle		gui=bold	cterm=bold
  hi texItalStyle		gui=italic	cterm=italic
  hi texBoldItalStyle		gui=bold,italic cterm=bold,italic
  hi texItalBoldStyle		gui=bold,italic cterm=bold,italic
  hi def link texCite		texRefZone
  hi def link texDefCmd		texDef
  hi def link texDefName	texDef
  hi def link texDocType	texCmdName
  hi def link texDocTypeArgs	texCmdArgs
  hi def link texInputFileOpt	texCmdArgs
  hi def link texInputCurlies	texDelimiter
  hi def link texLigature	texSpecialChar
  if !exists("g:tex_no_math")
   hi def link texMathDelimSet1	texMathDelim
   hi def link texMathDelimSet2	texMathDelim
   hi def link texMathDelimKey	texMathDelim
   hi def link texMathMatcher	texMath
   hi def link texAccent	texStatement
   hi def link texGreek		texStatement
   hi def link texSuperscript	texStatement
   hi def link texSubscript	texStatement
   hi def link texSuperscripts 	texSuperscript
   hi def link texSubscripts 	texSubscript
   hi def link texMathSymbol	texStatement
   hi def link texMathZoneV	texMath
   hi def link texMathZoneW	texMath
   hi def link texMathZoneX	texMath
   hi def link texMathZoneY	texMath
   hi def link texMathZoneV	texMath
   hi def link texMathZoneZ	texMath
  endif
  hi def link texBeginEnd	texCmdName
  hi def link texBeginEndName	texSection
  hi def link texSpaceCode	texStatement
  hi def link texStyleStatement	texStatement
  hi def link texTypeSize	texType
  hi def link texTypeStyle	texType

   " Basic TeX highlighting groups
  hi def link texCmdArgs	Number
  hi def link texCmdName	Statement
  hi def link texComment	Comment
  hi def link texDef		Statement
  hi def link texDefParm	Special
  hi def link texDelimiter	Delimiter
  hi def link texInput		Special
  hi def link texInputFile	Special
  hi def link texLength		Number
  hi def link texMath		Special
  hi def link texMathDelim	Statement
  hi def link texMathOper	Operator
  hi def link texNewCmd		Statement
  hi def link texNewEnv		Statement
  hi def link texOption		Number
  hi def link texRefZone	Special
  hi def link texSection	PreCondit
  hi def link texSpaceCodeChar	Special
  hi def link texSpecialChar	SpecialChar
  hi def link texStatement	Statement
  hi def link texString		String
  hi def link texTodo		Todo
  hi def link texType		Type
  hi def link texZone		PreCondit

endif

" Cleanup: {{{1
delc TexFold
unlet s:extfname
let   b:current_syntax = "fasttex"
let &cpo               = s:keepcpo
unlet s:keepcpo
" vim: ts=8 fdm=marker

