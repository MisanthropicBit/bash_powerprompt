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

# Return the number of unstaged files
__git_unstaged() {
    git diff --numstat | wc -l
}

# Return the number of staged files
__git_staged() {
    git diff --cached --numstat | wc -l
}

# Return the number of commits for HEAD
__git_commits() {
    git rev-list --count HEAD
}

# Return the number of commits for all branches
__git_all_commits() {
    git rev-list --count --all HEAD
}

# Return the number of commits the current branch is ahead of its remote
__git_ahead() {
    git rev-list master..HEAD --count
}

# Return the number of commits the current branch is behind its remote
__git_behind() {
    git rev-list HEAD..master --count
}

#__git_conflicts() {
#}

# Return the number of stashed files
__git_stashed() {
    git stash list 2>/dev/null | wc -l
}

#__git_tracked() {
#    git ls-files | wc -l
#}

# Return the number of untracked files
__git_untracked() {
    git ls-files --others --exclude-standard | wc -l
}

#__git_uncommited() {
#}
