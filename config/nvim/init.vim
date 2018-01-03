" normal setings
set hidden

" move by screen-line instead of text-line
nnoremap j gj
nnoremap k gk

" make capital Y act more normal
nnoremap Y y$

" make saving easier
nnoremap <c-s> :w<CR>
inoremap <c-s> <c-o>:w<CR>
vnoremap <c-s> <esc>:w<CR>gv

" paste from the copy buffer
vnoremap x "0p

" easily replace recent macro
nnoremap Q @q

" improve visual commands
vnoremap Q :normal @q<CR>
vnoremap . :normal .<CR>

" make register-global replacements the default
set gdefault

" highlight pasted text
nnoremap gp `[v`]

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

" fold settings
set foldmethod=indent
set foldlevelstart=99

" use mouse
set mouse=a

" Leader commands
map <SPACE> <leader>
nnoremap <silent> <Leader>c :let @+ = expand("%")<CR> |" copy filepath
nnoremap <leader>sv :source $MYVIMRC<CR>

" TODO use vim polyglot
set expandtab
set shiftround
set shiftwidth=4
set softtabstop=4

""" PLUGINS

if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif
call plug#begin('~/.local/share/nvim/plugged')

" completion
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'
Plug 'ajh17/VimCompletesMe'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

" file management
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all'  }
Plug 'junegunn/fzf.vim'
Plug 'mhinz/vim-sayonara', { 'on': 'Sayonara' }
Plug 'tpope/vim-fugitive'

Plug 'tpope/vim-rhubarb'
Plug 'ludovicchabant/vim-gutentags'
Plug 'majutsushi/tagbar'

" usability
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-rsi'
Plug 'wellle/targets.vim'
Plug 'peterrincker/vim-argumentative'
Plug 'godlygeek/tabular'
Plug 'janko-m/vim-test'
Plug 'mhinz/vim-grepper'
Plug 'romainl/vim-qf'

" ui
Plug 'mhinz/vim-signify'
Plug 'w0rp/ale'
Plug 'machakann/vim-highlightedyank'
Plug 'chriskempson/base16-vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" productivity
Plug 'vimwiki/vimwiki'

" python
Plug 'davidhalter/jedi-vim'
Plug 'zchee/deoplete-jedi'
Plug 'vim-python/python-syntax'

" languages
Plug 'pangloss/vim-javascript'
Plug 'plasticboy/vim-markdown'
Plug 'leafgarland/typescript-vim'
Plug 'sheerun/vim-polyglot'

call plug#end()

" theming
set termguicolors
set background=dark
colorscheme base16-default-dark

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
        vsplit term://$SHELL
    else
        split term://$SHELL
    endif

    set bufhidden=delete
    startinsert
endfunction

nnoremap <C-w>\| :call MakeTermSplit('v')<CR>
nnoremap <C-w>- :call MakeTermSplit('s')<CR>

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

" Sayonara config
nnoremap <C-c> :Sayonara!<CR>

" ale config
let g:ale_lint_on_text_changed = 0
let g:ale_lint_on_save = 1
let g:ale_fixers = {
\   'python': ['isort', 'trim_whitespace'],
\}
let g:ale_fix_on_save = 1

" highlightedyank config
let g:highlightedyank_highlight_duration = 500

" fzf config
nnoremap <c-p> :FZFBuffers<cr>
let g:fzf_layout = {'window': 'enew'}

" vim-grepper config
nmap gs <plug>(GrepperOperator)
xmap gs <plug>(GrepperOperator)
let g:grepper = {
\   'prompt': 0,
\   'highlight': 1,
\   'tools': ['ag']
\ }
noremap <Leader>g :Grepper -prompt

" vim-signify config
let g:signify_vcs_list = ['git']

" tagbar config
noremap <Leader>t :TagbarToggle<CR>
let g:tagbar_left = 1

" vim-qf config
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

" python config
let g:jedi#completions_enabled = 0
let g:jedi#goto_command = "<c-]>"
let g:jedi#rename_command = ""
let g:deoplete#enable_at_startup = 1
let g:deoplete#sources#jedi#show_docstring = 0
let g:python_highlight_indent_errors = 0
let g:python_highlight_space_errors = 0
let g:python_highlight_all = 1

" fix this by using the --query arg as the initial
nnoremap <leader>a :Ag <C-R><C-W><CR>

" autocmds
autocmd BufNewFile,BufRead *.sls  set syntax=yaml
autocmd filetype crontab setlocal nobackup nowritebackup

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
        let filter_grep = 'grep -Ev "'.join(buffer_names, '|').'"'
        let search_cmd = search_cmd.' | '. filter_grep
    endif
    return search_cmd.';'
endfunction

command! FZFBuffers call fzf#run(fzf#wrap({
            \'source': GetBufferNames_sh().GetFZFCommand_sh(),
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
