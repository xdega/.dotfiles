" --- Plugin Manager Setup --- "
" Initialize vim-plug
call plug#begin('~/.vim/plugged')
" Declare the Nova theme plugin
Plug 'iammerrick/nova-vim'
" LSP client: autocomplete, go-to-definition, references, diagnostics
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Finalize plugin loading
call plug#end()
" --- Color Scheme Settings --- "
syntax on
set termguicolors
" On the first install, nova is not available until PlugInstall completes.
if !empty(globpath(&runtimepath, 'colors/nova.vim'))
  colorscheme nova
endif
" --- Search --- "
set hlsearch
set incsearch
" --- Tabbing and Spacing --- "
set ts=4
set backspace=indent,eol,start
set shiftwidth=4
set expandtab
set autoindent
set smartindent
set nowrap
set showmode
set number
set showtabline=2
let mapleader = ','
" --- Remove Search Highlighting --- "
nmap <leader><space> :nohlsearch<cr>
" --- Tab Navigation --- "
nnoremap <leader>1 1gt
nnoremap <leader>2 2gt
nnoremap <leader>3 3gt
nnoremap <leader>4 4gt
nnoremap <leader>5 5gt
nnoremap <leader>cc :tabclose<CR>
nnoremap <leader>tt :tabnew<CR>
" --- Project-Wide Ripgrep to New Tabs --- "
" 1. Configure engine to use ripgrep with standard vimgrep/smart-case flags
if executable('rg')
  set grepprg=rg\ --vimgrep\ --smart-case
  set grepformat=%f:%l:%c:%m
endif
" 1b. Automatically open the quickfix window after any grep (only when there
"     are results). This is what makes ,gg show its matches.
augroup quickfix_autoopen
  autocmd!
  autocmd QuickFixCmdPost grep cwindow
augroup END
" 2. Function to open Quickfix results in a new tab
function! OpenQuickfixInNewTab()
  let l:qf_list = getqflist()
  let l:idx = line('.') - 1
  if l:idx >= 0 && l:idx < len(l:qf_list)
    let l:item = l:qf_list[l:idx]
    if l:item.bufnr > 0
      cclose
      execute 'tabedit +' . l:item.lnum . ' ' . bufname(l:item.bufnr)
    endif
  endif
endfunction
" 3. Automatically map Enter inside the Quickfix window
augroup QfTabMapping
  autocmd!
  autocmd FileType qf nnoremap <buffer> <CR> :call OpenQuickfixInNewTab()<CR>
augroup END
" 4. Keybindings for Project-Wide Grepping
" Press ,gc to grep the word under the cursor across the whole project
nnoremap <leader>gc :execute "grep! " . shellescape(expand('<cword>'))<CR>
" Press ,gg to type your project search pattern manually
nnoremap <leader>gg :grep! 
" Press ,qq to close the quickfix window
nnoremap <leader>qq :cclose<CR>
" --- coc.nvim: LSP navigation --- "
" Helper: turn a file:// URI (as coc returns) into a filesystem path,
" decoding %XX escapes so paths with spaces etc. resolve correctly.
function! s:DecodeURI(uri) abort
  let l:path = substitute(a:uri, '^file://', '', '')
  return substitute(l:path, '%\(\x\x\)', '\=printf("%c", str2nr(submatch(1), 16))', 'g')
endfunction
" Collect all references into the quickfix list, then show them in a new tab
" (first reference on top, quickfix list below).
function! ShowReferencesInTab() abort
  let l:refs = CocAction('references')
  if type(l:refs) != v:t_list || empty(l:refs)
    echohl WarningMsg | echomsg 'No references found' | echohl None
    return
  endif
  let l:items = []
  for l:ref in l:refs
    call add(l:items, {
      \ 'filename': s:DecodeURI(l:ref.uri),
      \ 'lnum': l:ref.range.start.line + 1,
      \ 'col':  l:ref.range.start.character + 1,
      \ 'text': 'reference',
      \ })
  endfor
  call setqflist([], ' ', {'title': 'References', 'items': l:items})
  tabnew
  cfirst
  copen
endfunction
" Jump to definition in a new tab
nmap <silent> <leader>d :call CocActionAsync('jumpDefinition', 'tabe')<CR>
" List references in a quickfix window in a new tab
nmap <silent> <leader>r :call ShowReferencesInTab()<CR>
" --- coc.nvim: autocomplete-as-you-type --- "
" Use <Tab>/<Shift-Tab> to cycle the popup menu, <CR> to confirm
inoremap <silent><expr> <TAB>
\ coc#pum#visible() ? coc#pum#next(1) :
\ CheckBackspace() ? "\<Tab>" :
\ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>"
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1] =~# '\s'
endfunction
" Show hover documentation with K
nnoremap <silent> K :call ShowDocumentation()<CR>
function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction
" Highlight the symbol and its references when cursor holds
autocmd CursorHold * silent call CocActionAsync('highlight')
" --- Automatic Commands --- "
" Source the .vimrc file when saved
augroup autosourcing
  autocmd!
  autocmd BufWritePost .vimrc source %
augroup END
