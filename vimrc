" Update MYVIMRC
let $MYVIMRC="~/.dotfiles/vimrc"

" Make windows accept unixy stuff
if has('win32') || has('win64')
    set runtimepath=~/.vim,$VIM/vimfiles,$VIM,$VIM/vimfiles/after,~/.vim/after
    set dir=$TEMP
endif

"Load pathogen
source ~/.vim/bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()

"Psh, compatibility schmompatibility
set nocompatible

filetype plugin indent on    " required

" Put your non-Plugin stuff after this line
" END VUNDLE CONFIG

"Set Color Scheme and font
colorscheme solarized
set background=dark
set guifont=Source_Code_Pro:h12:cANSI

"Configure some simple settings
set backspace=2 "Backspace over indents, eol, etc.

"Set up VIM GUIs
set guioptions-=m " Hide menu bar
set guioptions-=T " Remove toolbar 
set guioptions-=r
set guioptions-=L " Remove scrollbars

"Syntax Highlighting ON!
syntax on

"Indentation configuration
set tabstop=4
set shiftwidth=4
set softtabstop=4
set smarttab
set expandtab

" Statusline and line numbers
set laststatus=2
set number
"set statusline=%{fugitive#statusline()}

" Macros/Mappings
nmap <S-Enter> O<Esc>
nmap <CR> o<Esc>

" Remove the ability to "derp around using the arrow keys"
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>
imap <up> <nop>
imap <down> <nop>
imap <left> <nop>
imap <right> <nop>

" Use Ctrl-J and Ctrl-K to switch windows
map <C-J> <C-W>j<C-W>_
map <C-K> <C-W>k<C-W>_

" Configure NERDTree and NERDTree tabs
map <A-O> <Esc>:NERDTreeToggle<CR>
map <C-O> <Esc>:NERDTreeFocusToggle<CR>
let g:nerdtree_tabs_open_on_gui_startup=0
let g:nerdtree_tabs_open_on_new_tab=0

" CtrlP settings
let g:ctrlp_working_path_mode='ra'

" Maximize the window on launch
au GUIEnter * simalt ~x
