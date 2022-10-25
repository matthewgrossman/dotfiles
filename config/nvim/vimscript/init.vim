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

" enforce we are doing mac/linux files
set fileformat=unix

" highlight pasted text
nnoremap gp `[v`]

" search options
set ignorecase
set smartcase
nnoremap n nzz
nnoremap N Nzz

" line numbering
set number
set signcolumn=yes

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

" don't error out when quitting w/ an open terminal
" https://github.com/neovim/neovim/issues/14061
command Z w | qa
cabbrev wqa Z

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

" add toggle for pinning a window at a size
nnoremap ]st :set winfixheight<CR>
nnoremap [st :set nowinfixheight<CR>

" use mouse
set mouse=a

" disable preview window
set pumheight=30

" reload external changes
set autoread
autocmd! FocusGained,BufEnter * if mode() != 'c' | checktime | endif

" Leader commands
nnoremap <silent> <Leader><SPACE> :nohlsearch<CR>
nnoremap <silent> <Leader>c :let @+ = expand("%")<CR> |" copy filepath
nnoremap <leader>sv :source $MYVIMRC<CR>
nnoremap <silent> <leader>l :redraw!<CR>

" python config
" use host python3
let g:python3_host_prog = "/usr/local/bin/python3"

" cron config
autocmd filetype crontab setlocal nobackup nowritebackup

" NEOVIM SPECIFIC
set inccommand=nosplit

" neovim remote
let $EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
let $VISUAL = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
autocmd FileType gitcommit,gitrebase,gitconfig setlocal bufhidden=delete
autocmd BufNewFile,BufRead kubectl-edit-*.yaml  setlocal bufhidden=delete

" NEOVIM TERMINAL CONFIG
autocmd TermOpen * call InitTermBuffer()
function! InitTermBuffer()
    setlocal nonumber
    setlocal signcolumn=no
    nnoremap <buffer> <C-c> :startinsert<CR>
    nnoremap <buffer> <C-b> :startinsert<CR>
    nnoremap <buffer> <C-e> :startinsert<CR><C-e>
    nnoremap <buffer> <C-a> :startinsert<CR><C-a>
    nnoremap <buffer> q :startinsert<CR>q
endfunction

nnoremap <C-w>\| :vsplit <bar> terminal <CR>:startinsert<CR>
nnoremap <C-w>- :split <bar> terminal <CR>:startinsert<CR>
nnoremap <C-w>t :tabnew <bar> :terminal<CR>a
vnoremap <C-w>\| <esc>:vsplit <bar> terminal <CR>:startinsert<CR>
vnoremap <C-w>- <esc>:split <bar> terminal <CR>:startinsert<CR>
vnoremap <C-w>t <esc>:tabnew <bar> :terminal<CR>a

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

" markdown config
let g:mkdp_auto_close = 0

" gutentags config
let g:gutentags_cache_dir = $HOME.'/.build/gutentags'
set nofsync

" vim-easy-align config
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" file_browser config
nnoremap - :Telescope file_browser path=%:p:h<CR>

" airline config
" let g:airline_highlighting_cache = 1

let g:html_indent_script1 = "inc"
let g:html_indent_style1 = "inc"

" vim-qf config
noremap <leader>q <Plug>(qf_qf_toggle_stay)

set shortmess+=c

" python config
let g:python_highlight_indent_errors = 0
let g:python_highlight_space_errors = 0
let g:python_highlight_all = 1
abbreviate dbg breakpoint()

" nnoremap <leader>a <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>a :Telescope grep_string search=<CR>

" commands
command! -range=% JSONformat :<line1>,<line2>!python -m json.tool
command! -range=% XMLformat :<line1>,<line2>!xmllint --format -
command! -range EscapeForwardSlash :<line1>,<line2>s,/,\\/
command! -range SpongebobCase :<line1>,<line2>luado return require('spongebob')(line)

" theming
" set termguicolors
" colorscheme material
set background=dark

" vim-grepper config
nmap gs <plug>(GrepperOperator)
xmap gs <plug>(GrepperOperator)
let g:grepper = {
\   'highlight': 1,
\   'tools': ['rg']
\ }

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

" highlightedyank config
let g:highlightedyank_highlight_duration = 150

" fugitive config
nmap <Leader>gg :Git<cr>
nmap <Leader>gdd :Gdiffsplit<cr>
nmap <Leader>gdm :Gdiffsplit master<cr>
nmap <Leader>gb :Git blame<cr>
nmap <Leader>ga :Gwrite<cr>
nmap <Leader>gp :Git push<cr>
nmap <Leader>gh V:GBrowse<cr>
vmap <Leader>gh :GBrowse<cr>


" tagbar config
noremap <Leader>t :TagbarOpenAutoClose<CR>
let g:tagbar_left = 1

" fzf config
" nnoremap <c-p> :GFiles<cr>
" let g:fzf_layout = {'window': 'enew'}
let g:fzf_action = {
    \ 'ctrl-q': 'wall | bdelete',
    \ 'ctrl-t': 'tab split',
    \ 'ctrl-x': 'split',
    \ 'ctrl-v': 'vsplit' }
