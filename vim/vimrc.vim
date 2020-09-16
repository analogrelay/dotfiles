set nocompatible
syntax on

" Enable vim-plug
call plug#begin('~/.vim/plugged')

" Add plugins here!
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'fatih/vim-go'

call plug#end()

" FZF config
map <C-p> :FZF<enter>
