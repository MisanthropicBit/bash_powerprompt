#!/usr/bin/env bash

# Custom bash prompt theme for 256-color terminals
# Author: MisanthropicBit
#
# Features:
#   - Written in pure bash with no dependencies
#   - Easily customisable and extendable
#   - Multiple predefined sections
#   - Fancy Unicode and Powerline symbols
#
# Requirements:
#   - A terminal capable of displaying utf-8
#   - A patched powerline font set up with your terminal
#
# Installation:
#   1. (OPTIONAL) Run install.sh to set up a symlink to your home directory
#   2. Add the following to you in ~/.bashrc or ~/.profile etc.
#
#      if [ -e ~/.bash_powerline.sh ]; then
#          source ~/.bash_powerline.sh
#          export PROMPT_COMMAND=__bash_powerline_prompt
#      fi
#
# See 'CUSTOMISING.md' for help with customising this script.

__bash_powerline_prompt() {
    # Must come before anything else than could return an exit code
    local EXIT_STATUS=$?

    ######################################################################
    # USER CONFIGURABLE VARIABLES
    ######################################################################
    # Configuration

    # Symbols and colors
    local SOLID_ARROW_SYMBOL="\xee\x82\xb0" # Powerline symbol (U+e0b0)
    local THIN_ARROW_SYMBOL="\xee\x82\xb1"  # Powerline symbol (U+e0b1)

    ######################################################################

    ######################################################################
    # NON-CONFIGURABLE VARIABLES
    ######################################################################
    local COLOR_ESCAPDE_CODE='\033'
    local FG_COLOR_PREFIX='38;5;'
    local BG_COLOR_PREFIX='48;5;'
    local RESET_FG_COLORS='39'
    local RESET_BG_COLORS='49'
    local RESET_ATTRS='0'
    ######################################################################

    # Loads a given theme (reverts to the default theme on error)
    __load_theme() {
        if [[ -n "$BASH_POWERLINE_THEME" ]]; then
            local script_dir="$(__get_script_dir)"
            local theme_path="$script_dir/themes/$BASH_POWERLINE_THEME.theme"

            if [ -r "$theme_path" ]; then
                local theme="$BASH_POWERLINE_THEME"

                # Load the default theme and let custom themes override them
                source "$script_dir/themes/default.theme"
                __set_theme

                # Load the custom theme unless it is the default
                if [ "$theme" != "default" ]; then
                    source $theme_path
                    __set_theme
                fi
            else
                printf "Error: Failed to load theme '$BASH_POWERLINE_THEME'\n"
            fi
        fi
    }

    # Returns the directory that this script is actually in
    # Credits: http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
    __get_script_dir() {
        unset CDPATH
        local source="${BASH_SOURCE[0]}"

        while [ -L "$source" ]; do
            local dir="$(cd -P "$(dirname "$source")" && pwd)"
            source="$(readlink "$source")"
            [[ $source != /* ]] && source="$dir/$source"
        done

        printf "$(cd -P "$(dirname "$source")" && pwd)"
    }

    # Returns a string representing the current OS, e.g. 'Darwin' for Mac systems
    __get_os_name() {
        printf "$(uname -s)"
    }

    # Returns the name of the current user
    __get_username() {
        if [ $(__get_os_name) == "Darwin" ]; then
            printf $(id -un) # 'whoami' has been obsoleted on OSX
        else
            printf $(whoami)
        fi
    }

    __get_hostname() {
        if [ $(__get_os_name) == "Darwin" ]; then
            printf $(scutil --get ComputerName)
        else
            printf $(hostname -s)
        fi
    }

    # Returns the current working directory
    __get_cwd() {
        local cwd=$(pwd)

        if [ $USE_TILDE_FOR_HOME ]; then
            cwd=${cwd/$HOME/$HOME_ALIAS}
        fi

        printf $cwd
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

        printf "$1" | cut -d/ "-f1-$n"
    }

    # Gets the n last elements of a path
    __get_path_tails() {
        local n=$2

        printf "$1" | rev | cut -d/ -f1-"$n" | rev
    }

    # Return the number of columns available to the prompt
    __get_columns() {
        # Get the environment variable or if that fails, get it from terminfo
        if [ -n "$COLUMNS" ]; then
            printf "$COLUMNS"
        else
            tput cols
        fi
    }

    # Resets all ANSI attributes
    __reset_attributes() {
        printf "\[$COLOR_ESCAPDE_CODE[0m"
    }

    # Format a color as an ANSI escape sequence
    __format_color() {
        # Colors are wrapped in '\[' and '\]' to tell bash not to count them towards line length
        if [ $# -gt 1 ]; then
            printf "\[$COLOR_ESCAPDE_CODE[$FG_COLOR_PREFIX%s;$BG_COLOR_PREFIX%sm\]" $1 $2
        elif [ $# -gt 0 ]; then
            printf "\[$COLOR_ESCAPDE_CODE[$FG_COLOR_PREFIX%sm\]" $1
        fi

        printf ''
    }

    # Get the current git branch. Use .git-prompt.sh if it is available
    __get_current_git_branch() {
        local git_branch=''

        if [ -n "$(type __git_ps1)" ]; then
            git_branch="$(__git_ps1 '%s')"
        else
            git_branch=$(git symbolic-ref HEAD)

            if [ $? -ne 0 ]; then
                return ''
            fi

            git_branch=$(basename $git_branch)
        fi

        printf "$git_branch"
    }

    ######################################################################
    # PREDEFINED SECTIONS
    ######################################################################
    # Prints an empty section. Useful for when $BASH_POWERLINE_IGNORE_EMPTY_SECTIONS is 0
    # and you want a layout similar to the example layout of 'Turbo Boost'
    __empty_section() {
        printf ''
    }

    # Prints the exit status of the last command
    __exit_status() {
        local exit_status=$EXIT_STATUS

        if [[ $exit_status != 0 ]]; then
            fg=$BASH_POWERLINE_GIT_FG_DIRTY_COLOR
        fi

        printf "$exit_status "
    }

    # Prints the current username and host, and optionally the current python virtualenv
    __user_context() {
        local result="$(__get_username)$BASH_POWERLINE_USER_CXT_SEPARATOR_SYMBOL$(__get_hostname)"

        if [ -n "$VIRTUAL_ENV" ]; then
            result+=" ($VIRTUAL_ENV)"
        fi

        printf "$result "
    }

    # Prints the current directory
    __cwd_context() {
        printf "$(__get_cwd) "
    }

    # Prints the current git branch (if any), a branch symbol and whether
    # the current branch is clean or dirty (via 'git status')
    __git_context() {
        local git_state=""
        local git_branch="$(__format_color $1 $2)$BASH_POWERLINE_GIT_BRANCH_SYMBOL"
        local git_fg=$BASH_POWERLINE_GIT_FG_DIRTY_COLOR
        local git_symbol=$BASH_POWERLINE_GIT_DIRTY_SYMBOL

        if type git > /dev/null; then
            if 2>/dev/null 1>&2 git status --ignore-submodules; then
                if 2>/dev/null 1>&2 git status --ignore-submodules | grep 'nothing to commit'; then
                   git_fg=$BASH_POWERLINE_GIT_FG_CLEAN_COLOR
                   git_symbol=$BASH_POWERLINE_GIT_CLEAN_SYMBOL
                fi

                git_state="$(__format_color $git_fg $2)$git_symbol"
                git_branch="$(__format_color $1 $2)$BASH_POWERLINE_GIT_BRANCH_SYMBOL"

                if [ -n "$BASH_POWERLINE_GIT_BRANCH_COLOR" ]; then
                    git_branch+="$(__format_color $BASH_POWERLINE_GIT_BRANCH_COLOR $2)"
                fi

                local temp_branch="$(__get_current_git_branch)"

                if [ -n "$temp_branch" ]; then
                    git_branch+=" "
                fi

                git_branch+="$temp_branch $git_state"
            fi
        fi

        printf " $git_branch "
    }

    # Prints a section with a single command symbol
    __prompt_end() {
        printf "$BASH_POWERLINE_COMMAND_SYMBOL"
    }

    ######################################################################

    # Attempt to load the current theme
    __load_theme

    # Prints a single separator
    __print_separator() {
        if [ -n "$PREVIOUS_SYMBOL" ]; then
            # Handle the case where the solid powerline triangle symbol was used
            if [ "$PREVIOUS_SYMBOL" == "$SOLID_ARROW_SYMBOL" ]; then
                __ps1+=" $(printf "$(__format_color $PREVIOUS_BG_COLOR $bg)$PREVIOUS_SYMBOL")"
            else
                # Any other separator needs its own colors
                fg=${BASH_POWERLINE_SEPARATOR_FG_COLORS[$((i - 1))]}
                bg=${BASH_POWERLINE_SEPARATOR_BG_COLORS[$((i - 1))]}
                __ps1+="$(printf "$(__format_color $fg $bg)$PREVIOUS_SYMBOL")"
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
    for i in ${!BASH_POWERLINE_SECTIONS[@]}; do
        fg=${BASH_POWERLINE_FG_COLORS[$i]}
        bg=${BASH_POWERLINE_BG_COLORS[$i]}

        if [[ -n "$fg" || -n "$bg" ]]; then
            contents="$(__format_color $fg $bg)$(${BASH_POWERLINE_SECTIONS[$i]})"
        else
            contents="${BASH_POWERLINE_SECTIONS[$i]}"
        fi

        if [[ $BASH_POWERLINE_IGNORE_EMPTY_SECTIONS -eq 1 && -z "$contents" ]]; then
            continue
        fi

        __print_separator
        __ps1+=$contents

        # Save curent settings
        PREVIOUS_CONTENTS=$contents
        PREVIOUS_FG_COLOR=$fg
        PREVIOUS_BG_COLOR=$bg
        PREVIOUS_SYMBOL=${BASH_POWERLINE_SEPARATORS[$i]}
    done

    # Handle the last separator separately
    if [ -n "$PREVIOUS_SYMBOL" ]; then
        if [ "$PREVIOUS_SYMBOL" == "$SOLID_ARROW_SYMBOL" ]; then
            __ps1+=$(printf "$(__reset_attributes)$(__format_color $PREVIOUS_BG_COLOR)$PREVIOUS_SYMBOL")
        else
            # Any other separator needs its own colors
            fg=${BASH_POWERLINE_SEPARATOR_FG_COLORS[$i]}
            bg=${BASH_POWERLINE_SEPARATOR_BG_COLORS[$i]}
            __ps1+=$(printf "$(__reset_attributes)$(__format_color $fg)$PREVIOUS_SYMBOL")
        fi
    fi

    # Must be called afterwards to reset all colors and attributes
    __ps1+=$(__reset_attributes)

    __ps1+=$BASH_POWERLINE_PROMPT_END_SPACING
    export PS1=$__ps1
}
