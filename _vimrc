
" ENVIRONMENT VARS
" LLVM_DIR
filetype plugin on
"Plugins{{{
"download vimplug and put in autoload directory
call plug#begin('~/vimfiles/plugged')
    Plug 'scrooloose/nerdtree'
    Plug 'udalov/kotlin-vim'
    Plug 'vim-jp/vim-cpp'
    Plug 'ctrlpvim/ctrlp.vim'
    Plug 'majutsushi/tagbar'
    Plug 'danielwe/base16-vim'
    Plug 'scrooloose/nerdcommenter'
    Plug 'mhinz/vim-startify'
call plug#end()
"}}}

set go-=r
set ffs=unix,dos
let &statusline="\ \ \ \ %{expand('%:p:h')}\\"
set stl+=%#FileNameHL#
set stl+=%t
set stl+=%#StatusLine#
set stl+=\ Buf:%n
set statusline+=%=
set statusline+=%m\ chr=0x%02.2B\ byte_no=%o\ L=%l\ C=%c\ [%p%%]
set titlestring=%F\ %m[%p%%]
syntax on
set mousefocus

let g:NERDCustomDelimiters = { 'dosini': { 'left':'#'} }
"Variables
let LLVM_DIR = $LLVM_DIR

"Notes {{{
"
"q: -- enter command window
"
"C-l for refreshing the screen
"
"redir @* | set guifont? | redir END
"
"For easier diffing execute these in corresponding splits
"   ;set cursorbind
"   :set scrollbind 
"}}}
vnoremap <leader>" <esc>`<i"<esc>`>a"<esc>
nnoremap <leader>" viw<esc>a"<esc>bi"<esc>lel

iabbrev #i #include <><left>
set autoread
if has('gui_running')
    set cursorline
endif
let g:tagbar_show_linenumbers=1
let NERDTreeShowLineNumbers=1
let NERDTreeChDirMode=2
set undofile
" TODO: fix this
if has("unix")
    set undodir=$USERPROFILE/.vimundodir
    set dir=$USERPROFILE/.vimswap
    set backupdir=$USERPROFILE/.vimbackups
    silent ":!mkdir -p " . dir
    silent ":!mkdir -p " . undodir
    silent ":!mkdir -p " . backupdir
else
    set undodir=$USERPROFILE\.vimundodir
    set dir=$USERPROFILE\.vimswap
    set backupdir=$USERPROFILE\.vimbackups
    silent ":!md  " . &dir
    silent ":!md  " . &undodir
    silent ":!md  " . &backupdir
endif
let extension = expand('%:e')
if extension == "py"
    set foldmethod=indent
else
    set foldmethod=syntax
endif
if has("gui_running")
    colorscheme base16-gruvbox-dark-soft
    if has("win32")
        set rop=type:directx
        "This is a workaround for window size change when sourcing vimrc
        "i.e. we only set font if it is not already set (on a startup)
        let font = execute('set guifont?')
        let font = substitute(substitute(font, '\n', '', ''), ' \+guifont', 'guifont', '')
        if font != "guifont=Hack:h15:cANSI"
            set guifont=Hack:h15:cANSI
        endif
    endif
endif
set encoding=utf-8 "needed to display cyrillic chars
hi FileNameHL guibg=#b8bb26 guifg=#3c3836
set hidden
noremap <C-j> :bp <CR>
noremap <C-k> :bn <CR>
command! W w
command! Q qall 
let mapleader = " " "space

"guiopts {{{ 
set guioptions-=T            " Remove toolbar
set guioptions-=m            " Remove menu
set guioptions+=c            " Use console for simple choices
set guioptions-=r            " remove right scrollbar
set guioptions-=L            " Remove left scrollbar
"}}}

set smarttab
set smartindent
set tabstop=4
set shiftwidth=4
set virtualedit=block
set shiftround
set nu rnu
set ls=2
set hlsearch
"set expandtab
set incsearch
set scrolloff=99999
au BufRead * silent! lcd %:p:h | set tag=tags;/
au GUIEnter * simalt ~x  
ino <C-C> <Esc>
au FocusLost * silent! :w
set autochdir
set formatoptions=qrn1
set colorcolumn=79
set display+=lastline      " Show as much as possible of the lsat line

"Compilation/building {{{
function! CompileCppFile()
    silent w

    if has("win32")
			!"C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\bin\amd64_x86\vcvarsamd64_x86.bat" && cl.exe % /nologo /Fa%:r.exe 2>quickfixerrorfile
			"/Fo %:r.exe
			"silent !g++ % -march=native -g3 -O0 --std=c++1z -Werror -Wall -pedantic -o %:r.exe 2>quickfixerrorfile
	else
		if $HAS_GCC
			silent !g++ % -march=native -g3 -O0 --std=c++1z -Werror -Wall -pedantic -o %:r.exe 2>quickfixerrorfile
		else
			silent !clang++ % -march=native -Xclang -flto-visibility-public-std -g3 -O0 --std=c++1z -Werror -Wall -Wno-format-security -pedantic -o %:r.exe 2>quickfixerrorfile
		endif
    endif
    silent cfile quickfixerrorfile
    if !empty(readfile("quickfixerrorfile"))
        let g:quickfix_return_to_window = winnr()
        copen
        execute g:quickfix_return_to_window . "wincmd w"
        let g:quickfix_is_open = 1
    else
        silent !rd quickfixerrorfile
        echo "No errors found."
        cclose
        let g:quickfix_is_open = 0
        !%:r
    endif
    silent !rm quickfixerrorfile
endfunction
function! CompilePython()
    silent w
    :!python % 
endfunction
function! CompileKotlin()
    silent w
    :!kotlinc % -include-runtime -d %:r.jar && java -jar %:r.jar
    ":!java -jar %:r.jar
endfunction

function! RunKotlin()
    silent w
    :!kotlinc -script % 
endfunction

function! CompilePythonWithParam()
    silent w
    let f = input ("arg: ")
    :exec "!python % " . f
endfunction

function! RunBatWithParam()
    silent w
    let f = input ("arg: ")
    :exec "!% " . f
endfunction

function! RunPythonInterp()
    silent w
    :!python -i %
endfunction

function! PandocConv()
    :silent exec "!pandoc % -s --toc --toc-depth=4 --css pandoc.css -f gfm -o %:r.md.html" 
endfunction

function! IsNERDTreeOpen()        
    return exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
endfunction

function! SyncTree()
    if &modifiable && IsNERDTreeOpen() && strlen(expand('%')) > 0 && !&diff
        NERDTreeFind
        wincmd p
    endif
endfunction

set splitbelow
function! CppOutFinished(channel)
    ccl
    execute "10sp " . g:outName
    normal G
    if line('$') == 1 && getline(1) == ''
        bd
        echo 'Finished'
    endif
endfunction

function! CompileCppAsyncFinished(channel)
    execute "cfile " . g:backgroundCommandOutput
    copen
    unlet g:backgroundCommandOutput
    if line('$') == 1 && getline(1) == ''
        bd
        let g:outName = tempname() . "_OUT"
        call job_start( g:execname, {'close_cb': 'CppOutFinished', "out_io":"file", 'out_name':g:outName})
    else
        call feedkeys("\<C-w>\<C-p>")
    endif
endfunction

function! GetBufferList()
    return filter(range(1,bufnr('$')), 'buflisted(v:val)')
endfunction

function! GetMatchingBuffers(pattern)
    return filter(GetBufferList(), 'bufname(v:val) =~ a:pattern')
endfunction

function! WipeMatchingBuffers(pattern)
    let l:matchList = GetMatchingBuffers(a:pattern)

    let l:count = len(l:matchList)
    if l:count < 1
        "echo 'No buffers found matching pattern ' . a:pattern
        return
    endif

    exec 'bw ' . join(l:matchList, ' ')

    "echo 'Wiped ' . l:count . ' buffer' . l:suffix . '.'
endfunction

function! CompileCppBuildBatAsyncFinished(job, exit_status)
    execute "cfile " . g:backgroundCommandOutput
    copen
    if line('$') == 1 && getline(1) == ''
        bd
        echom g:backgroundCommandOutputBatFile
        execute "10sp " . g:backgroundCommandOutputBatFile
        normal G
        if line('$') == 1 && getline(1) == ''
            bd
            echo 'Finished'
        else
            execute ":e ++ff=dos"
        endif

    else
        call feedkeys("\<C-w>\<C-p>")
    endif
    unlet g:backgroundCommandOutput
    unlet g:backgroundCommandOutputBatFile
endfunction

function! FindInUpperDir(filename)
    let prev_cwd = getcwd()
    let saved_cwd = getcwd()
    while !filereadable(a:filename)
        cd ../
        if prev_cwd == getcwd()
            break
        endif
        let prev_cwd = getcwd()
    endwhile
    let found = getcwd() 
    execute "cd " . saved_cwd
    if filereadable(found . '/' . a:filename)
        return found
    else
        return ''
    endif
endfunction

function! CompileCppBuildBatAsync()
    if v:version < 800
        echoerr 'Async compilation requires VIM version 8 or higher'
        return
    endif

    call WipeMatchingBuffers(".*tmp_OUT$")

    let script_name = 'build.bat'
    let script_dir = FindInUpperDir(script_name)
    if !filereadable(script_dir . '/' . script_name)
        echo "No build.bat is found"
        return
    endif

    if exists('g:backgroundCommandOutput') || exists('g:backgroundCommandOutputBatFile')
        echo 'Already compiling in background'
    else
        echo 'Compiling...'
        let g:backgroundCommandOutput = tempname() . "_OUT"
        let g:backgroundCommandOutputBatFile = tempname() . "_OUT"
        let g:job = job_start([script_dir . '/' . script_name], {'exit_cb': 'CompileCppBuildBatAsyncFinished', "out_io":"file", "out_name":g:backgroundCommandOutputBatFile, "err_io":"file", 'err_name':g:backgroundCommandOutput, 'cwd':script_dir})
        execute "cd " . script_dir
        let job_status = job_status(g:job)
        if job_status == 'fail'
            unlet g:backgroundCommandOutput
            unlet g:backgroundCommandOutputBatFile
            echom "Job start failed!"
        endif
    endif
endfunction

func! StopJob() 
    call job_stop(g:job)
    echo "Job stopped"
endfunc

function! CompileCppAsync()
    silent w
    if v:version < 800
        echoerr 'Async compilation requires VIM version 8 or higher'
        return
    endif

    call WipeMatchingBuffers(".*tmp_OUT$")
    if exists('g:backgroundCommandOutput')
        echo 'Already compiling in background'
    else
        echo 'Compiling...'
        let g:backgroundCommandOutput = tempname() . "_OUT"

        if $HAS_GCC
            let l:compiler = "g++"
            let l:compiler_specific_opts = []
        else
            let l:compiler = "clang++"
            let l:compiler_specific_opts = ['-Xclang', '-flto-visibility-public-std']
        endif
        let g:filename = expand('%')
        let g:execname = expand('%:r') . ".exe"
        let l:lst = [l:compiler, g:filename, '-march=native', '-g3', '-O0', '--std=c++17', '-Werror', '-Wall', '-Wno-format-security', '-pedantic', '-o', g:execname]
        for el in l:compiler_specific_opts
            call add(l:lst, el)
        endfor
        call job_start(l:lst, {'close_cb': 'CompileCppAsyncFinished', "err_io":"file", 'err_name':g:backgroundCommandOutput})
    endif
endfunction
function! CompileWithTerminal()
    if v:version < 800
        echoerr 'Async compilation requires VIM version 8 or higher'
        return
    endif

    let script_name = 'build.bat'
    let script_dir = FindInUpperDir(script_name)
    if !filereadable(script_dir . '/' . script_name)
        echo "No build.bat is found"
        return
    endif
    execute ("!cd " . script_dir . ' && ' . script_name)
endfunction
"}}}

nnoremap <C-F10> :call CompileWithTerminal()<CR>
nnoremap <F10> :call CompileCppBuildBatAsync()<CR>
nnoremap <F11> :call StopJob()<CR>


augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END

augroup Build
    autocmd!
    autocmd BufEnter *.bat nnoremap <buffer> <F5> :!% <CR>
    autocmd BufEnter *.bat nnoremap <buffer> <F6> :call RunBatWithParam() <CR>
    autocmd BufEnter *.cpp nnoremap <buffer> <F5> :call CompileCppFile()<CR>
    autocmd BufEnter *.cpp nnoremap <buffer> <F6> :!build.bat<CR>
    autocmd BufEnter *.cpp nnoremap <buffer> <F9> :call CompileCppAsync()<CR>
    autocmd BufEnter *.py nnoremap  <buffer> <F5> :call CompilePython() <CR>
    autocmd BufEnter *.py nnoremap  <buffer> <F6> :call CompilePythonWithParam() <CR>
    autocmd BufEnter *.dot nnoremap <buffer> <F5> :!dot -Tpng % -o %:r.png <CR>
    autocmd BufEnter *.kt nnoremap  <buffer> <F5> :call CompileKotlin() <CR>
    autocmd BufEnter *.kts nnoremap  <buffer> <F5> :call RunKotlin() <CR>
    "requires pandoc and TamperMonkey
    "Use this script in TamperMonkey:
    "// ==UserScript==
    "// @name         New Userscript
    "// @namespace    http://tampermonkey.net/
    "// @version      0.1
    "// @description  try to take over the world!
    "// @author       You
    "// @match        http://*/*
    "// @grant        none
    "// ==/UserScript==
    "
    "(function() {
    "    'use strict';
    "setTimeout(function(){
    "   window.location.reload(1);
    "}, 500);
    "    // Your code here...
    "})();
    "And put this filter into User includes:  file//*.md.html
    "And Exclude http://*//
    autocmd BufWritePost *.md :call PandocConv() 
augroup END

function! QuickfixToggle()
    if g:quickfix_is_open
        cclose
        let g:quickfix_is_open = 0
        execute g:quickfix_return_to_window . "wincmd w"
    else
        let g:quickfix_return_to_window = winnr()
        copen
        execute g:quickfix_return_to_window . "wincmd w"
        let g:quickfix_is_open = 1
    endif
endfunction
set path+=**
set wildmenu
let NERDTreeWinSize=25
function! FormatFile()
    let FMT = g:LLVM_DIR . "/share/clang/clang-format.py"
    let l:lines="all"
    :execute("py3f " . FMT)
endfunction
noremap <M-i>  :call FormatFile()<CR>
setlocal foldmethod=expr foldexpr=DiffFold(v:lnum)
function! DiffFold(lnum)
    let line = getline(a:lnum)
    if line =~ '^\(diff\|---\|+++\|@@\) '
        return 1
    elseif line[0] =~ '[-+ ]'
        return 2
    else
        return 0
    endif
endfunction
function! CheckHeaderSource()
    if expand("%:e") == "cpp"
        let exts = ["h", "hpp"]
        let fldrs = ["Inc", "inc", "include"]
    else
        let exts = ["c", "cpp"]
        let fldrs = ["Src", "src", "source"]
    endif

    for fldr in fldrs
        for ext in exts
            let l_fname = expand('%:r')
            let here = expand('%:p:h') . "/" . l_fname . "." . ext
            let there = expand('%:p:h') . "/../" . fldr . "/" . l_fname . "." . ext
            "TODO: use substitute
            if filereadable(here)
                execute "e " . here
            elseif filereadable(there)
                execute "e " . there
            endif
        endfor
    endfor
endfunction

function! TTakeInput()
    let f = input ("Exec: ")
    :exec  ":!python -c \"print(".f.")\""
endfunction
function! EnterNotes()
    silent e $USERPROFILE/notes.txt 
    :execute "normal G"
    :put = strftime('%c') 
    :put = strftime('-------------------') 
    :execute "normal! o"
    :startinsert!
endfunction

noremap <C-S-F2> :execute "!start ." <CR>
noremap <C-F2> :!start cmd.exe <CR> 
noremap <F2> :terminal <CR> 
"use Ctrl-w-c to close the terminal
nnoremap <C-F3> :noh<CR>
nnoremap <F3> :call RunPythonInterp() <CR>
noremap <F4> :call CheckHeaderSource() <CR>
noremap <F6> :call TTakeInput() <CR>
noremap <F7> :call EnterNotes() <CR>
noremap <BS> 5k
noremap <Space> 5j
vnoremap . :norm.<CR>
nnoremap <C-Tab> gt
nnoremap <C-S-Tab> gT
nnoremap j gj
nnoremap k gk
nnoremap <leader>l :ls<CR>:b<space>
nnoremap <leader>bd :ls<CR>:bd<left><left>
nnoremap <left> :cp <CR>
nnoremap <right> :cn <CR>
nnoremap <C-t> :NERDTreeToggle .<CR>
noremap <C-F11> :NERDTreeFind <CR>
nnoremap <leader>ev :e $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>
nmap <F8> :TagbarToggle<CR>
noremap <C-s> :w <CR>
imap <C-s> <Esc>:w<CR>VA

let g:ctrlp_working_path_mode = 'ra'
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.svn,
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
if executable('rg')
    set grepprg=rg\ --color=never
    let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
    let g:ctrlp_use_caching = 0
endif
let g:ctrlp_extensions = ['tag', 'buffertag']
let g:ctrlp_root_markers = ['.svn']

set langmap=ёйцукенгшщзхъфывапролджэячсмитьбюЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ;`qwertyuiop[]asdfghjkl\\;'zxcvbnm\\,.~QWERTYUIOP{}ASDFGHJKL:\\"ZXCVBNM<>
set listchars=space:·,tab:→\  
set list
highlight SpecialKey ctermfg=8 guifg=DimGrey


set ve=all
set belloff=all
nnoremap <leader>p :put = strftime('%H:%M')<CR>
