" normal settings
set hidden

" move by screen-line instead of text-line
noremap j gj
noremap k gk

" hop to the beginning and ends of line easily
nnoremap H ^
nnoremap L $

" make capital Y act more normal
nnoremap Y y$

" make saving easier
nnoremap <c-s> :w<CR>
inoremap <c-s> <c-o>:w<CR>
vnoremap <c-s> <esc>:w<CR>gv

" common typos
command! -bang Qa qa
command! -bang QA qa
command! -bang Wq wq
command! -bang WQ wq
command! -bang Wqa wqa

" paste from the copy buffer
vnoremap x "0p

" easily replay recent macro
nnoremap Q @q

" improve visual commands
vnoremap Q :normal @q<CR>
vnoremap . :normal .<CR>

" copy things from vim-rsi
inoremap        <C-A> <C-O>^
cnoremap        <C-A> <Home>

inoremap <expr> <C-B> getline('.')=~'^\s*$'&&col('.')>strlen(getline('.'))?"0\<Lt>C-D>\<Lt>Esc>kJs":"\<Lt>Left>"
cnoremap        <C-B> <Left>

inoremap <expr> <C-D> col('.')>strlen(getline('.'))?"\<Lt>C-D>":"\<Lt>Del>"
cnoremap <expr> <C-D> getcmdpos()>strlen(getcmdline())?"\<Lt>C-D>":"\<Lt>Del>"

inoremap <expr> <C-E> col('.')>strlen(getline('.'))<bar><bar>pumvisible()?"\<Lt>C-E>":"\<Lt>End>"

inoremap <expr> <C-F> col('.')>strlen(getline('.'))?"\<Lt>C-F>":"\<Lt>Right>"
cnoremap <expr> <C-F> getcmdpos()>strlen(getcmdline())?&cedit:"\<Lt>Right>"


noremap!        <M-b> <S-Left>
noremap!        <M-f> <S-Right>
noremap!        <M-d> <C-O>dw
cnoremap        <M-d> <S-Right><C-W>
noremap!        <M-n> <Down>
noremap!        <M-p> <Up>
noremap!        <M-BS> <C-W>
noremap!        <M-C-h> <C-W>

" add line text object
xnoremap il g_o^
onoremap il :normal vil<CR>
xnoremap al $o0
onoremap al :normal val<CR>

" make line-global replacements the default
set gdefault

" highlight pasted text
nnoremap gp `[v`]

" search options
set ignorecase
set smartcase
nnoremap n nzz
nnoremap N Nzz

" line numbering
set number

" link to system clipboard
set clipboard=unnamed

" make splits more intuitive
set splitbelow
set splitright

" zoom in function to take a split to the full screen
nnoremap <C-w>z :tab split<CR>

" diff
set diffopt=internal,algorithm:patience,indent-heuristic

" fold settings
set foldmethod=indent
set foldlevelstart=99

" don't redraw during macros
set lazyredraw
set cursorline

" sane defaults for languages not covered by file plugins
set tabstop=4
set shiftwidth=4
set expandtab

" filetype autocmds
autocmd BufNewFile,BufRead *.sls  set syntax=yaml
autocmd BufNewFile,BufRead tsconfig.json  set filetype=jsonc
autocmd BufNewFile,BufRead Tiltfile  set filetype=bzl
autocmd FileType json let &formatprg='python3 -m json.tool'
autocmd FileType xml let &formatprg='xmllint --format -'
autocmd FileType python let &formatprg='black --quiet -'
autocmd FileType crontab setlocal nobackup nowritebackup
autocmd FileType vimwiki setlocal noexpandtab
autocmd FileType fugitive* nmap <buffer> q gq
autocmd FileType lua setlocal expandtab shiftwidth=4 softtabstop=4 tabstop=4
autocmd FileType go setlocal noexpandtab

" scratch buffer
function! Scratch()
    execute 'enew'
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
endfunction
nnoremap ge :call Scratch()<CR>

" add toggle for pinning a window at a size
nnoremap ]st :set winfixheight<CR>
nnoremap [st :set nowinfixheight<CR>

" use mouse
set mouse=a

" disable preview window
set pumheight=30

" reload external changes
set autoread
au FocusGained,BufEnter * checktime

" Leader commands
map <SPACE> <leader>
nnoremap <silent> <Leader><SPACE> :nohlsearch<CR>
nnoremap <silent> <Leader>c :let @+ = expand("%")<CR> |" copy filepath
nnoremap <leader>sv :source $MYVIMRC<CR>
nnoremap <silent> <leader>l :redraw!<CR>

" polyglot config
let g:polyglot_disabled = ['csv']

" python config
" use host python3
let g:python3_host_prog = "/usr/local/bin/python3"

""" PLUGINS
call plug#begin('~/.local/share/nvim/plugged')

" nvim shenanigans
Plug 'nvim-lua/plenary.nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'antoinemadec/FixCursorHold.nvim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'jose-elias-alvarez/null-ls.nvim'

" completion
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

" file management
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all'  }
Plug 'junegunn/fzf.vim'
Plug 'mhinz/vim-sayonara', { 'on': 'Sayonara' }
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-eunuch'
Plug 'ludovicchabant/vim-gutentags'
Plug 'majutsushi/tagbar'
Plug 'francoiscabrol/ranger.vim'
Plug 'rbgrouleff/bclose.vim'

" usability
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
" Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'tpope/vim-repeat'
" Plug 'tpope/vim-rsi'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-abolish'
Plug 'machakann/vim-sandwich'
Plug 'wellle/targets.vim'
Plug 'kana/vim-textobj-indent'
Plug 'peterrincker/vim-argumentative'
Plug 'janko-m/vim-test'
Plug 'mhinz/vim-grepper'
" Plug 'romainl/vim-qf'
Plug 'kana/vim-textobj-user'
Plug 'stefandtw/quickfix-reflector.vim'
Plug 'junegunn/vim-easy-align'
Plug 'nelstrom/vim-visual-star-search'
Plug 'AndrewRadev/splitjoin.vim'

" ui
" Plug 'mhinz/vim-signify'
Plug 'chriskempson/base16-vim'
Plug 'machakann/vim-highlightedyank'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" productivity
Plug 'junegunn/goyo.vim'

" python
Plug 'vim-python/python-syntax', { 'for': 'python' }
Plug 'bps/vim-textobj-python', { 'for': 'python' }

" other languages
Plug 'sheerun/vim-polyglot'
Plug 'Glench/Vim-Jinja2-Syntax', { 'for': 'jinja.html' }
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
Plug 'junegunn/vader.vim'
Plug 'neoclide/jsonc.vim'


call plug#end()

" theming
set termguicolors
colorscheme base16-default-dark
set background=dark

" cron config
autocmd filetype crontab setlocal nobackup nowritebackup

" NEOVIM SPECIFIC
set inccommand=nosplit

" neovim remote
let $EDITOR = 'nvr -cc split --remote-wait'
let $VISUAL = 'nvr -cc split --remote-wait'
autocmd FileType gitcommit,gitrebase,gitconfig setlocal bufhidden=delete
autocmd BufNewFile,BufRead kubectl-edit-*.yaml  setlocal bufhidden=delete

" NEOVIM TERMINAL CONFIG
autocmd TermOpen * call InitTermBuffer()
function! InitTermBuffer()
    setlocal nonumber
    nnoremap <buffer> <C-c> :startinsert<CR>
    nnoremap <buffer> <C-b> :startinsert<CR>
    nnoremap <buffer> <C-e> :startinsert<CR><C-e>
    nnoremap <buffer> <C-a> :startinsert<CR><C-a>
    nnoremap <buffer> q :startinsert<CR>q
endfunction

nnoremap <C-w>\| :vsplit <bar> terminal <CR>:startinsert<CR>
nnoremap <C-w>- :split <bar> terminal <CR>:startinsert<CR>
nnoremap <C-w>t :tabnew <bar> :terminal<CR>a

" Remember last mode in terminal buffer
function! LeaveTermWhileInInsert(direction)
    let b:last_mode = 'insert'
    execute 'wincmd '.a:direction
endfunction
function! LeaveTermAndResetMode()
    let b:last_mode = 'normal'
endfunction
function! EnterTermAndActivateLastMode()
    if !exists('b:last_mode') || (exists('b:last_mode') && b:last_mode == 'insert')
        startinsert
    endif
endfunction
autocmd WinEnter term://* silent call EnterTermAndActivateLastMode()
tnoremap <silent> <esc> <C-\><C-N>:call LeaveTermAndResetMode()<CR>

tnoremap <silent> <C-h> <C-\><C-N>:call LeaveTermWhileInInsert('h')<CR>
tnoremap <silent> <C-j> <C-\><C-N>:call LeaveTermWhileInInsert('j')<CR>
tnoremap <silent> <C-k> <C-\><C-N>:call LeaveTermWhileInInsert('k')<CR>
tnoremap <silent> <C-l> <C-\><C-N>:call LeaveTermWhileInInsert('l')<CR>
tnoremap <M-[> <Esc>
inoremap <C-h> <C-\><C-N><C-w>h
inoremap <C-j> <C-\><C-N><C-w>j
inoremap <C-k> <C-\><C-N><C-w>k
inoremap <C-l> <C-\><C-N><C-w>l
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
vnoremap <C-h> <esc><C-w>h
vnoremap <C-j> <esc><C-w>j
vnoremap <C-k> <esc><C-w>k
vnoremap <C-l> <esc><C-w>l

" vim-sandwich
runtime macros/sandwich/keymap/surround.vim
for recipe in g:sandwich#recipes
    let recipe.cursor = 'head'
endfor

" Sayonara config
nnoremap <C-q> :Sayonara!<CR>

" markdown config
let g:mkdp_auto_close = 0

" gutentags config
let g:gutentags_cache_dir = $HOME.'/.build/gutentags'
set nofsync

" vim-easy-align config
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" ranger config
nnoremap - :Ranger<CR>
" function! Ranger()
"     let args = &buftype == 'terminal' ? '' : ' --selectfile='.expand('%')
"     execute 'terminal VISUAL="nvr" ranger'.args
"     startinsert
" endfunction
" nnoremap - :call Ranger()<CR>
" autocmd TermClose term://.//*:ranger* bprevious | bwipeout! #

" fugitive config
nmap <Leader>gg :Git<cr>
nmap <Leader>gdd :Gdiffsplit<cr>
nmap <Leader>gdm :Gdiffsplit master<cr>
nmap <Leader>gb :Git blame<cr>
nmap <Leader>ga :Gwrite<cr>
nmap <Leader>gp :Git push<cr>
nmap <Leader>gh V:GBrowse<cr>
vmap <Leader>gh :GBrowse<cr>

" airline config
let g:airline_highlighting_cache = 1

" highlightedyank config
let g:highlightedyank_highlight_duration = 150

" fzf config
" nnoremap <c-p> :GFiles<cr>
" let g:fzf_layout = {'window': 'enew'}
let g:fzf_action = {
    \ 'ctrl-q': 'wall | bdelete',
    \ 'ctrl-t': 'tab split',
    \ 'ctrl-x': 'split',
    \ 'ctrl-v': 'vsplit' }

" vim-grepper config
nmap gs <plug>(GrepperOperator)
xmap gs <plug>(GrepperOperator)
let g:grepper = {
\   'highlight': 1,
\   'tools': ['rg']
\ }

let g:html_indent_script1 = "inc"
let g:html_indent_style1 = "inc"

" tagbar config
noremap <Leader>t :TagbarOpenAutoClose<CR>
let g:tagbar_left = 1

" vim-qf config
noremap <leader>q <Plug>(qf_qf_toggle_stay)

" autopairs config
inoremap <silent> <C-Space> <esc>:call AutoPairsJump()<CR>a

" vim-test config
nmap <silent> <leader>r :TestNearest<CR>
nmap <silent> <leader>R :TestFile<CR>

function! ClipboardStrategy(cmd)
    let @+ = a:cmd
endfunction
let g:test#custom_strategies = {'clipboard': function('ClipboardStrategy')}
let g:test#strategy = 'clipboard'
" let g:test#custom_transformations = {'service_venv': function({cmd -> 'service_venv '.cmd})}
" let g:test#custom_transformations = {'python_module': function({cmd -> 'python3 -m '.cmd})}
" let g:test#transformation = 'python_module'
" let g:test#python#runner = 'pytest'

set shortmess+=c

" python config
let g:python_highlight_indent_errors = 0
let g:python_highlight_space_errors = 0
let g:python_highlight_all = 1
abbreviate dbg breakpoint()
nmap <silent> <leader>p ^f(a<CR><ESC>gE%i<CR><ESC>=i(

nnoremap <leader>a :Rg <C-R><C-W><CR>

" commands
command! -range=% JSONformat :<line1>,<line2>!python -m json.tool
command! -range=% XMLformat :<line1>,<line2>!xmllint --format -
command! -range EscapeForwardSlash :<line1>,<line2>s,/,\\/
command! -range SpongebobCase :<line1>,<line2>luado return require('spongebob')(line)

lua require('init')
