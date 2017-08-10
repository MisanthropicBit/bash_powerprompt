# Returns 0 if the branch is clean, 1 otherwise
__svn_clean() {
    svn status -q 2> /dev/null
    printf "%d" $?
}

# Returns 0 if the current directory is an svn repository, 1 otherwise
__svn_is_repo() {
    svn info 2> /dev/null
    printf "%d" $?
}
