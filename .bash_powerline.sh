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
    local IGNORE_EMPTY_SECTIONS=0 # If enabled, do not display sections that return an empty string

    # Symbols and colors
    local SOLID_ARROW_SYMBOL="\xee\x82\xb0" # Powerline symbol (U+e0b0)
    local THIN_ARROW_SYMBOL="\xee\x82\xb1"  # Powerline symbol (U+e0b1)

    if [[ -n "$BASH_POWERLINE_THEME" && "$BASH_POWERLINE_THEME" != "$__BASH_POWERLINE_CACHED_THEME" ]]; then
        local script_dir="$(__get_script_dir)"
        local theme_path="$script_dir/themes/$BASH_POWERLINE_THEME.theme"

        if [ -r "$theme_path" ]; then
            # Load the default theme and let custom themes override them
            source "$script_dir/themes/default.theme"
            __set_theme

            # Load the custom theme unless it is the default
            if [ "$BASH_POWERLINE_THEME" != "default" ]; then
                source $theme_path
                __set_theme
            fi

            # Cache the current theme
            __BASH_POWERLINE_CACHED_THEME=$BASH_POWERLINE_THEME
        else
            printf "Error: Failed to load theme '$BASH_POWERLINE_THEME'\n"
        fi
    fi

    ######################################################################

    ######################################################################
    # NON-CONFIGURABLE VARIABLES
    ######################################################################
    local FG_COLOR_PREFIX='38;5;'
    local BG_COLOR_PREFIX='48;5;'
    local RESET_FG_COLORS='39'
    local RESET_BG_COLORS='49'
    local RESET_ATTRS='0'
    ######################################################################

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

    # Resets all ANSI attributes
    __reset_attributes() {
        printf "\[\e[0m"
    }

    # Format a color as an ANSI escape sequence
    __format_color() {
        # Colors are wrapped in '\[' and '\]' to tell bash not to count them towards line length
        if [ $# -gt 1 ]; then
            printf "\[\e[$FG_COLOR_PREFIX%s;$BG_COLOR_PREFIX%sm\]" $1 $2
        elif [ $# -gt 0 ]; then
            printf "\[\e[$FG_COLOR_PREFIX%sm\]" $1
        fi

        printf ''
    }

    # Get the current git branch. Use .git-prompt.sh if it is available
    __get_current_git_branch() {
        local git_branch=''

        if [ -n "$(type __git_ps1)" ]; then
            git_branch=" $(__git_ps1 '%s') $git_state"
        else
            git_branch=$(git symbolic-ref HEAD)

            if [ $? -ne 0 ]; then
                return ''
            fi

            git_branch=$(basename $git_branch)
        fi

        printf $git_branch
    }

    ######################################################################
    # PREDEFINED SECTIONS
    ######################################################################
    # Prints an empty section. Useful for when $IGNORE_EMPTY_SECTIONS is 0
    # and you want a layout similar to the example layout of 'Turbo Boost'
    __empty_section() {
        printf ''
    }

    # Prints the exit status of the last command
    __exit_status() {
        local fg=$1
        local bg=$2
        local exit_status=$EXIT_STATUS

        if [[ $exit_status != 0 ]]; then
            fg=$BASH_POWERLINE_GIT_FG_DIRTY_COLOR
        fi

        printf "$(__format_color $fg $bg) $exit_status "
    }

    # Prints the current username and host, and optionally the current python virtualenv
    __user_context() {
        local result="$(__get_username)$BASH_POWERLINE_USER_CXT_SEPARATOR_SYMBOL$(__get_hostname)"

        if [ -n "$VIRTUAL_ENV" ]; then
            result+=" ($VIRTUAL_ENV)"
        fi

        printf "$(__format_color $1 $2) $result "
    }

    # Prints the current directory
    __cwd_context() {
        printf "$(__format_color $1 $2) $(__get_cwd) "
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

                local temp_branch=$(__get_current_git_branch)

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
        printf "$(__format_color $1 $2) $BASH_POWERLINE_COMMAND_SYMBOL "
    }
    ######################################################################

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
        contents=$(${BASH_POWERLINE_SECTIONS[$i]} $fg $bg)

        if [[ $IGNORE_EMPTY_SECTIONS -eq 1 && -z "$contents" ]]; then
            continue
        fi

        if [ -n "$PREVIOUS_SYMBOL" ]; then
            # Handle the case where the solid powerline triangle symbol was used
            if [ "$PREVIOUS_SYMBOL" == "$SOLID_ARROW_SYMBOL" ]; then
                __ps1+=$(printf "$(__format_color $PREVIOUS_BG_COLOR $bg)$PREVIOUS_SYMBOL")
            else
                __ps1+=$(printf "$(__format_color $BASH_POWERLINE_SEPARATOR_FG_COLOR $bg)$PREVIOUS_SYMBOL")
            fi
        fi

        __ps1+=$contents

        # Save curent settings
        PREVIOUS_CONTENTS=$contents
        PREVIOUS_FG_COLOR=$fg
        PREVIOUS_BG_COLOR=$bg
        PREVIOUS_SYMBOL=${BASH_POWERLINE_SEPARATORS[$i]}
    done

    # Handle the last separator
    if [ -n "$PREVIOUS_SYMBOL" ]; then
        __ps1+=$(printf "$(__reset_attributes)$(__format_color $PREVIOUS_BG_COLOR)$SOLID_ARROW_SYMBOL")
    fi

    # Must be called afterwards to reset all colors and attributes
    __ps1+=$(__reset_attributes)

    __ps1+=$BASH_POWERLINE_PROMPT_END_SPACING
    export PS1=$__ps1
}
