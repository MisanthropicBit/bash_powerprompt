#!/usr/bin/env bash

__symlink_install() {
    if [ -e "$3/$1" ]; then
        printf "Error: Cannot symlink $1 because it already exists in $3"
    else
        ln -s "$2/$1" "$3/$1"

        if [ $? != 0 ]; then
            printf "Error: Failed to symlink $1 (return code: $?)"
        fi
    fi
}

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)

printf "Symlinking .bash_powerprompt.sh to '$HOME'..."
__symlink_install ".bash_powerprompt.sh" "$script_dir" "$HOME"
