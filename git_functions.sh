# Returns 0 if the branch is clean, 1 otherwise
__is_git_branch_clean() {
    2>/dev/null 1>&2 git status --ignore-submodules | grep 'nothing to commit'
}

# Returns 0 if the current directory is a git branch, 1 otherwise
__is_git_branch() {
    2>/dev/null 1>&2 git status --ignore-submodules
}

# Get the current git branch. Use .git-prompt.sh if it is available
__get_current_git_branch() {
    local git_branch=''

    if type __git_ps1 > /dev/null; then
        git_branch="$(__git_ps1 '%s')"
    else
        # This requires git v1.7+
        git_branch=$(git rev-parse --abbrev-ref HEAD)
    fi

    printf "%s" "$git_branch"
}

#__git_ahead() {
#}

#__git_behind() {
#}

#__git_staged() {
#}

#__git_conflicts() {
#}

#__git_stashed() {
#}

#__git_tracked() {
#    git ls-files | wc -l
#}

#__git_untracked() {
#    git status --untracked-files --porcelain | wc -l
#}

#__git_uncommited() {
#}

#__git_is_local() {
#}
