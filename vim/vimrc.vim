set nocompatible
syntax on

if has('win32') || has('win64')
    " Add ~/.vim to runtime path on Windows (to be more like unix)
    set runtimepath^=~/.vim
end

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
Plug 'roxma/vim-tmux-clipboard'
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-commentary'
Plug 'tomtom/tinykeymap_vim'

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
nnoremap <Leader>b :Buffers<CR>
nnoremap <Leader>t :Tags<CR>
nnoremap <Leader>p "+p
nnoremap <Leader>y "+y

" Use <C-w> as the key to enter tinykeymap_vim's Window mode
let g:tinykeymap#map#windows#map = '<C-w>'
call tinykeymap#Load("windows")
