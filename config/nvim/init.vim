" normal settings
set hidden

" move by screen-line instead of text-line
nnoremap j gj
nnoremap k gk

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
au FocusGained,BufEnter * checktime

" Leader commands
map <SPACE> <leader>
nnoremap <silent> <Leader><SPACE> :nohlsearch<CR>
nnoremap <silent> <Leader>c :let @+ = expand("%")<CR> |" copy filepath
nnoremap <leader>sv :source $MYVIMRC<CR>
nnoremap <silent> <leader>l :redraw!<CR>

""" PLUGINS
call plug#begin('~/.local/share/nvim/plugged')

" completion
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" file management
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all'  }
Plug 'junegunn/fzf.vim'
Plug 'mhinz/vim-sayonara', { 'on': 'Sayonara' }
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-eunuch'
Plug 'ludovicchabant/vim-gutentags'
Plug 'majutsushi/tagbar'

" usability
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-rsi'
Plug 'tpope/vim-abolish'
Plug 'machakann/vim-sandwich'
Plug 'wellle/targets.vim'
Plug 'kana/vim-textobj-indent'
Plug 'peterrincker/vim-argumentative'
Plug 'janko-m/vim-test'
Plug 'mhinz/vim-grepper'
Plug 'romainl/vim-qf'
Plug 'kana/vim-textobj-user'
Plug 'stefandtw/quickfix-reflector.vim'
Plug 'junegunn/vim-easy-align'
Plug 'nelstrom/vim-visual-star-search'
Plug 'AndrewRadev/splitjoin.vim'

" ui
Plug 'mhinz/vim-signify'
Plug 'w0rp/ale'
Plug 'chriskempson/base16-vim'
Plug 'machakann/vim-highlightedyank'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" productivity
Plug 'vimwiki/vimwiki'
Plug 'junegunn/goyo.vim'

" python
Plug 'vim-python/python-syntax', { 'for': 'python' }
Plug 'bps/vim-textobj-python', { 'for': 'python' }

" other languages
Plug 'sheerun/vim-polyglot'
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'Glench/Vim-Jinja2-Syntax', { 'for': 'jinja.html' }
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
Plug 'junegunn/vader.vim'

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
tnoremap <esc> <C-\><C-n>
nnoremap <C-w>t :tabnew <bar> :terminal<CR>a
autocmd BufEnter,BufWinEnter,WinEnter * if &buftype=='terminal' | startinsert | endif

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

tnoremap <M-[> <Esc>
tnoremap <C-h> <C-\><C-N><C-w>h
tnoremap <C-j> <C-\><C-N><C-w>j
tnoremap <C-k> <C-\><C-N><C-w>k
tnoremap <C-l> <C-\><C-N><C-w>l
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

" polyglot config
let g:polyglot_disabled = ['csv']

" markdown config
let g:mkdp_auto_close = 0

" ale config
function! ReorderPythonImports(buffer)
    return { 'command': 'reorder-python-imports -'}
endfunction
function! AddTrailingComma(buffer)
    return { 'command': 'add-trailing-comma --py36-plus -'}
endfunction
let g:ale_linters = {
\   'typescript': ['tsserver'],
\   'python': ['flake8', 'mypy', 'pyls'],
\   'zsh': ['shellcheck'],
\   'bash': ['shellcheck'],
\   'go': ['gopls'],
\   'lua': ['luacheck'],
\   'cpp': ['clangd'],
\}

" include pyls to leverage LSP; disable below to silence diagnostics
let g:ale_linters_ignore = {'python': ['pyls']}
let g:ale_fixers = {
\   '*': ['trim_whitespace'],
\   'python': [function('AddTrailingComma'), function('ReorderPythonImports'), 'isort', 'trim_whitespace', 'autopep8', 'black'],
\   'go': ['gofmt']
\}
let g:ale_fix_on_save = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 1
let g:ale_python_autopep8_options = '--max-line-length=10000'
let g:ale_lua_luacheck_options = '--config '.$XDG_CONFIG_HOME.'/luacheck/.luacheckrc'
let g:ale_cpp_clangd_options = '-x c++'
let g:ale_virtualtext_cursor = 1

autocmd BufEnter __init__.py,manage.py,venv/* let b:ale_fix_on_save = 0

" gutentags config
let g:gutentags_cache_dir = $HOME.'/.build/gutentags'
set nofsync

" vimwiki config
nmap <Leader>d <Plug>VimwikiMakeDiaryNote
nmap <Leader>di <Plug>VimwikiDiaryIndex
nmap <Leader>dig <Plug>VimwikiDiaryGenerateLinks

" vim-easy-align config
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" ranger config
function! Ranger()
    let args = &buftype == 'terminal' ? '' : ' --selectfile='.expand('%')
    execute 'terminal VISUAL="nvr" ranger'.args
    startinsert
endfunction
nnoremap - :call Ranger()<CR>
autocmd TermClose term://.//*:ranger* bprevious | bwipeout! #

" fugitive config
nmap <Leader>gg :Git<space>
nmap <Leader>gd :Gdiff<cr>
nmap <Leader>gs :Gstatus<cr>
nmap <Leader>gb :Gblame<cr>
nmap <Leader>ga :Gwrite<cr>
nmap <Leader>gh V:Gbrowse<cr>
vmap <Leader>gh :Gbrowse<cr>

" airline config
let g:airline_highlighting_cache = 1

" highlightedyank config
let g:highlightedyank_highlight_duration = 150

" fzf config
nnoremap <c-p> :FZFBuffers<cr>
let g:fzf_layout = {'window': 'enew'}
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

" vim-signify config
let g:signify_vcs_list = ['git']
nnoremap [d :call SignifyToggleDiff('head')<CR>
nnoremap ]d :call SignifyToggleDiff('master')<CR>
function! SignifyToggleDiff(diff_commit)
    if(a:diff_commit == 'master')
        let g:signify_vcs_cmds = {
        \ 'git': 'git diff master --no-color --no-ext-diff -U0 -- %f',
        \ }
    else
        let g:signify_vcs_cmds = {
        \ 'git': 'git diff --no-color --no-ext-diff -U0 -- %f',
        \ }
    endif
endfunction

" tagbar config
noremap <Leader>t :TagbarOpenAutoClose<CR>
let g:tagbar_left = 1

" vim-qf config
nmap [l <Plug>(ale_previous_wrap)
nmap ]l <Plug>(ale_next_wrap)
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
let g:test#custom_transformations = {'python_module': function({cmd -> 'python3 -m '.cmd})}
let g:test#transformation = 'python_module'
let g:test#python#runner = 'pytest'

" coc config
" set completeopt=noinsert,menuone,noselect
set shortmess+=c
" use <tab> for trigger completion and navigate to the next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
let g:coc_global_extensions = [
    \  'coc-tsserver',
    \  'coc-json',
    \  'coc-pyls',
    \  'coc-yaml',
    \  'coc-html',
    \  'coc-snippets',
    \  'coc-go',
\ ]

let g:lc_languages = ["typescript", "python", "typescript.tsx", "go", "cpp"]
function! LC_maps()
    if index(g:lc_languages, &filetype) != -1
        nmap <buffer> <silent> <C-]> <Plug>(coc-definition)
        nmap <buffer> <silent> gr <Plug>(coc-references)
        nmap <buffer> <silent> <C-w><C-]> :vsplit<CR>:call CocAction('jumpDefinition')<CR>
        nmap <buffer> <silent> K :call CocAction('doHover')<CR>
    endif
endfunction
autocmd FileType * call LC_maps()

" python config
let g:python_highlight_indent_errors = 0
let g:python_highlight_space_errors = 0
let g:python_highlight_all = 1
abbreviate dbg import ipdb; ipdb.set_trace()
nmap <silent> <leader>p ^f(a<CR><ESC>gE%i<CR><ESC>=i(

nnoremap <leader>a :Ag <C-R><C-W><CR>

" commands
command! -range=% JSONformat :<line1>,<line2>!python -m json.tool
command! -range=% XMLformat :<line1>,<line2>!xmllint --format -
command! -range EscapeForwardSlash :<line1>,<line2>s,/,\\/
command! -range SpongebobEscape :<line1>,<line2>execute "normal qa~lq100@a"
" command! -range SpongebobEscape :<line1>,<line2>normal C


function! SpongebobEscapeFunc()
endfunction
function! GetBufferNames()
    let bufnrs = map(filter(copy(getbufinfo()), {i,b -> b.listed && len(b.name)}), 'v:val.bufnr')
    let filtered_bufnrs = filter(copy(bufnrs), {i,b -> getbufvar(b, '&buftype') == ''})
    let full_paths = map(copy(filtered_bufnrs), 'bufname(v:val)')
    return map(full_paths, {i,b -> fnamemodify(b, ':.')})
endfunction

function! GetBufferNames_sh()
    let buffer_names = GetBufferNames()
    if len(buffer_names)
        let buffers_str = join(buffer_names, "\n")."\n"
        let colors_str = '\e[34m%s\e[0m'
        let command_str = 'printf "'.colors_str.'" "'.buffers_str.'"'
        return 'bash -c '''.command_str.''';'
    else
        return ''
    endif
endfunction

function! GetFZFCommand_sh()
    let search_cmd = 'git ls-files --recurse-submodules'
    let buffer_names = GetBufferNames()
    if len(buffer_names)
        let filter_grep = 'grep -Ev "^'.join(buffer_names, '$|^').'$"'
        let search_cmd = search_cmd.' | '. filter_grep
    endif
    return search_cmd.';'
endfunction

command! FZFBuffers call fzf#run(fzf#wrap({
            \'source': GetBufferNames_sh().GetFZFCommand_sh(),
            \'options': '--multi',
            \}))
