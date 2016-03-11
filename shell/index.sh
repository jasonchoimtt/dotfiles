[ -n "$BASH_VERSION" ] && SHELL_TYPE=bash
[ -n "$ZSH_VERSION" ] && SHELL_TYPE=zsh

# Utility
_color_seq() {
    local color=$1
    if [ -z $color ]; then
        printf "\e[0m"
    elif [ $color -lt 16 ]; then
        printf "\e[$(($color + 30))m"
    else
        printf "\e[38;5;${color}m"
    fi
}

[ -z "$PROMPT_COLOR" ] && PROMPT_COLOR=4

source "$DOTFILES_ROOT/shell/fzf.sh"

# Variables
export PATH=~/local/bin:$PATH

export CLICOLOR=true
export LC_ALL="en_US.utf-8"
export EDITOR=vim
export MANPAGER="bash -c \"vim -n -c 'setl ft=man ro nomod noma' -c 'nmap q ZQ' -c 'sign unplace *' </dev/tty <(col -b)\""


# Aliases
alias l='ls'
alias la='ls -al'
alias rm='rm -i'

alias vgit='vim . -c Gstatus'

[ -f ~/.localrc ] && source ~/.localrc

printf "$(_color_seq 244)You are at: $PWD @ $(hostname -f)$(_color_seq)\n"
# vim:ft=zsh:
