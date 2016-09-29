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

# Return the number of columns available to the prompt
__get_columns() {
    # Get the environment variable or if that fails, get it from terminfo
    if [ -n "$COLUMNS" ]; then
        printf "%s" "$COLUMNS"
    else
        tput cols
    fi
}
