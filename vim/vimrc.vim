set nocompatible
syntax on

" Enable vim-plug
call plug#begin('~/.vim/plugged')

" Add plugins here!
Plug 'scrooloose/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'fatih/vim-go'
Plug 'jremmen/vim-ripgrep', { 'on': 'Rg' }
Plug 'OmniSharp/omnisharp-vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'editorconfig/editorconfig-vim'
Plug 'tpope/vim-fugitive'

call plug#end()

" FZF config
map <C-p> :FZF<enter>

" RG config
map <C-F> :Rg 

" NERDTree config
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTreeToggle | endif

map <C-o> :NERDTreeToggle<CR>

autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
autocmd BufEnter * if bufname('#') =~# "^NERD_tree_" && winnr('$') > 1 | b# | endif

let g:plug_window = 'noautocmd vertical topleft new'
