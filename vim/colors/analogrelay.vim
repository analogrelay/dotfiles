" Vim color file
" Maintainer:	Andrew Stanton-Nurse <contact@analogrelay.dev>

" Remove all existing highlighting and set the defaults.
hi clear

hi Normal guifg=#e6e1de ctermfg=15 gui=none

" Load the syntax highlighting defaults, if it's enabled.
if exists("syntax_on")
  syntax reset
endif

let colors_name = "analogrelay"

" vim: sw=2
