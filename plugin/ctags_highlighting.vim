" ctags_highlighting
"   Author:  A. S. Budden
"## Date::   17th August 2009        ##
"## RevTag:: r309                    ##

if &cp || exists("g:loaded_ctags_highlighting")
	finish
endif

let g:loaded_ctags_highlighting = 1
if !exists('g:VIMFILESDIR')
	let g:VIMFILESDIR = $HOME . "/.vim/"
endif

" load the types_*.vim highlighting file, if it exists
autocmd BufRead,BufNewFile *.[ch]   call ReadTypes('c')
autocmd BufRead,BufNewFile *.[ch]pp call ReadTypes('c')
" autocmd BufRead,BufNewFile *.p[lm]  call ReadTypes('pl')
" autocmd BufRead,BufNewFile *.java   call ReadTypes('java')
" autocmd BufRead,BufNewFile *.py     call ReadTypes('py')
" autocmd BufRead,BufNewFile *.pyw    call ReadTypes('py')
" autocmd BufRead,BufNewFile *.rb     call ReadTypes('ruby')
" autocmd BufRead,BufNewFile *.vhd*   call ReadTypes('vhdl')
" autocmd BufRead,BufNewFile *.php    call ReadTypes('php')

" autocmd BufWritePost       *.[ch]   exec 'WriteTypes'
" autocmd BufWritePost       *.[ch]pp exec 'WriteTypes'
let b:TypesFileLanguages = "c"
let b:TypesFileIncludeLocals = 1

command! ReadTypes  call ReadTypesAutoDetect()
command! WriteTypes call UpdateTypesFile(1,0)

function! ReadTypesAutoDetect()
	let extension = expand('%:e')
	let extensionLookup =
				\ {
				\     '[ch]\(pp\)\?' : "c",
				\     'p[lm]'        : "pl",
				\     'java'         : "java",
				\     'pyw\?'        : "py",
				\     'rb'           : "ruby",
				\     'php'          : "php",
				\     'vhdl\?'       : "vhdl",
				\ }

	for key in keys(extensionLookup)
		let regex = '^' . key . '$'
		if extension =~ regex
			call ReadTypes(extensionLookup[key])
			continue
		endif
	endfor
endfunction

function! ReadTypes(suffix)
	" Open project tags
        if exists('g:project_path')
		let pname= g:project_path . '/types_' . a:suffix . '.vim'
		if filereadable(pname)
			exe 'so ' . pname
		endif
	endif

	" Open pre-build include file tags
	if exists('g:library_type_path')
		exe 'so' . g:library_type_path
	endif
endfunction

func! UpdateTypesFile(recurse, skiptags)
	let s:vrc = globpath(&rtp, "mktypes.py")

	if type(s:vrc) == type("")
		let mktypes_py_file = s:vrc
	elseif type(s:vrc) == type([])
		let mktypes_py_file = s:vrc[0]
	endif

	let sysroot = 'python ' . shellescape(mktypes_py_file)
	let syscmd = ' --ctags-dir='

	let path = substitute($PATH, ':', ',', 'g')
	let ctags_exe = split(globpath(path, 'ctags'))[0]
	if filereadable(ctags_exe)
		let ctags_path = fnamemodify(ctags_exe, ':p:h')
	else
		throw "Cannot find ctags"
	endif

	let syscmd .= ctags_path

	if exists('b:TypesFileRecurse')
		if b:TypesFileRecurse == 1
			let syscmd .= ' -r'
		endif
	else
		if a:recurse == 1
			let syscmd .= ' -r'
		endif
	endif

	if exists('b:TypesFileLanguages')
		for lang in b:TypesFileLanguages
			let syscmd .= ' --include-language=' . lang
		endfor
	endif

	if exists('b:TypesFileIncludeSynMatches')
		if b:TypesFileIncludeSynMatches == 1
			let syscmd .= ' --include-invalid-keywords-as-matches'
		endif
	endif

	if exists('b:TypesFileIncludeLocals')
		if b:TypesFileIncludeLocals == 1
			let syscmd .= ' --include-locals'
		endif
	endif

	if exists('b:TypesFileDoNotGenerateTags')
		if b:TypesFileDoNotGenerateTags == 1
			let syscmd .= ' --use-existing-tagfile'
		endif
	elseif a:skiptags == 1
		let syscmd .= ' --use-existing-tagfile'
	endif

	if exists('b:CheckForCScopeFiles')
		if b:CheckForCScopeFiles == 1
			let syscmd .= ' --build-cscopedb-if-cscope-file-exists'
			let syscmd .= ' --cscope-dir='
			let path = substitute($PATH, ':', ',', 'g')

			let cscope_exe = split(globpath(path, 'cscope'))[0]
			if filereadable(cscope_exe)
				let cscope_path = fnamemodify(cscope_exe, ':p:h')
			else
				throw "Cannot find cscope"
			endif
			let syscmd .= cscope_path
		endif
	endif

	call system(sysroot . syscmd)

endfunc

