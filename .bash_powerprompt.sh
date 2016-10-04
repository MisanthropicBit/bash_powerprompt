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

    # Loads a given theme after loading the default theme first (reverts to the default theme on error)
    __load_theme_internal() {
        if [[ -n "$BASH_POWERPROMPT_THEME" ]]; then
            local script_dir="$(__get_script_dir)"
            local theme_path="$script_dir/themes/$BASH_POWERPROMPT_THEME.theme"

            if [ -r "$theme_path" ]; then
                local theme="$BASH_POWERPROMPT_THEME"

                # Load the default theme and let custom themes override them
                source "$script_dir/themes/default.theme"
                __bpp_set_theme

                # Load the custom theme unless it is the default
                if [ "$theme" != "default" ]; then
                    source $theme_path
                    __bpp_set_theme
                fi
            else
                printf "%s\n" "Error: Failed to load theme '$BASH_POWERPROMPT_THEME'"
            fi
        fi
    }

    # Load a theme without loading the default theme first. To be used in one theme to load another
    __load_theme() {
        if [ -n "$1" ]; then
            local script_dir="$(__get_script_dir)"
            local theme_path="$script_dir/themes/$1.theme"

            if [ -r "$theme_path" ]; then
                source $theme_path
                __bpp_set_theme
            else
                printf "%s\n" "Error: Failed to load theme '$BASH_POWERPROMPT_THEME'"
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

    # Load a set of utility functions
    __load_utility() {
        if [ -n "$1" ]; then
            local script_dir=$(__get_script_dir)

            source "$script_dir/lib/$1.sh"
        else
            printf "%s" "Error: Failed to load utility '$1'\n"
        fi
    }

    ######################################################################

    # Attempt to load the current theme
    __load_theme_internal

    # Exit if the theme only sets PS1
    if [ "$BASH_POWERPROMPT_ONLY_PS1" -eq 1 ]; then
        return 0
    fi

    # Prints a single separator
    __print_separator() {
        local prev_symbol="$2"

        if [ -n "$prev_symbol" ]; then
            # Handle the case where the solid powerline triangle symbol was used
            if [ "$prev_symbol" == "$BASH_POWERPROMPT_SOLID_ARROW_SYMBOL" ]; then
                local prev_bg_color="$3"
                local bg_color="$4"

                __ps1+="$(printf "${BASH_POWERPROMPT_COLOR_FORMAT}$prev_symbol" "$prev_bg_color" "$bg_color")"
            else
                local i="$1"

                # Any other separator has its own colors
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
            contents="$(printf "${BASH_POWERPROMPT_COLOR_FORMAT}%s" "$fg" "$bg" "$contents")"
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
    __ps1+=$(printf "%s" "$RESET_BG_COLORS")
    __print_separator "$i" "$PREVIOUS_SYMBOL" "$PREVIOUS_BG_COLOR" ""

    # Must be called as the last element of the prompt to reset all colors and attributes
    __ps1+=$(printf "%s" "$RESET_ATTRIBUTES")

    __ps1+="$BASH_POWERPROMPT_PROMPT_END_SPACING"
    export PS1="$__ps1"
}
