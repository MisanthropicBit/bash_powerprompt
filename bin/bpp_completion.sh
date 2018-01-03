# Returns the directory that this script is located in, no matter where the
# function is called from
#
# Credits:
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
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

# bpp completion function
__bpp_theme_completion() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    local install_dir

    if [ -n "$BASH_POWERPROMPT_DIRECTORY" ]; then
        install_dir="$BASH_POWERPROMPT_DIRECTORY"
    else
        install_dir="$(__get_script_dir)"
    fi

    local theme_files=($install_dir/themes/*.theme)
    local themes=""

    for i in ${!theme_files[@]}; do
        local theme_file=${theme_files[i]}

        # Extract base name
        theme_file=${theme_file##*/}

        # Extract theme name without its extension
        theme_file=${theme_file%.*}

        themes+="$theme_file "
    done

    COMPREPLY=($(compgen -W "${themes[@]}" -- $cur))
}

# Tell bash to use the completion function with the 'bpp' command
complete -F __bpp_theme_completion bpp
