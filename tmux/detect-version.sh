#!/usr/bin/env bash
set -e

# Require that tmux version satisfies lower <= version < upper
# Ignoring alphabetical suffixes (e.g. tmux 3.0a is considered 3.0)
lower=$1
upper=$2

version=$(tmux -V | sed 's/^tmux \([0-9.]\+\).*/\1/')

if [[ -n "$lower" ]]; then
    (( $(echo "$version >= $lower" | bc -l) ))
fi
if [[ -n "$upper" ]]; then
    (( $(echo "$version < $upper" | bc -l) ))
fi
