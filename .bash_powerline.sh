#!/usr/bin/env bash

# Custom bash prompt theme for 256-color terminals
# Author: Alexander Bock
#
# Features:
#   - Written in pure bash with no dependencies
#   - Multiple predefined functions for displaying current username, hostname,
#     git branche, python virtualenv, directory and exit code of the last command
#   - Uses fancy Unicode and Powerline symbols
#   - Easily customisable and extensible
#
# Requirements:
#   - A terminal/shell capable of displaying utf-8
#   - A patched powerline font set up with your terminal
#
# Installation:
#   1. (OPTIONAL) Run install.sh to set up a symlink to your home directory
#   2. Add 'source <path_to_this_script>' in ~/.bashrc or ~/.profile etc.
#   3. Call 'export PROMPT_COMMAND=__bash_powerline_prompt' after sourcing
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
    local COMMAND_SYMBOL='$'                # Command symbol at the end of the prompt
    local SOLID_ARROW_SYMBOL="\xee\x82\xb0" # Powerline symbol (U+e0b0)
    local THIN_ARROW_SYMBOL="\xee\x82\xb1"  # Powerline symbol (U+e0b1)
    local USER_CXT_SEPARATOR_SYMBOL='@'     # Separator between user- and hostnames
    local PROMPT_END_SPACING=' '            # Spacing at the end of the prompt
    local GIT_BRANCH_SYMBOL="\xee\x82\xa0"  # Powerline symbol that looks like a git branch
    local GIT_CLEAN_SYMBOL="\xe2\x9c\x93"   # A checkmark (U+2713)
    local GIT_DIRTY_SYMBOL="\xe2\x9c\x97"   # A ballot x (U+2717)
    local SEPARATOR_FG_COLOR=15             # Only used when the separator is not SOLID_ARROW_SYMBOL
    local GIT_BRANCH_COLOR=                 # The color of the current git branch (if any)
    local GIT_FG_CLEAN_COLOR=76             # The color for a git branch with uncommitted files
    local GIT_FG_DIRTY_COLOR=160            # The color for a git branch with a clean working directory

    # Layout variables for sections
    #
    # Note: There is an additional symbol in the array SEPARATORS for ending the
    # prompt
    local FG_COLORS=(15 15 15 15 15)
    local BG_COLORS=(65 60 167 110 221)
    local SECTIONS=(__exit_status __user_context __cwd_context __git_context __prompt_end)
    local SEPARATORS=($SOLID_ARROW_SYMBOL $SOLID_ARROW_SYMBOL $SOLID_ARROW_SYMBOL $SOLID_ARROW_SYMBOL $SOLID_ARROW_SYMBOL)
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

    __get_python_virtualenv() {
        printf "$VIRTUAL_ENV"
    }

    # Resets all ANSI attributes
    __reset_attributes() {
        printf "\[\e[0m"
    }

    # Format a color as an ANSI escape sequence
    __format_color() {
        if [[ -z $1 && -z $2 ]]; then
            printf ''
        fi

        local fg_full='39'
        local bg_full='49'

        if [[ -n $1 ]]; then
            fg_full=${FG_COLOR_PREFIX}$1
        fi

        if [[ -n $2 ]]; then
            bg_full=${BG_COLOR_PREFIX}$2
        fi

        # Colors are wrapped in '\[' and '\]' to tell bash not to count them towards line length
        printf "\[\e[%s;%sm\]" $fg_full $bg_full
    }

    # Get the current git branch. Use .git-prompt.sh if it is available
    __get_current_git_branch() {
        local git_branch=''

        if [ -n "$(type __git_ps1)" ]; then
            git_branch=" $(__git_ps1 '%s') $git_state"
        else
            git_branch=" $(git symbolic-ref HEAD)"

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
            fg=$GIT_FG_DIRTY_COLOR
        fi

        printf "$(__format_color $fg $bg) $exit_status "
    }

    # Prints the current username and host, and optionally the current python virtualenv
    __user_context() {
        local result="$(__get_username)$USER_CXT_SEPARATOR_SYMBOL$(__get_hostname)"
        local virtualenv=$(__get_python_virtualenv)

        if [ -n "$virtualenv" ]; then
            result+=" ($virtualenv)"
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
        local git_branch="$(__format_color $1 $2)$GIT_BRANCH_SYMBOL"
        local git_fg=$GIT_FG_DIRTY_COLOR
        local git_symbol=$GIT_DIRTY_SYMBOL

        if type git > /dev/null; then
            if 2>/dev/null 1>&2 git status --ignore-submodules; then
                if git status --ignore-submodules | grep 'nothing to commit' > /dev/null; then
                   git_fg=$GIT_FG_CLEAN_COLOR
                   git_symbol=$GIT_CLEAN_SYMBOL
                fi

                git_state="$(__format_color $git_fg $2)$git_symbol"
                git_branch="$(__format_color $1 $2)$GIT_BRANCH_SYMBOL"

                if [ -n "$GIT_BRANCH_COLOR" ]; then
                    git_branch+="$(__format_color $GIT_BRANCH_COLOR $2)"
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
        printf "$(__format_color $1 $2) $COMMAND_SYMBOL "
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
    for i in ${!SECTIONS[@]}; do
        fg=${FG_COLORS[$i]}
        bg=${BG_COLORS[$i]}
        contents=$(${SECTIONS[$i]} $fg $bg)

        if [[ $IGNORE_EMPTY_SECTIONS -eq 1 && -z "$contents" ]]; then
            continue
        fi

        if [ -n "$PREVIOUS_SYMBOL" ]; then
            # Handle the case where the solid powerline triangle symbol was used
            if [ "$PREVIOUS_SYMBOL" == "$SOLID_ARROW_SYMBOL" ]; then
                __ps1+=$(printf "$(__format_color $PREVIOUS_BG_COLOR $bg)$PREVIOUS_SYMBOL")
            else
                __ps1+=$(printf "$(__format_color $SEPARATOR_FG_COLOR $bg)$PREVIOUS_SYMBOL")
            fi
        fi

        __ps1+=$contents

        # Save curent settings
        PREVIOUS_CONTENTS=$contents
        PREVIOUS_FG_COLOR=$fg
        PREVIOUS_BG_COLOR=$bg
        PREVIOUS_SYMBOL=${SEPARATORS[$i]}
    done

    # Handle the last separator
    if [ -n "$PREVIOUS_SYMBOL" ]; then
        __ps1+=$(printf "$(__format_color $PREVIOUS_BG_COLOR "")$SOLID_ARROW_SYMBOL")
    fi

    # Must be called afterwards to reset all colors and attributes
    __ps1+=$(__reset_attributes)

    __ps1+=$PROMPT_END_SPACING
    export PS1=$__ps1
}
