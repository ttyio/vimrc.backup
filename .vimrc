"Last modified: 2010/11/03 13:21:31

"set mapleader
let mapleader = ","

"VIM setting
set so=7     "Scroll when cursor is 7 lines from top/bottom of screen
set nu       "show number
set autoread
" set autochdir
set shortmess=atI       "no startup tip
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching
set nolinebreak             " break between words
set wrap
set cmdheight=1
set laststatus=2
set nobackup		" do not keep a backup file, use versions instead
set nowritebackup
set backspace=indent,eol,start           " allow backspacing over everything in insert mode
set nocompatible       "no compatible with vi
set wildmenu           "auto complete in enhanced command mode
set ic                "ignore case when search
set hlsearch
set noerrorbells      "no bell
set novisualbell      "no bell
set cindent
set showmatch          "show match {[()]}
set t_Co=256           "colors of vim used
set stal=2 "show table line
set statusline=file:\ %F%m%r%h\ %w\ \ dir:\ %r%{getcwd()}%h\ \ \ line:\ %l/%L:%c
" set hid
" set switchbuf=usetab
" set mouse=a

"theme
colorscheme banditEx

"syntax
syntax enable

"auto fold syntax
"set foldmethod=syntax
"set foldcolumn=3
"set foldclose=all
"set foldenable

"utf-8 encoding
set fenc=utf-8
set fencs=utf-8,usc-bom,gb18030,gbk,gb2312,default,latin1
set enc=utf-8
let &termencoding=&encoding

nmap <leader>w :w!<cr>
" nmap <leader>s :so ~/.vim/.vimrc<cr>
nmap <leader>q :q<cr>
nmap <silent> <leader>e :tabnew ~/.vim/.vimrc<cr>

map <leader>j <C-W><C-J>
map <leader>k <C-W><C-K>
map <leader>h <C-W><C-H>
map <leader>l <C-W><C-L>

nmap <right> :bn<cr>
nmap <left> :bp<cr>
nmap <leader>t :tabnew <C-R>=expand("%:p:h")."/" <CR>

"Remove the Windows ^M
noremap <silent> <leader>rm mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! VisualSearch() range
	let l:saved_reg = @"
	execute "normal! vgvy"
	let l:pattern = escape(@", '\\/.*$^~[]')
	let l:pattern = substitute(l:pattern, "\n$", "", "")
	execute "normal /" . l:pattern . "^M"
	let @/ = l:pattern
	let @" = l:saved_reg
endfunction

vnoremap <silent> <leader>ff :call VisualSearch()<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" project setting
command! InitProject call CommandInitProject()
func! CommandInitProject()
	call CommandCleanProject()
	call CommandSetupProjectEnv()
	call CommandBuildTags()
endfunc

command! CleanProject call CommandCleanProject()
func! CommandCleanProject()
	call system('rm -f cscope.*')
	call system('rm -f tags')
	call system('rm -f filenametags')
	call system('rm -f types_c.vim')
	call system('rm -f types_pl.vim')
endfunc

command! BuildTypes call CommandBuildTypes()
func! CommandBuildTypes()
	let l:OldCurDir = getcwd()
	exec 'cd ' . g:project_path
	exec 'WriteTypes'
	exec 'ReadTypes'
	exec 'cd ' . l:OldCurDir
endfunc

command! BuildTags call CommandBuildTags()
func! CommandBuildTags()
	let l:OldCurDir = getcwd()
	exec 'cd ' . g:project_path
	"cscope
	call system('cscope -Rbq')
	"lookup file
	call system('echo -e "!_TAG_FILE_SORTED\t2\t/2=foldcase/" > filenametags')
	call system('find . -regex ".*\.\(h\|hpp\|cpp\|c\)" -type f -printf "%f\t%p\t1\n" | sort -f >> filenametags')
	"ctags_highlighting
	call system("python ".expand('~/.vim/mktypes.py')." --ctags-dir=/usr/bin -r")
	"omni-cppcomplete
	call system("ctags -R --c++-kinds=+p --fields=+iaS --extra=+q")
	exec 'cd ' . l:OldCurDir
endfunc

func! CommandSetupProjectEnv()
	set tags+=./tags
	set path+=./**,/usr/include/**
	let g:project_path=getcwd()
	" let g:project_path=expand('%:p:h')
endfunc

if filereadable("./tags")
	call CommandSetupProjectEnv()
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"taglist plugin setting
let g:Tlist_Compact_Format=1
let g:Tlist_Show_One_File = 1
let g:Tlist_Exit_OnlyWindow = 1
let Tlist_Sort_Type = "order"
let Tlist_Display_Prototype = 0
let Tlist_Display_Tag_Scope = 1

"grep
nmap  <silent> <leader>ff :Grep<CR>

"word-complete setting
"au BufEnter * call DoWordComplete()

"netrw (Tree/File Explorer) setting
let g:netrw_winsize = 30
let g:treeExplVertical = 1
let g:treeExplWinSize = 30
nmap <silent> <leader>fe :Sexplore<cr>

"buffer explorer setting
let g:bufExplorerDefaultHelp=0       " Do not show default help.
let g:bufExplorerSortBy='mru'        " Sort by most recently used.
let g:bufExplorerSplitRight=0        " Split left.
let g:bufExplorerSplitVertical=1     " Split vertically.
let g:bufExplorerSplitVertSize = 30  " Split width
let g:bufExplorerUseCurrentWindow=1  " Open in new window.

"a setting
let g:alternateSearchPath = 'sfr:../source,sfr:../src,sfr:../include,sfr:../inc'
let g:alternateNoDefaultAlternate = 1  "no nav if file not exit
let g:alternateRelativeFiles = 1
nmap <silent> <F12> :A<cr>

"CSApprox setting
set t_Co=256

"winManager setting
" let g:winManagerWindowLayout = "BufExplorer,FileExplorer|TagList"
let g:winManagerWindowLayout = "FileExplorer|TagList"
let g:winManagerWidth = 30
let g:defaultExplorer = 0
nmap <silent> <leader>wm :WMToggle<cr>
nmap <silent> <F11> :wa<cr>:TlistUpdate<cr>:FirstExplorerWindow<cr><F5><c-w>b
au BufWinEnter \[Buf\ List\] setl nonumber
au BufWinEnter \[File\ List\] setl nonumber

"quickfix setting
nmap <F6> :cp<cr>
nmap <F8> :cn<cr>

"vimgdb setting
run macros/gdb_mappings.vim

"latex
" IMPORTANT: grep will sometimes skip displaying the file name if you
" search in a singe file. This will confuse Latex-Suite. Set your grep
" program to always generate a file-name.
set grepprg=grep\ -nH\ $*
" OPTIONAL: Starting with Vim 7, the filetype of empty .tex files defaults to
" 'plaintex' instead of 'tex', which results in vim-latex not being loaded.
" The following changes the default filetype back to 'tex':
let g:tex_flavor='latex'
let g:Tex_DefaultTargetFormat='pdf'



"omnicppcomplete
set completeopt=longest,menu
let OmniCpp_GlobalScopeSearch = 1
let OmniCpp_NamespaceSearch = 0
let OmniCpp_DisplayMode = 1
let OmniCpp_ShowScopeInAbbr = 0
let OmniCpp_ShowPrototypeInAbbr = 1
let OmniCpp_ShowAccess = 1
let OmniCpp_DefaultNamespaces = ["std"]
let OmniCpp_MayCompleteDot = 1
let OmniCpp_MayCompleteArrow = 1
let OmniCpp_MayCompleteScope = 0
let OmniCpp_SelectFirstItem = 0

"lookupfile setting
let g:LookupFile_MinPatLength = 2
let g:LookupFile_AlwaysAcceptFirst = 1
let g:LookupFile_AllowNewFiles = 0
let g:LookupFile_Ignorecase = 1
if filereadable("./filenametags")
	let g:LookupFile_TagExpr='"./filenametags"'
endif
nmap <silent> <leader>lk :LookupFile<cr>
nmap <silent> <leader>ll :LUBufs<cr>
nmap <silent> <leader>lw :LUWalk<cr>

"conque
nmap <silent> <leader>r :ConqueTerm bash<cr>

"cscope setting
set csprg=/usr/bin/cscope
set csto=0
set nocst
if filereadable("cscope.out")
	cs add cscope.out
endif
set csverb
set cscopequickfix=s-,c-,d-,i-,t-,e-

nmap <silent> <C-_> :cstag <C-R>=expand("<cword>")<CR><CR>
nmap <silent><C-_>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <silent><C-_>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <silent><C-_>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <silent><C-_>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <silent><C-_>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <silent><C-_>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <silent><C-_>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! LastModified()
	if &modified
		let save_cursor = getpos(".")
		let n = min([1, line("$")])
		exe '1,' . n . 's#^\(.\{,10}Last modified: \).*#\1' .
					\ strftime('%Y/%m/%d %H:%M:%S') . '#e'
		call setpos('.', save_cursor)
	endif
endfun
autocmd BufWritePre * call LastModified()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! GnuIndent()
	setlocal cinoptions=>4,n-2,{2,^-2,:2,=2,g0,h2,p5,t0,+2,(0,u0,w1,m1
	setlocal shiftwidth=2
	setlocal tabstop=8
endfunction

function! RemoveTrailingSpace()
	if $VIM_HATE_SPACE_ERRORS != '0' && (&filetype == 'c' || &filetype == 'cpp' || &filetype == 'vim')
		normal m`
		silent! :%s/\s\+$//e
		normal ``
	endif
endfunction

" Enable file type detection.
filetype on
filetype plugin on
filetype indent on

" Recognize C stype files
au FileType vim,c,cpp setlocal cinoptions=:0,g0,(0,w1 shiftwidth=4 tabstop=4 softtabstop=4
au FileType diff  setlocal shiftwidth=4 tabstop=4

" Recognize standard C++ headers
au BufEnter /usr/include/*  setf cpp
au BufEnter /usr/*  call GnuIndent()
au BufEnter * :syntax sync fromstart

" Remove trailing spaces
au BufWritePre *  call RemoveTrailingSpace()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis  | wincmd p | diffthis
endif
