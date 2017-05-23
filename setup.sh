(
    set -e
    git clone https://github.com/jasonchoimtt/dotfiles .dotfiles
    cd .dotfiles
    ./bootstrap.sh
    ./install.sh
)
