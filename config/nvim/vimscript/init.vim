" common typos
command! -bang Qa qa
command! -bang QA qa
command! -bang Wq wq
command! -bang WQ wq
command! -bang Wqa wqa

" paste from the copy buffer
vnoremap x "0p

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

" reload external changes
autocmd! FocusGained,BufEnter * if mode() != 'c' | checktime | endif

" Leader commands
nnoremap <silent> <Leader>c :let @+ = expand("%")<CR> |" copy filepath
nnoremap <leader>sv :source $MYVIMRC<CR>
nnoremap <silent> <leader>l :redraw!<CR>

" python config
" use host python3
let g:python3_host_prog = "/usr/local/bin/python3"

" cron config
autocmd filetype crontab setlocal nobackup nowritebackup

" NEOVIM SPECIFIC

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

nnoremap <C-w>\| :vsplit term://$SHELL <CR>:startinsert<CR>
nnoremap <C-w>- :split term://$SHELL <CR>:startinsert<CR>
nnoremap <C-w>t :tabnew <bar> :terminal<CR>a
vnoremap <C-w>\| <esc>:vsplit term://$SHELL <CR>:startinsert<CR>
vnoremap <C-w>- <esc>:split term://$SHELL <CR>:startinsert<CR>
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

" vim-easy-align config
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" file_browser config
nnoremap - :Telescope file_browser path=%:p:h<CR>

abbreviate dbg breakpoint()
" nnoremap <leader>a <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>a :Telescope grep_string search=<CR>

" commands
command! -range=% JSONformat :<line1>,<line2>!python -m json.tool
command! -range=% XMLformat :<line1>,<line2>!xmllint --format -
command! -range EscapeForwardSlash :<line1>,<line2>s,/,\\/
command! -range SpongebobCase :<line1>,<line2>luado return require('spongebob')(line)

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

" winbar config
au VimEnter,BufWinEnter * if &buftype == "" | setlocal winbar=%f | endif

" fzf config
" nnoremap <c-p> :GFiles<cr>
" let g:fzf_layout = {'window': 'enew'}
let g:fzf_action = {
    \ 'ctrl-q': 'wall | bdelete',
    \ 'ctrl-t': 'tab split',
    \ 'ctrl-x': 'split',
    \ 'ctrl-v': 'vsplit' }
