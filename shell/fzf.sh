if [[ -z "$INTERACTIVE" ]] || [[ -n "$SSH_CLIENT" ]]; then
    return
fi

# Initialize fzf and related fuzzy finding, if available
if [ -f ~/.fzf.$SHELL_TYPE ]; then
    source ~/.fzf.$SHELL_TYPE
    if which ag > /dev/null 2>&1; then
        export FZF_DEFAULT_COMMAND='ag -g ""'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi

    if [ $SHELL_TYPE '==' zsh ]; then
        _lazycomp() {
            local lbuf=$LBUFFER
            eval "$2"
            if [[ -z $lbuf && -n $LBUFFER ]]; then
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
            find "${cdxpath[@]}" -not -path '*/\.*' -maxdepth 2 -type d | _fzf_complete_quoted $opts "$LBUFFER"
        }
        xcd() { _lazycomp 'cd' _xcd_impl; }
        zle -N xcd
        bindkey '\Cxc' xcd

        _xcdr_impl() {
            cdr -l | while read line; do
                echo ${line[6,${#line}]}
            done | _fzf_complete_quoted "" "$LBUFFER"
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
            done < ~/.viminfo | _fzf_complete_quoted "--multi" "$LBUFFER"
        }
        xvim() { _lazycomp 'vim' _xvim_impl; }
        zle -N xvim
        bindkey '\CxF' xvim

        _xvimopen_impl() {
            ag -g "" | _fzf_complete_quoted "--multi" "$LBUFFER"
        }
        xvimopen() { _lazycomp 'vim' _xvimopen_impl; }
        zle -N xvimopen
        bindkey '\Cf' xvimopen

        _xvimopen_all_impl() {
            ag -a -g "" | _fzf_complete_quoted "--multi" "$LBUFFER"
        }
        xvimopen_all() { _lazycomp 'vim' _xvimopen_all_impl; }
        zle -N xvimopen_all
        bindkey '\Cxf' xvimopen_all

        _xopen_impl() {
            ag -g "" | _fzf_complete_quoted "--multi" "$LBUFFER"
        }
        xopen() { _lazycomp 'open' _xopen_impl; }
        zle -N xopen
        bindkey '\Cxo' xopen

        _xgitstatus_impl() {
            git -c color.status=always status -s | _fzf_complete "--multi --ansi --nth=2" "$LBUFFER"
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
            local commit=HEAD
            [[ -n "$gref" ]] && commit=$gref
            local count=$(( $(git rev-list --count $commit) - 1 ))
            local min=$(( $count > 9 ? 9 : $count ))
            git --no-pager log --pretty=oneline --color --abbrev-commit $commit~$min..$commit | \
                _fzf_complete "--multi --ansi --nth=1" "$LBUFFER"
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
