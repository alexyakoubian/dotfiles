#!/bin/bash
#
# Much taken from Carl Jackson's install.sh:
# https://github.com/zenazn/dotfiles/blob/master/install.sh

ROOT=$(cd "$(dirname "$0")" && pwd)

function green { printf "\033[32m$1\033[0m\n"; }
function yellow { printf "\033[33m$1\033[0m\n"; }
function red { printf "\033[31m$1\033[0m\n"; }

# Install a file or directory to a given path by symlinking it, printing nice
# things along the way.
function install {
    local from="$1" to="$2" from_="$ROOT/$1" to_="$HOME/$2"

    if [ ! -e "$from_" ]; then
        red "ERROR: $from doesn't exist! This is an error in $0"
        return 1
    fi

    if [ ! -e "$to_" ]; then
        yellow "Linking ~/$to => $from"

        if [ -d "$from_" ]; then
            ln -s "$from_/" "$to_"
        else
            ln -s "$from_" "$to_"
        fi
    else
        local link
        link=$(readlink "$to_")
        if [ "$?" == 0 -a \( "$link" == "$from_" -o "$link" == "$from_/" \) ]; then
            green "Link ~/$to => $from already exists!"
        else
            red "Error linking ~/$to to $from: $to already exists!"
        fi
    fi
}

function install_dot {
    install "$1" ".$1"
}

function ask {
    local question="$1" default_y="$2" yn
    if [ -z "$default_y" ]; then
        read -p "$question (y/N)? "
    else
        read -p "$question (Y/n)? "
    fi
    yn=$(echo "$REPLY" | tr "A-Z" "a-z")
    if [ -z "$default_y" ]; then
        test "$yn" == 'y' -o "$yn" == 'yes'
    else
        test "$yn" == 'n' -o "$yn" == 'no'
    fi
}

install_dot "bash_profile"
install_dot "bashrc"
install_dot "vimrc"
install_dot "vim"
install_dot "gitconfig"
install_dot "gitignore"
install_dot "tmux.conf"
install_dot "gemrc"

if ! git config --get-regexp submodule* > /dev/null; then
    if ask "Initialize submodules?"; then
        git submodule init
        git submodule update
    fi
fi

if command -v vim > /dev/null ; then
    if ask "Install Vundle for Vim?"; then
        vim +BundleInstall +qall
    fi
fi
