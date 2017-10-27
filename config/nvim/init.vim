""" BASIC COMMANDS
set nocompatible

" move by screen-line instead of text-line
nnoremap j gj
nnoremap k gk

" make register-global replacements the default
set gdefault

" make capital Y act more normal
nnoremap Y y$

" make saving easier
nnoremap <c-s> :w<CR>
inoremap <c-s> <c-o>:w<CR>
vnoremap <c-s> <esc>:w<CR>gv

" easily highlight recently pasted text
nnoremap gp `[v`]

" search options
set incsearch
set hlsearch
set ignorecase
set infercase
vnoremap // y/\V<C-R>"<CR>

" line numbering
set number

" link to system clipboard
set clipboard=unnamed

" make splits more intuitive
set splitbelow
set splitright

" turn on syntax highlighting and filetypes
filetype plugin indent on
syntax on

""" TERMINAL SPECIFIC
set mouse=a

" nvim compat
if !has('nvim')
    set ttyfast
    set ttyscroll=3
    set noesckeys
    set ttymouse=xterm2
end

" gotta go fast
set lazyredraw
set timeoutlen=400

" Leader commands
nnoremap <silent> <Leader>w :w<CR> |" easier saving
nnoremap <silent> <Leader>c :let @+ = expand("%")<CR> |" copy filepath

""" PLUGINS

if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif
call plug#begin('~/.local/share/nvim/plugged')

" movement
Plug 'christoomey/vim-tmux-navigator'

" completion
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'
Plug 'ajh17/VimCompletesMe'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

" file management
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all'  }
Plug 'junegunn/fzf.vim'
Plug 'qpkorr/vim-bufkill'
Plug 'tpope/vim-fugitive'

Plug 'tpope/vim-rhubarb'
Plug 'ludovicchabant/vim-gutentags'
Plug 'majutsushi/tagbar'

" usability
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-unimpaired'
Plug 'wellle/targets.vim'
Plug 'peterrincker/vim-argumentative'
Plug 'godlygeek/tabular'
Plug 'mhinz/vim-grepper'

" ui
Plug 'mhinz/vim-signify'
Plug 'chriskempson/base16-vim'
Plug 'itchyny/lightline.vim'
Plug 'w0rp/ale'

" productivity
Plug 'vimwiki/vimwiki'

" python
Plug 'davidhalter/jedi-vim'
Plug 'zchee/deoplete-jedi'
Plug 'hynek/vim-python-pep8-indent'
Plug 'vim-python/python-syntax'

" languages
Plug 'pangloss/vim-javascript'
Plug 'plasticboy/vim-markdown'
Plug 'junegunn/vader.vim'
Plug 'leafgarland/typescript-vim'

call plug#end()

" bufkill config
nmap <C-c> :BD<CR>

" ale config
let g:ale_lint_on_text_changed = 0
let g:ale_lint_on_save = 1

" fzf config
nnoremap <c-p> :GFiles<cr>
nnoremap - :Buffers<cr>

" vim-grepper config
nmap gs <plug>(GrepperOperator)
xmap gs <plug>(GrepperOperator)
let g:grepper = {
\   'prompt': 0,
\   'highlight': 1,
\   'tools': ['ag']
\ }
" command GP :Grepper -prompt

" tagbar config
noremap <Leader>t :TagbarToggle<CR>

" delimitMate config
let delimitMate_expand_cr = 1
let delimitMate_expand_space = 1

" SimpylFold
let g:SimpylFold_fold_docstring = 0
let g:SimpylFold_fold_import = 0

" " lightline config
set laststatus=2
let g:lightline = {
\   'colorscheme': 'wombat'
\ }

" deoplete config
let g:deoplete#enable_at_startup = 1

" python config
let g:jedi#completions_enabled = 0
let g:deoplete#sources#jedi#show_docstring = 0
let g:python_highlight_indent_errors = 0
let g:python_highlight_space_errors = 0
let g:python_highlight_all = 1

" Change color theme
set background=dark
let base16colorspace=256
colorscheme base16-default-dark

map <SPACE> <leader>

" fix this by using the --query arg as the initial
nnoremap K :Ag <C-R><C-W><CR>


" normal setings
set backspace=2
set history=1000
set showmode
set gcr=a:blinkon0
set visualbell

set hidden
set tags=./tags;
set autoread

set wildmenu

set expandtab
set shiftround
set shiftwidth=4
set softtabstop=4

" autocmds
autocmd BufNewFile,BufRead *.sls  set syntax=yaml
autocmd filetype crontab setlocal nobackup nowritebackup
