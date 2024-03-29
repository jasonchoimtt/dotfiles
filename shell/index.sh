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

[[ -z "$PROMPT_COLOR" ]] && PROMPT_COLOR=4

# Variables
export PATH=~/local/bin:~/.dotfiles/bin:$PATH:~/.cabal/bin

export LC_ALL="en_US.utf-8"

case $- in
    *i*) INTERACTIVE=1;;
esac


if [[ -n "$INTERACTIVE" ]]; then
    export CLICOLOR=true
    export EDITOR=vim
    export MANPAGER="bash -c \"vim -n -c 'setl ft=man ro nomod noma' -c 'nmap q ZQ' -c 'sign unplace *' </dev/tty <(col -b)\""
    export LESS="-R"

    # Aliases
    alias l='ls'
    [[ "$(uname -s)" != "Darwin" ]] && alias ls='ls --color=auto'
    alias la='ls -al'
    alias mv='mv -i'
    alias cp='cp -i'

    alias g='git'
    alias vgit='vim . -c Gstatus -c only -c "normal 8G"'
    alias jsont='python3 -m json.tool'
    vhich() { vim "$(which "$1")"; }

    mn() { "$@" --help 2>&1 | less -R; }

    mkdcd() { mkdir "$1" && cd "$1"; }

    if which ag > /dev/null 2>&1; then
        alias \?='ag --pager "less"'
    fi

    alias vimopen='vim -c CtrlP'
    if [[ $SHELL_TYPE == zsh ]]; then
        _vimopen() {
            BUFFER="vimopen"
            zle accept-line
        }
        zle -N _vimopen
        bindkey '\Cf' _vimopen
    else
        bind -x '"\C-f": "vimopen"'
    fi

    # Temporary environmental variable helpers
    doenv_docker() {
        if which docker-machine > /dev/null 2>&1; then
            local env_str
            if env_str=$(docker-machine env default 2> /dev/null); then
                eval $env_str
            fi
        fi
    }

    doenv_python() {
        if [[ -f venv/bin/activate ]]; then
            if [[ $(file venv/bin/python) == *arm64 ]] && [[ $(uname -m) != arm64 ]] && [[ "$SHELL" == /usr/local/bin/zsh ]]; then
                echo "Switching to ARM zsh"
                exec env SHELL=/bin/zsh arch --arm64e /bin/zsh
            else
                source venv/bin/activate
            fi
        fi
    }

    doenv() {
        doenv_docker
        doenv_python
    }

    # Allow Ctrl-S, Ctrl-Q to be used in vim
    stty -ixon

    source "$DOTFILES_ROOT/shell/fzf.sh"

    # Horizontal rule
    HR_COLOR=24
    hr() {
        _color_seq $HR_COLOR "$(printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' '▁')"
        _color_seq $HR_COLOR "$(printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' '▔')"
    }

    # List of "workspace" directories
    cdxpath=(~)
fi

pastecmd() {
    if [[ -z "$1" ]]; then
        echo "Usage: pastecmd [command name]" >&2
    else
        eval "$1() { $(pbpaste) \"\$@\" ; }"
    fi
}

# Local shell
[[ -f ~/.localrc ]] && source ~/.localrc


if [[ -n "$INTERACTIVE" ]] && [[ -z "$SSH_CLIENT" ]]; then
    printf "$(_color_seq 244)You are at: $PWD @ $(hostname -f)$(_color_seq)\n"
fi
# vim:ft=zsh:
