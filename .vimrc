" Name: Liam's Vim Settings
" Author: Liam Hockley
" Description: Aesthetically pleasing and minimal, yet functional.

" --- Editor Setup and Color Scheme --- "
" Load Plugins
set nocompatible
so ~/.vim/plugins.vim

" GUI and Colors
set showmode
syntax enable
colorscheme codedark
set number
set showtabline=2
let mapleader = ','
" Tabbing and Spacing
set ts=4
set backspace=indent,eol,start
set shiftwidth=4
set expandtab
set autoindent
set smartindent
set nowrap
" Custom Highlights
hi TabLineSel ctermbg=88
au InsertEnter * hi TabLineSel ctermbg=29
au InsertLeave * hi TabLineSel ctermbg=88

" --- Search --- "
set hlsearch
set incsearch

" --- Plugin Settings -- "
" CtrlP
let g:ctrlp_custom_ignore = 'vendor\node_modules\DS_Store\|git'
let g:ctrlp_match_window = 'top,order:ttb,min:1,max:5,results:5'
let g:ctrlp_prompt_mappings = {
        \ 'AcceptSelection("e")': ['<2-LeftMouse>'],
        \ 'AcceptSelection("t")': ['<cr>'],
        \ }

" --- Custom Mappings --- "
" Edit Config Files
nmap <leader>ev :tabedit $MYVIMRC<cr>
nmap <leader>ep :tabedit ~/.vim/plugins.vim<cr>
nmap <leader>es :tabedit ~/.vim/snippets/php.snippets<cr>

" Remove Search Highlighting
nmap <leader><space> :nohlsearch<cr>
" Tab Navigation
nnoremap <leader>1 1gt
nnoremap <leader>2 2gt
nnoremap <leader>3 3gt
nnoremap <leader>4 4gt
nnoremap <leader>5 5gt

" Run PHP Linting (Saved Changes Only)
map <F5> :!php -l %<CR>

" --- Automatic Commands --- "
" Source the .vimrc file when saved
augroup autosourcing
    autocmd!
    autocmd BufWritePost .vimrc source %
augroup END

