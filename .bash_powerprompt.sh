#!/usr/bin/env bash

# A bash script that gives you a visually pleasing, informative and customisable
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
#      if [ -e ~/.bash_powerprompt.sh ]; then
#          source ~/.bash_powerprompt.sh
#          export BASH_POWERPROMPT_THEME=<your default theme> # Optional
#          export PROMPT_COMMAND=__bash_powerprompt
#      fi
#
#   3. (optional) It is recommended, but not required, to also set
#      BASH_POWERPROMPT_DIRECTORY to the chosen install directory, in order to
#      avoid having to look up the install directory on every call to
#      PROMPT_COMMAND
#
# For more information about customisation and creating your own themes, see
# 'CUSTOMISING.md'.

# Print an error message
__error() {
    printf "$COLOR_ESCAPE_CODE[31m%s$COLOR_ESCAPE_CODE[0m: %s\n" "Error" "$1"
}

# Loads a given theme after loading the default theme first (reverts to the default theme on error)
__load_theme_internal() {
    if [ -n "$BASH_POWERPROMPT_THEME" ]; then
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
            __error "Failed to load theme '$BASH_POWERPROMPT_THEME'"
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
            __error "Failed to load theme '$BASH_POWERPROMPT_THEME'"
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

        if ! source "$script_dir/lib/$1.sh"; then
            __error "Error: Failed to load utility '$1'"
        fi
    else
        __error "Error: Empty argument to __load_utility"
    fi
}

__bash_powerprompt() {
    # Must come before anything else than could return an exit code
    local BASH_POWERPROMPT_EXIT_STATUS=$?

    ######################################################################
    # COLOR VARIABLES
    ######################################################################
    local COLOR_ESCAPE_CODE='\033'
    local FG_COLOR_PREFIX_16=''
    local BG_COLOR_PREFIX_16=''
    local FG_COLOR_PREFIX_256='38;5'
    local BG_COLOR_PREFIX_256='48;5'
    local FG_COLOR_PREFIX_TRUE_COLOR='38;2'
    local BG_COLOR_PREFIX_TRUE_COLOR='48;2'
    local RESET_FG_CODE="39"
    local RESET_BG_CODE="49"
    local RESET_FG_COLOR="\[$COLOR_ESCAPE_CODE[${RESET_FG_CODE}m\]"
    local RESET_BG_COLOR="\[$COLOR_ESCAPE_CODE[${RESET_BG_CODE}m\]"
    local RESET_ATTRIBUTES="\[$COLOR_ESCAPE_CODE[0m\]" # Resets all ANSI attributes
    local BARE_COLOR_FORMAT="\[${COLOR_ESCAPE_CODE}[%s;%sm\]"
    local BASH_POWERPROMPT_COLOR_FORMAT_16="\[$COLOR_ESCAPE_CODE[%s;%sm\]"
    local BASH_POWERPROMPT_COLOR_FORMAT_256="\[$COLOR_ESCAPE_CODE[${FG_COLOR_PREFIX_256};%s;${BG_COLOR_PREFIX_256};%sm\]"
    local BASH_POWERPROMPT_COLOR_FORMAT_TRUECOLOR="\[$COLOR_ESCAPE_CODE[${FG_COLOR_PREFIX_TRUE_COLOR};%s;${BG_COLOR_PREFIX_TRUE_COLOR};%sm\]"
    ######################################################################

    # Prints a single separator
    __print_separator() {
        local prev_symbol="$2"

        # Handle the case where the solid powerline triangle symbol was used
        if [ "$prev_symbol" == "$BASH_POWERPROMPT_SOLID_ARROW_SYMBOL" ]; then
            local prev_bg_color="$3"
            local bg_color="$4"
            [ -n "$prev_bg_color" ] && prev_bg_color="${BASH_POWERPROMPT_FG_COLOR_PREFIX};$prev_bg_color" || prev_bg_color="$RESET_FG_CODE"
            [ -n "$bg_color" ] && bg_color="${BASH_POWERPROMPT_BG_COLOR_PREFIX};$bg_color" || bg_color="$RESET_BG_CODE"

            __ps1+="$(printf "${BARE_COLOR_FORMAT}$prev_symbol" "$prev_bg_color" "$bg_color")"
        else
            local i="$1"

            # Any other separator has its own colors
            local sfg=${BASH_POWERPROMPT_SEPARATOR_FG_COLORS[$((i - 1))]}
            local sbg=${BASH_POWERPROMPT_SEPARATOR_BG_COLORS[$((i - 1))]}

            [ -n "$sfg" ] && sfg="${BASH_POWERPROMPT_FG_COLOR_PREFIX};$sfg" || sfg="$RESET_FG_CODE"
            [ -n "$sbg" ] && sbg="${BASH_POWERPROMPT_BG_COLOR_PREFIX};$sbg" || sbg="$RESET_BG_CODE"

            if [ -n "$sfg" ] || [ -n "$sbg" ]; then
                __ps1+="$(printf "${BARE_COLOR_FORMAT}$prev_symbol" "$sfg" "$sbg")"
            else
                __ps1+="$prev_symbol"
            fi
        fi
    }

    ######################################################################

    # Attempt to load the current theme
    __load_theme_internal

    # Exit if the theme only sets PS1
    if [ "$BASH_POWERPROMPT_ONLY_PS1" -eq 1 ]; then
        return 0
    fi

    # Set color code prefixes
    case "$BASH_POWERPROMPT_COLOR_FORMAT" in
        "$BASH_POWERPROMPT_COLOR_FORMAT_16")
            BASH_POWERPROMPT_FG_COLOR_PREFIX="$FG_COLOR_PREFIX_16"
            BASH_POWERPROMPT_BG_COLOR_PREFIX="$BG_COLOR_PREFIX_16"
            ;;
        "$BASH_POWERPROMPT_COLOR_FORMAT_256")
            BASH_POWERPROMPT_FG_COLOR_PREFIX="$FG_COLOR_PREFIX_256"
            BASH_POWERPROMPT_BG_COLOR_PREFIX="$BG_COLOR_PREFIX_256"
            ;;
        "$BASH_POWERPROMPT_COLOR_FORMAT_TRUECOLOR")
            BASH_POWERPROMPT_FG_COLOR_PREFIX="$FG_COLOR_PREFIX_TRUE_COLOR"
            BASH_POWERPROMPT_BG_COLOR_PREFIX="$BG_COLOR_PREFIX_TRUE_COLOR"
            ;;
        *)
            __error "Unknown color format '$BASH_POWERPROMPT_COLOR_FORMAT'"
            ;;
    esac

    local __ps1=''
    local fg=''
    local bg=''
    local contents=''
    local PREVIOUS_SYMBOL=''
    local PREVIOUS_FG_COLOR=''
    local PREVIOUS_BG_COLOR=''

    # Assemble the prompt
    for i in ${!BASH_POWERPROMPT_SECTIONS[@]}; do
        contents="${BASH_POWERPROMPT_SECTIONS[$i]}"

        if [ "$BASH_POWERPROMPT_IGNORE_EMPTY_SECTIONS" -eq 1 ] && [ -z "$contents" ]; then
            continue
        fi

        contents="${BASH_POWERPROMPT_LEFT_PADDING[$i]}$contents${BASH_POWERPROMPT_RIGHT_PADDING[$i]}"

        fg=${BASH_POWERPROMPT_FG_COLORS[$i]}
        bg=${BASH_POWERPROMPT_BG_COLORS[$i]}

        if [ -n "$fg" ] || [ -n "$bg" ]; then
            local ffg fbg
            [ -n "$fg" ] && ffg="${BASH_POWERPROMPT_FG_COLOR_PREFIX};$fg" || ffg="$RESET_FG_CODE"
            [ -n "$bg" ] && fbg="${BASH_POWERPROMPT_BG_COLOR_PREFIX};$bg" || fbg="$RESET_BG_CODE"

            contents="\[${COLOR_ESCAPE_CODE}[${ffg};${fbg}m\]$contents"
        fi

        [ -n "$PREVIOUS_SYMBOL" ] && __print_separator "$i" "$PREVIOUS_SYMBOL" "$PREVIOUS_BG_COLOR" "$bg"
        __ps1+="$contents"

        # Save current settings for next iteration
        PREVIOUS_CONTENTS=$contents
        PREVIOUS_FG_COLOR=$fg
        PREVIOUS_BG_COLOR=$bg
        PREVIOUS_SYMBOL=${BASH_POWERPROMPT_SEPARATORS[$i]}
    done

    # Handle the last separator separately
    __ps1+=$(printf "%s" "$RESET_BG_COLOR")
    __print_separator "$i" "$PREVIOUS_SYMBOL" "$PREVIOUS_BG_COLOR" ""

    # Must be called as the last element of the prompt to reset all colors and attributes
    __ps1+=$(printf "%s" "$RESET_ATTRIBUTES")

    __ps1+="$BASH_POWERPROMPT_END_SPACING"

    export PS1="$__ps1"
}
