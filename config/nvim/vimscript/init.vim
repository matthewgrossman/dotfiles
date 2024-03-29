" don't error out when quitting w/ an open terminal
" https://github.com/neovim/neovim/issues/14061
command Z w | qa
cabbrev wqa Z
cabbrev wqa! Z

abbreviate dbg breakpoint()
abbreviate iii import ipdb; ipdb.set_trace()
" nnoremap <leader>a <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>a :Telescope grep_string search=<CR>

" commands
command! -range=% JSONformat :<line1>,<line2>!python -m json.tool
command! -range=% XMLformat :<line1>,<line2>!xmllint --format -
command! -range EscapeForwardSlash :<line1>,<line2>s,/,\\/
command! -range SpongebobCase :<line1>,<line2>luado return require('spongebob')(line)

" vim-grepper config
" TODO just drop for telescope?
nmap gs <plug>(GrepperOperator)
xmap gs <plug>(GrepperOperator)
" let g:grepper = {
" \   'highlight': 1,
" \   'tools': ['rg']
" \ }

" vim-test config
" nmap <silent> <leader>r :TestNearest<CR>
" nmap <silent> <leader>R :TestFile<CR>
function! ClipboardStrategy(cmd)
    let @+ = a:cmd
endfunction
let g:test#custom_strategies = {'clipboard': function('ClipboardStrategy')}
let g:test#strategy = 'clipboard'
" let g:test#custom_transformations = {'service_venv': function({cmd -> 'service_venv '.cmd})}
" let g:test#custom_transformations = {'python_module': function({cmd -> 'python3 -m '.cmd})}
" let g:test#transformation = 'python_module'
" let g:test#python#runner = 'pytest'

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
