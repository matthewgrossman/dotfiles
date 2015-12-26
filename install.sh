# ensure vim, tmux, and git are all installed

# symlink the dotfiles
ln -s $HOME/dotfiles/.vim $HOME/.vim
ln -s $HOME/dotfiles/.tmux.conf $HOME/.tmux.conf
ln -s $HOME/dotfiles/zshrc $HOME/.zshrc

# vim/vundle setup
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall
