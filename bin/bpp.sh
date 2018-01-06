bpp() {
    for i in "$@"; do
        case $i in
            -h|--help)
                printf "%s\n" "Usage: bpp"
                printf "%s\n" "       bpp [theme_name]"
                printf "%s\n" "       bpp [-l | --list] [-h, --help]"
                return
            ;;

            -l|--list)
                if [ -n "$BASH_POWERPROMPT_DIRECTORY" ]; then
                    for theme in $BASH_POWERPROMPT_DIRECTORY/themes/*.theme; do
                        local bname=${theme##*/}
                        printf "%s\n" ${bname%.*}
                    done
                else
                    printf "\033[31;1mError:\033[0m \033[38;1m%s\033[0m%s\n" "BASH_POWERPROMPT_DIRECTORY" " not set to install directory, cannot list themes"
                fi

                return
            ;;

            *)
            ;;
        esac
    done

    if [ -n "$1" ]; then
        if [ "$1" = "random"] && [ -n "$BASH_POWERPROMPT_RANDOM_THEMES" ]; then
            printf "Random theme selected from: ${BASH_POWERPROMPT_RANDOM_THEMES[@]}\n"
        fi

        export BASH_POWERPROMPT_THEME="$1"
    else
        printf "Current theme is \033[38;1m%s\033[0m\n" "$BASH_POWERPROMPT_THEME"
    fi
}
