#!/usr/bin/env bash

DOTFILES_ROOT=$(pwd -P)

set -e

info () {
  printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

user () {
  printf "\r  [ \033[0;33m??\033[0m ] $1\n"
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

if ! [ -d "$DOTFILES_ROOT/vim/vim.symlink/bundle" ]; then
    user "Install Vundle ([*] continue, [s]kip)?"

    read action

    if [ "$action" != 's' ]; then
        mkdir "$DOTFILES_ROOT/vim/vim.symlink/bundle"
        git clone https://github.com/VundleVim/Vundle.vim.git "$DOTFILES_ROOT/vim/vim.symlink/bundle/Vundle.vim"
        vim -c "VundleInstall"
    fi
else
    info "Vundle is already installed."
fi

if ! [[ -d "$DOTFILES_ROOT/tmux/tmux.symlink/plugins" ]]; then
    user "Install tmux plugin manager ([*] continue, [s]kip)?"

    read action

    if [[ "$action" != 's' ]]; then
        mkdir -p "$DOTFILES_ROOT/tmux/tmux.symlink/plugins"
        git clone https://github.com/tmux-plugins/tpm "$DOTFILES_ROOT/tmux/tmux.symlink/plugins/tpm"
        info "Run tmux to install plugins."
    fi
else
    info "Tmux plugin manager is already installed."
fi
