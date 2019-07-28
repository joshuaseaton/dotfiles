"======"
" MISC "
"======"
set autoindent

" Enable modern Vim features not compatible with Vi spec.
set nocompatible


"===="
" UI "
"===="
syntax on
set number
colorscheme torte
set cursorline
set shortmess=a
set cmdheight=2


"========="
" SPACING "
"========="
set tabstop=2     " number of visual spaces per <TAB>
set shiftwidth=2
set softtabstop=0
set expandtab     " tabs are spaces

" Remove trailing whitespace on write.
autocmd BufWritePre * %s/\s\+$//e


"==========="
" SEARCHING "
"==========="
set incsearch   " search as characters are entered
set hlsearch    " highlight matches
set wildmenu    " visial auto-complete for command menu

" to turn off search highlighting
nnoremap <leader><space> :nohlsearch<CR>


"======"
" FILE "
"======"
filetype plugin indent on

" Enable auto-continuation of comments across newlines.
autocmd BufRead,BufNewFile * set formatoptions+=r

" Ensure that "gn" is a recognized filetype and set its syntax as python's,
" for lack of the actual option.
autocmd BufRead,BufNewFile *.gn,*.gni set filetype=gn syntax=python

" Autoformat code based on file type.
augroup autoformat
  autocmd FileType c,cpp AutoFormatBuffer clang-format
  autocmd FileType dart AutoFormatBuffer dartfmt
  autocmd FileType gn AutoFormatBuffer gn
  autocmd FileType go AutoFormatBuffer gofmt
  autocmd FileType python AutoFormatBuffer yapf
augroup END

" Auto-populate a bash shebang in shell files.
autocmd BufNewFile *.sh call io#InsertText("#!/bin/bash\n")

" Enable auto-population of license headers in new files.
source ~/.vim/lib/license.vim
