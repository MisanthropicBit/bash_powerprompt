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
