[ -n "$BASH_VERSION" ] && SHELL_TYPE=bash
[ -n "$ZSH_VERSION" ] && SHELL_TYPE=zsh

which brew > /dev/null 2>&1 && BREW_PREFIX="$(brew --prefix)"

# vim:ft=zsh:
