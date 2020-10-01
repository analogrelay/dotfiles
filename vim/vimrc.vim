set nocompatible
syntax on

" Enable vim-plug
call plug#begin('~/.vim/plugged')

" Add plugins here!
Plug 'scrooloose/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'fatih/vim-go'
"Plug 'jremmen/vim-ripgrep', { 'on': 'Rg' }
Plug 'OmniSharp/omnisharp-vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'editorconfig/editorconfig-vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'christoomey/vim-tmux-navigator'
Plug 'vim-scripts/AutoComplPop'
Plug 'vim-ruby/vim-ruby'

call plug#end()

" FZF config
map <C-p> :FZF<enter>

" NERDTree config
map <C-n> :NERDTreeToggle<CR>

autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
autocmd BufEnter * if bufname('#') =~# "^NERD_tree_" && winnr('$') > 1 | b# | endif

let g:plug_window = 'noautocmd vertical topleft new'

set number

" Buffer management
nnoremap <Leader>b :buffers<CR>:buffer<SPACE>
