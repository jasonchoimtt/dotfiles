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
    if [ -n "$2" ]; then
        printf "$2\e[0m\n"
    fi
}

[ -z "$PROMPT_COLOR" ] && PROMPT_COLOR=4

source "$DOTFILES_ROOT/shell/fzf.sh"

# Variables
export PATH=~/local/bin:~/.dotfiles/bin:$PATH

export CLICOLOR=true
export LC_ALL="en_US.utf-8"
export EDITOR=vim
export MANPAGER="bash -c \"vim -n -c 'setl ft=man ro nomod noma' -c 'nmap q ZQ' -c 'sign unplace *' </dev/tty <(col -b)\""


# Aliases
alias l='ls'
[ "$(uname -s)" != "Darwin" ] && alias ls='ls --color=auto'
alias la='ls -al'
alias rm='rm -i'
alias mv='mv -i'

alias vimopen='vim -c CtrlP'

alias g='git'
alias vgit='vim . -c Gstatus'

# Temporary environmental variable helpers
doenv_docker() {
    if which docker-machine > /dev/null; then
        local env_str
        if env_str=$(docker-machine env default 2> /dev/null); then
            eval $env_str
        fi
    fi
}

doenv_python() {
    [ -f venv/bin/activate ] && source venv/bin/activate
}

doenv() {
    doenv_docker
    doenv_python
}


# Local shell
[ -f ~/.localrc ] && source ~/.localrc

if [ -z "$SSH_CLIENT" ]; then
    printf "$(_color_seq 244)You are at: $PWD @ $(hostname -f)$(_color_seq)\n"
fi
# vim:ft=zsh:
