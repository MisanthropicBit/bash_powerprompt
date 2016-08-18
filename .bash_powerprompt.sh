#!/usr/bin/env bash

# A `bash` script that gives you a visually pleasing, informative and customisable
# command line prompt.
#
# Author: MisanthropicBit
#
# Features:
#   - Written in pure bash with no dependencies
#   - Multiple predefined themes
#   - Highly customisable
#
# Requirements:
#   - A bash shell
#
# Installation:
#   1. (OPTIONAL) Run install.sh to set up a symlink to your home directory
#   2. Add the following to you in ~/.bashrc or ~/.profile etc.
#
#      if [ -e ~/.bash_powerline.sh ]; then
#          source ~/.bash_powerline.sh
#          export BASH_POWERPROMPT_THEME=<your default theme> # Optional
#          export PROMPT_COMMAND=__bash_powerline_prompt
#      fi
#
# For more information about customisation and creating your own themes, see
# 'CUSTOMISING.md'.

__bash_powerprompt() {
    # Must come before anything else than could return an exit code
    local BASH_POWERPROMPT_EXIT_STATUS=$?

    ######################################################################
    # COLOR VARIABLES
    ######################################################################
    local COLOR_ESCAPE_CODE='\033'
    local FG_COLOR_PREFIX_256='38;5'
    local BG_COLOR_PREFIX_256='48;5'
    local FG_COLOR_PREFIX_TRUE_COLOR='38;2'
    local BG_COLOR_PREFIX_TRUE_COLOR='48;2'
    local RESET_FG_COLORS="\[$COLOR_ESCAPE_CODE[39m\]"
    local RESET_BG_COLORS="\[$COLOR_ESCAPE_CODE[49m\]"
    local RESET_ATTRIBUTES="\[$COLOR_ESCAPE_CODE[0m\]" # Resets all ANSI attributes
    local BASH_POWERPROMPT_COLOR_FORMAT_16="\[$COLOR_ESCAPE_CODE[%s;%sm\]"
    local BASH_POWERPROMPT_COLOR_FORMAT_256="\[$COLOR_ESCAPE_CODE[${FG_COLOR_PREFIX_256};%s;${BG_COLOR_PREFIX_256};%sm\]"
    local BASH_POWERPROMPT_COLOR_FORMAT_TRUECOLOR="\[$COLOR_ESCAPE_CODE[${FG_COLOR_PREFIX_TRUE_COLOR};%s;${BG_COLOR_PREFIX_TRUE_COLOR};%sm\]"
    ######################################################################

    # Loads a given theme (reverts to the default theme on error)
    __load_theme() {
        if [[ -n "$BASH_POWERPROMPT_THEME" ]]; then
            local script_dir="$(__get_script_dir)"
            local theme_path="$script_dir/themes/$BASH_POWERPROMPT_THEME.theme"

            if [ -r "$theme_path" ]; then
                local theme="$BASH_POWERPROMPT_THEME"

                # Load the default theme and let custom themes override them
                source "$script_dir/themes/default.theme"
                __set_theme

                # Load the custom theme unless it is the default
                if [ "$theme" != "default" ]; then
                    source $theme_path
                    __set_theme
                fi
            else
                printf "%s" "Error: Failed to load theme '$BASH_POWERPROMPT_THEME'\n"
            fi
        fi
    }

    # Returns the directory that this script is located in, no matter where the function is called from
    # Credits: http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
    __get_script_dir() {
        if [ -n "$BASH_POWERPROMPT_DIRECTORY" ]; then
            printf "%s" "$BASH_POWERPROMPT_DIRECTORY"
        else
            local source="${BASH_SOURCE[0]}"
            local old_cdpath="$CDPATH"
            unset CDPATH

            while [ -L "$source" ]; do
                local dir="$(cd -P "$(dirname "$source")" && pwd)"
                source="$(readlink "$source")"
                [[ $source != /* ]] && source="$dir/$source"
            done

            BASH_POWERPROMPT_DIRECTORY="$(cd -P "$(dirname "$source")" && pwd)"
            CDPATH="$old_cdpath"
            printf "%s" "$BASH_POWERPROMPT_DIRECTORY"
        fi
    }

    # Returns a string representing the current OS, e.g. 'Darwin' for Mac systems
    __get_os_name() {
        uname -s
    }

    # Returns the name of the current user
    __get_username() {
        if [ $(__get_os_name) == "Darwin" ]; then
            id -un # 'whoami' has been obsoleted on OSX
        else
            whoami
        fi
    }

    __get_hostname() {
        if [ $(__get_os_name) == "Darwin" ]; then
            scutil --get ComputerName
        else
            hostname -s
        fi
    }

    # Returns the current working directory
    __get_cwd() {
        local cwd=$(pwd)

        if [ "$BASH_POWERPROMPT_USE_TILDE_FOR_HOME" -eq 1 ]; then
            cwd=${cwd/$HOME/\~}
        fi

        printf "%s" "$cwd"
    }

    # Gets the last part of a path
    __get_path_basename() {
        basename "$1"
    }

    # Gets the n first elements of a path
    __get_path_heads() {
        local n=$2

        if [ "${$1:0:1}" == '/' ]; then
            n=$((n + 1))
        fi

        printf "%s" "$1" | cut -d/ "-f1-$n"
    }

    # Gets the n last elements of a path
    __get_path_tails() {
        local n=$2

        printf "%s" "$1" | rev | cut -d/ -f1-"$n" | rev
    }

    # Return the number of columns available to the prompt
    __get_columns() {
        # Get the environment variable or if that fails, get it from terminfo
        if [ -n "$COLUMNS" ]; then
            printf "%s" "$COLUMNS"
        else
            tput cols
        fi
    }

    # Returns 0 if the branch is clean, 1 otherwise
    __is_git_branch_clean() {
        2>/dev/null 1>&2 git status --ignore-submodules | grep 'nothing to commit'
    }

    # Returns 0 if the current directory is a git branch, 1 otherwise
    __is_git_branch() {
        2>/dev/null 1>&2 git status --ignore-submodules
    }

    # Get the current git branch. Use .git-prompt.sh if it is available
    __get_current_git_branch() {
        local git_branch=''

        if type __git_ps1 > /dev/null; then
            git_branch="$(__git_ps1 '%s')"
        else
            # This requires git v1.7+
            git_branch=$(git rev-parse --abbrev-ref HEAD)
        fi

        printf "%s" "$git_branch"
    }

    ######################################################################

    # Attempt to load the current theme
    __load_theme

    # Prints a single separator
    __print_separator() {
        local prev_symbol="$2"

        if [ -n "$prev_symbol" ]; then
            local i="$1"

            # Handle the case where the solid powerline triangle symbol was used
            if [ "$prev_symbol" == "$BASH_POWERPROMPT_SOLID_ARROW_SYMBOL" ]; then
                local prev_bg_color="$3"
                local bg_color="$4"

                __ps1+="$(printf "${BASH_POWERPROMPT_COLOR_FORMAT}$prev_symbol" "$prev_bg_color" "$bg_color")"
            else
                # Any other separator needs its own colors
                local sfg=${BASH_POWERPROMPT_SEPARATOR_FG_COLORS[$((i - 1))]}
                local sbg=${BASH_POWERPROMPT_SEPARATOR_BG_COLORS[$((i - 1))]}

                if [[ -n "$sfg" || -n "$sbg" ]]; then
                    __ps1+="$(printf "${BASH_POWERPROMPT_COLOR_FORMAT}$prev_symbol" "$sfg" "$sbg")"
                else
                    __ps1+="$prev_symbol"
                fi
            fi
        fi
    }

    local __ps1=''
    local fg=''
    local bg=''
    local contents=''
    local PREVIOUS_SYMBOL=''
    local PREVIOUS_FG_COLOR=''
    local PREVIOUS_BG_COLOR=''

    # Assemble the entire prompt command
    for i in ${!BASH_POWERPROMPT_SECTIONS[@]}; do
        fg=${BASH_POWERPROMPT_FG_COLORS[$i]}
        bg=${BASH_POWERPROMPT_BG_COLORS[$i]}
        contents="${BASH_POWERPROMPT_SECTIONS[$i]}"

        if [[ $BASH_POWERPROMPT_IGNORE_EMPTY_SECTIONS -eq 1 && -z "$contents" ]]; then
            continue
        fi

        contents="${BASH_POWERPROMPT_LEFT_PADDING[$i]}$contents${BASH_POWERPROMPT_RIGHT_PADDING[$i]}"

        if [[ -n "$fg" || -n "$bg" ]]; then
            contents="$(printf "${BASH_POWERPROMPT_COLOR_FORMAT}$contents" "$fg" "$bg")"
        fi

        __print_separator "$i" "$PREVIOUS_SYMBOL" "$PREVIOUS_BG_COLOR" "$bg"
        __ps1+="$contents"

        # Save curent settings
        PREVIOUS_CONTENTS=$contents
        PREVIOUS_FG_COLOR=$fg
        PREVIOUS_BG_COLOR=$bg
        PREVIOUS_SYMBOL=${BASH_POWERPROMPT_SEPARATORS[$i]}
    done

    # Handle the last separator separately
    __ps1+=$(printf "$RESET_ATTRIBUTES")
    __print_separator "$i" "${PREVIOUS_SYMBOL}" "$PREVIOUS_BG_COLOR" ""

    # Must be called as the last element of the prompt to reset all colors and attributes
    __ps1+=$(printf "$RESET_ATTRIBUTES")

    __ps1+="$BASH_POWERPROMPT_PROMPT_END_SPACING"
    export PS1="$__ps1"
}
