execute pathogen#infect()

syntax on

set ic
set expandtab
set tabstop=2
set shiftwidth=2
set autoindent
set number
set hlsearch
set hidden

colors torte
colorscheme desert

set nocompatible 
if has("autocmd") 
  filetype indent plugin on 
endif 

filetype plugin on

set cursorline

au BufNewFile,BufRead *.skim set filetype=slim

call pathogen#infect()
