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

" make register-global replacements the default
set gdefault

" highlight pasted text
nnoremap gp `[v`]

" https://github.com/neovim/neovim/issues/7994
au InsertLeave * set nopaste

" search options
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

nnoremap <C-w>z :tab split<CR>

" fold settings
set foldmethod=indent
set foldlevelstart=99

" don't redraw during macros
set lazyredraw
set cursorline

" sane defaults for languages not covered by file plugins
set expandtab
set shiftround
set shiftwidth=4
set softtabstop=4

" autocmds
autocmd BufNewFile,BufRead *.sls  set syntax=yaml
autocmd filetype crontab setlocal nobackup nowritebackup

" add toggle for pinning a window at a size
nnoremap ]st :set winfixheight<CR>
nnoremap [st :set nowinfixheight<CR>

" use mouse
set mouse=a

" disable preview window
set completeopt=menuone,noselect,noinsert
set pumheight=30

" Leader commands
map <SPACE> <leader>
nnoremap <silent> <Leader>c :let @+ = expand("%")<CR> |" copy filepath
nnoremap <leader>sv :source $MYVIMRC<CR>
nnoremap <silent> <leader>l :redraw!<CR>

""" PLUGINS
call plug#begin('~/.local/share/nvim/plugged')

" completion
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'
Plug 'ajh17/VimCompletesMe'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'tpope/vim-sleuth'

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

" usability
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-rsi'
Plug 'machakann/vim-sandwich'
Plug 'wellle/targets.vim'
Plug 'peterrincker/vim-argumentative'
Plug 'janko-m/vim-test'
Plug 'mhinz/vim-grepper'
Plug 'romainl/vim-qf'
Plug 'kana/vim-textobj-user'
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

" python
Plug 'davidhalter/jedi-vim', { 'for': 'python' }
Plug 'zchee/deoplete-jedi', { 'for': 'python' }
Plug 'vim-python/python-syntax', { 'for': 'python' }
Plug 'bps/vim-textobj-python', { 'for': 'python' }

" typescript
Plug 'leafgarland/typescript-vim', { 'for': 'typescript' }
Plug 'mhartington/nvim-typescript', { 'do': './install.sh', 'for': 'typescript' }

" other languages
Plug 'Glench/Vim-Jinja2-Syntax', { 'for': 'jinja.html' }
Plug 'sheerun/vim-polyglot'
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }

call plug#end()

" theming
set termguicolors
colorscheme base16-default-dark
set background=dark

" NEOVIM SPECIFIC
set inccommand=nosplit

" neovim remote
let $VISUAL = 'nvr -cc split --remote-wait'

" NEOVIM TERMINAL CONFIG
tnoremap <esc> <C-\><C-n>
autocmd BufEnter,BufWinEnter,WinEnter term://* startinsert

autocmd TermOpen * call InitTermBuffer()
function! InitTermBuffer()
    setlocal nonumber
    nnoremap <buffer> <C-c> :startinsert<CR>
    nnoremap <buffer> <C-b> :startinsert<CR>
    nnoremap <buffer> <C-e> :startinsert<CR><C-e>
    nnoremap <buffer> <C-a> :startinsert<CR><C-a>
    nnoremap <buffer> q :startinsert<CR>q
endfunction

function! MakeTermSplit(direction)
    if(a:direction == 'v')
        vsplit | terminal
    else
        split | terminal
    endif

    set bufhidden=delete
    startinsert
endfunction

nnoremap <C-w>\| :call MakeTermSplit('v')<CR>
nnoremap <C-w>- :call MakeTermSplit('s')<CR>

autocmd TermClose term://.//*:ranger* bprevious | bwipeout! #

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

" vim-sandwich
runtime macros/sandwich/keymap/surround.vim
let g:sandwich#recipes += [{'buns': ['{% translatable "COCONTEXTCONTEXTCONTEXTCONTEXTCONTEXTCONTEXTCONTEXTCONTEXTNTEXT" %}', '{% endtranslatable %}'], 'input': ['i']}]

" Sayonara config
nnoremap <C-q> :Sayonara!<CR>

" ale config
let g:ale_linters = {
\   'typescript': ['tsserver'],
\   'python': ['flake8', 'mypy'],
\}
let g:ale_fixers = {
\   'python': ['isort', 'trim_whitespace'],
\}
let g:ale_fix_on_save = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 1

" gutentags config
let g:gutentags_cache_dir = 'build/gutentags'
set nofsync

" vimwiki config
let g:vimwiki_folding='syntax'
nmap <Leader>d <Plug>VimwikiMakeDiaryNote
nmap <Leader>di <Plug>VimwikiDiaryIndex
nmap <Leader>dig <Plug>VimwikiDiaryGenerateLinks

" ranger config
let g:ranger_map_keys = 0
nnoremap - :Ranger<CR>

" fugitive config
nmap <Leader>g :Git<space>

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
noremap <Leader>t :TagbarToggle<CR>
let g:tagbar_left = 1

" vim-qf config
nmap [l <Plug>(ale_previous_wrap)
nmap ]l <Plug>(ale_next_wrap)
noremap <leader>q <Plug>(qf_qf_toggle_stay)
let g:qf_mapping_ack_style = 1

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
let g:test#custom_transformations = {'service_venv': function({cmd -> 'service_venv '.cmd})}
let g:test#transformation = 'service_venv'
let g:test#python#runner = 'pytest'

" python config
let g:jedi#completions_enabled = 0
let g:jedi#goto_command = "<c-]>"
let g:jedi#rename_command = ""
let g:deoplete#enable_at_startup = 1
let g:python_highlight_indent_errors = 0
let g:python_highlight_space_errors = 0
let g:python_highlight_all = 1
abbreviate dbg import ipdb; ipdb.set_trace()
nmap <silent> <leader>p ^f(a<CR><ESC>gE%i<CR><ESC>=i(

nnoremap <leader>a :Ag <C-R><C-W><CR>


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
    let search_cmd = 'git ls-files'
    let buffer_names = GetBufferNames()
    if len(buffer_names)
        let filter_grep = 'grep -Ev "^'.join(buffer_names, '$|^').'$"'
        let search_cmd = search_cmd.' | '. filter_grep
    endif
    return search_cmd.';'
endfunction

command! FZFBuffers call fzf#run(fzf#wrap({
            \'source': GetBufferNames_sh().GetFZFCommand_sh(),
            \'options': ['--multi'],
            \}))

" TODO experimental, currently has problem due to nvim resize bug
let g:named_terms = {}
function! OpenNamedTerm(name, direction)
    if has_key(g:named_terms, a:name)
        let l:bufnr = g:named_terms[a:name]

        if(a:direction == 'v')
            vsplit
        else
            split
        endif
        execute 'buffer' l:bufnr
    else
        if(a:direction == 'v')
            vsplit term://$SHELL
        else
            split term://$SHELL
        endif
        let g:named_terms[a:name] = bufnr('%')
    endif
endfunction
