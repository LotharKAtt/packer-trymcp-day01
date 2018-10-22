syntax on
set t_Co=256
set background=dark
""" https://www.vim.org/scripts/script.php?script_id=945
au BufRead,BufNewFile *.groovy  setf groovy
if did_filetype()
  finish
endif
if getline(1) =~ '^#!.*[/\\]groovy\>'
  setf groovy
endif
""" https://raw.githubusercontent.com/Glench/Vim-Jinja2-Syntax/master/syntax/jinja.vim
au BufRead,BufNewFile *.jinja setfiletype jinja
au BufRead,BufNewFile *.sls setfiletype jinja
"""
au BufRead,BufNewFile *.lio setfiletype yaml
""" syntaxer
set ignorecase
set hlsearch
set nocompatible
set backspace=2
inoremap ^? ^H
set ruler
set showcmd
set gdefault
set nobackup
set nodigraph
set incsearch
set nojoinspaces
set laststatus=2
set tabstop=2
set bg=light
set bs=2

function! TrimWhiteSpace()
    %s/\s\+$//e
endfunction
highlight ExtraWhitespace ctermbg=darkgreen guibg=darkgreen
match ExtraWhitespace /\s\+$/
match ExtraWhitespace /\s\+\%#\@<!$/
match ExtraWhitespace /\s\+$/
autocmd ColorScheme * highlight WhiteSpaces gui=undercurl guifg=LightGray | match WhiteSpaces / \+/

set viminfo='10,\"100,:20,%,n~/.viminfo

" when we reload, tell vim to restore the cursor to the saved position
augroup JumpCursorOnEdit
 au!
 autocmd BufReadPost *
 \ if expand("<afile>:p:h") !=? $TEMP |
 \ if line("'\"") > 1 && line("'\"") <= line("$") |
 \ let JumpCursorOnEdit_foo = line("'\"") |
 \ let b:doopenfold = 1 |
 \ if (foldlevel(JumpCursorOnEdit_foo) > foldlevel(JumpCursorOnEdit_foo - 1)) |
 \ let JumpCursorOnEdit_foo = JumpCursorOnEdit_foo - 1 |
 \ let b:doopenfold = 2 |
 \ endif |
 \ exe JumpCursorOnEdit_foo |
 \ endif |
 \ endif
 " Need to postpone using "zv" until after reading the modelines.
 autocmd BufWinEnter *
 \ if exists("b:doopenfold") |
 \ exe "normal zv" |
 \ if(b:doopenfold > 1) |
 \ exe "+".1 |
 \ endif |
 \ unlet b:doopenfold |
 \ endif
augroup END

