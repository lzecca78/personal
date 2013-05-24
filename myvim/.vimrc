" Pathogen
filetype off " Pathogen needs to run before plugin indent on
call pathogen#incubate()
call pathogen#helptags() " generate helptags for everything in 'runtimepath'
filetype plugin indent on


set background=dark
let g:solarized_termtrans=1
let g:solarized_termcolors=256
let g:solarized_contrast="high"
let g:solarized_visibility="high"
colorscheme solarized

set runtimepath^=~/.vim/bundle/ctrlp
let g:syntastic_mode_map={'mode':'active', 'active_filetypes':[], 'passive_filetypes':['html']}
8
let g:syntastic_phpcs_disable=1
let g:Powerline_symbols='fancy'

set expandtab tabstop=4 shiftwidth=4 softtabstop=4
set incsearch
set hlsearch
set ignorecase
set smartcase
set encoding=utf-8
set showcmd
set comments=sr:/*,mb:*,ex:*/
set wildmenu
set wildmode=longest,full
set wildignore=.svn,.git
set nocompatible
set laststatus=2

