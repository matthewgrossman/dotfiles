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

" vim-test config
function! ClipboardStrategy(cmd)
    let @+ = a:cmd
endfunction
let g:test#custom_strategies = {'clipboard': function('ClipboardStrategy')}
let g:test#strategy = 'clipboard'

" fzf config
" nnoremap <c-p> :GFiles<cr>
" let g:fzf_layout = {'window': 'enew'}
let g:fzf_action = {
    \ 'ctrl-q': 'wall | bdelete',
    \ 'ctrl-t': 'tab split',
    \ 'ctrl-x': 'split',
    \ 'ctrl-v': 'vsplit' }
