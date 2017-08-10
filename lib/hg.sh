__hg_clean() {
    hg summary | grep -q 'commit: (clean)'
    printf "%d" $?
}
