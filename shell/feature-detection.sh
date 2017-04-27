[ -n "$BASH_VERSION" ] && SHELL_TYPE=bash
[ -n "$ZSH_VERSION" ] && SHELL_TYPE=zsh

which brew 2> /dev/null && BREW_PREFIX="$(brew --prefix)"

# vim:ft=zsh:
