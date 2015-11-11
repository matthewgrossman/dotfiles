# ensure vim, tmux, and git are all installed

# base16 color scheme
git clone https://github.com/chriskempson/base16-shell.git $HOME/dotfiles/base16-shell

# symlink the dotfiles
ln -s $HOME/dotfiles/.vim $HOME/.vim
ln -s $HOME/dotfiles/.tmux.conf $HOME/.tmux.conf
ln -s $HOME/dotfiles/.zshrc $HOME/.zshrc

# vim/vundle setup
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

# tmux setup
 git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
