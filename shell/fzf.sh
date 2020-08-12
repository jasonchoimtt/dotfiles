if [[ -z "$INTERACTIVE" ]] || [[ -n "$SSH_CLIENT" ]]; then
    return
fi

# Initialize fzf and related fuzzy finding, if available
if [[ "$(uname -s)" == "Darwin" ]]; then
    # Assume installed from Homebrew
    fzf_path=/usr/local/opt/fzf/shell/
else
    fzf_path=/usr/share/doc/fzf/examples/
fi

if [[ -f "$fzf_path/completion.$SHELL_TYPE" ]]; then
    source "$fzf_path/completion.$SHELL_TYPE"
    source "$fzf_path/key-bindings.$SHELL_TYPE"

    if which rg > /dev/null 2>&1; then
        export FZF_DEFAULT_COMMAND='rg --files'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    elif which ag > /dev/null 2>&1; then
        export FZF_DEFAULT_COMMAND='ag -g ""'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi

    if [[ "$SHELL_TYPE" == zsh ]]; then
        _lazycomp() {
            local orig_lbuf=$LBUFFER tokens=(${(z)LBUFFER}) prefix lbuf

            if [[ "$LBUFFER" == *\  ]]; then
                prefix=
                lbuf=$LBUFFER
            else
                prefix=${tokens[-1]}
                lbuf=${LBUFFER:0:-${#prefix}}
            fi

            prefix=$prefix "$2" "$lbuf"

            if [[ -z "$lbuf" && "$orig_lbuf" != "$LBUFFER" ]]; then
                LBUFFER="$1 $LBUFFER"
                zle accept-line
            else
                false
            fi
        }

        _fzf_complete_quoted() {
            # fzf uses some magic name mangling to do the post processing action
            # so we wrap it to trigger _fzf_complete_quoted_post
            _fzf_complete "$@"
        }

        _fzf_complete_quoted_post() {
            while read item; do
                echo "${$(printf "%q" "$item")/\\~/~}"
            done
        }

        _xcd_impl() {
            local opts=""
            [ -n $LBUFFER ] && opts="--multi"
            find "${cdxpath[@]}" -not -path '*/\.*' -maxdepth 2 -type d | _fzf_complete_quoted $opts "$@"
        }
        xcd() { _lazycomp 'cd' _xcd_impl; }
        zle -N xcd
        bindkey '\Cxc' xcd

        _xcdr_impl() {
            cdr -l | while read line; do
                echo ${line[6,${#line}]}
            done | _fzf_complete_quoted "" "$@"
        }
        xcdr() { _lazycomp 'cd' _xcdr_impl; }
        zle -N xcdr
        bindkey '\Cxd' xcdr

        _xvim_impl() {
            while read line; do
                if [[ $line =~ '^> .*' ]]; then
                    line=${line[3,${#line}]}
                    [ -f ${line/\~/$HOME} ] && [[ $line =~ '~' ]] && echo $line
                fi
            done < ~/.viminfo | _fzf_complete_quoted "--multi" "$@"
        }
        xvim() { _lazycomp 'vim' _xvim_impl; }
        zle -N xvim
        bindkey '\CxF' xvim

        _xvimopen_impl() {
            if [[ "$prefix" == */ && -d "$prefix" && "$prefix" != *\ * ]]; then
                (cd "$prefix" && $=FZF_DEFAULT_COMMAND) | prefix= _fzf_complete_quoted "--multi --prompt=>$prefix" "$1$prefix"
            else
                $=FZF_DEFAULT_COMMAND | _fzf_complete_quoted "--multi" "$@"
            fi
        }
        xvimopen() { _lazycomp 'vim' _xvimopen_impl; }
        zle -N xvimopen
        bindkey '\Cf' xvimopen

        _xvimopen_all_impl() {
            if [[ "$prefix" == */ && -d "$prefix" && "$prefix" != *\ * ]]; then
                (cd "$prefix" && ag -u -g "") | prefix= _fzf_complete_quoted "--multi --prompt=>$prefix" "$1$prefix"
            else
                ag -u -g "" | _fzf_complete_quoted "--multi" "$@"
            fi
        }
        xvimopen_all() { _lazycomp 'vim' _xvimopen_all_impl; }
        zle -N xvimopen_all
        bindkey '\Cxf' xvimopen_all

        _xopen_impl() {
            $=FZF_DEFAULT_COMMAND | _fzf_complete_quoted "--multi" "$@"
        }
        xopen() { _lazycomp 'open' _xopen_impl; }
        zle -N xopen
        bindkey '\Cxo' xopen

        _is_git() {
            if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
                true
            else
                zle -M "not a git repository"
                false
            fi
        }

        _xgitstatus_impl() {
            _is_git || return
            git -c color.status=always status -s | _fzf_complete "--multi --ansi --nth=2" "$@"
        }
        _xgitstatus_impl_post() {
            cut -b 3- | while read item; do
                echo "${$(printf "%q" "$item")/\\~/~}"
            done
        }
        xgitstatus() { _lazycomp 'vim' _xgitstatus_impl; }
        zle -N xgitstatus
        bindkey '\Cxg' xgitstatus

        _xgitlog_impl() {
            _is_git || return
            local commit=HEAD
            [[ -n "$gref" ]] && commit=$gref
            local count=$(( $(git rev-list --count $commit) - 1 ))
            local min=$(( $count > 9 ? 9 : $count ))
            git --no-pager log --pretty=oneline --color --abbrev-commit $commit~$min..$commit | \
                _fzf_complete "--multi --ansi --nth=1" "$@"
        }
        _xgitlog_impl_post() {
            cut -d ' ' -f 1
        }
        xgitlog() { _xgitlog_impl; }
        zle -N xgitlog
        bindkey '\CxG' xgitlog
    fi
else
    if [ $SHELL_TYPE '==' bash ]; then
        bind -x '"\C-f": "vimopen"'
    fi
fi

# vim:ft=zsh:
