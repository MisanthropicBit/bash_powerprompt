# Returns 0 if the branch is clean, 1 otherwise
__is_git_branch_clean() {
    2>/dev/null 1>&2 git status --ignore-submodules | grep 'nothing to commit'
}

# Returns 0 if the current directory is a git branch, 1 otherwise
__is_git_branch() {
    2>/dev/null 1>&2 git status --ignore-submodules
}

# Get the current git branch. Use .git-prompt.sh if it is available
__git_branch() {
    local git_branch=''

    if type -t __git_ps1 > /dev/null 2>&1; then
        git_branch="$(__git_ps1 '%s')"
    else
        # This requires git v1.7+
        git_branch=$(git rev-parse --abbrev-ref HEAD)
    fi

    printf "%s" "$git_branch"
}

# Return the current git directory (usually '.git')
__git_dir() {
    printf "$(git rev-parse --git-dir)"
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
    local branch=$(__git_branch)
    local remote=$(git rev-parse --abbrev-ref --symbolic-full-name $branch@{u} 2> /dev/null)

    if [ -n "$remote" ]; then
        git rev-list $remote..$branch --count
    else
        printf "%d" 0
    fi
}

# Return the number of commits the current branch is behind its remote
__git_behind() {
    local branch=$(__git_branch)
    local remote=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2> /dev/null)

    if [ -n "$remote" ]; then
        git rev-list $branch..$remote --count
    else
        printf "%d" 0
    fi
}

#__git_conflicts() {
#}

# Return the number of stashed files
__git_stashed() {
    git stash list 2>/dev/null | wc -l
}

# Return the number of tracked files
__git_tracked() {
    git ls-files | wc -l
}

# Return the number of untracked files
__git_untracked() {
    git ls-files --others --exclude-standard | wc -l
}

# Parse the output of git status and return the state of all tracked content
__git_states() {
    local git_status=$(git status --porcelain --branch)

    [ "$?" -ne 0 ] && exit 0

    local branch=''
    local staged=0
    local modified=0
    local conflicts=0
    local untracked=0

    # We iterate over the loop twice: First parsing 2-character statuses,
    # then single-character statuses
    while IFS='' read -r line || [ -n "$line" ]; do
        local status=${line:0:2}

        while [[ -n "$status" ]]; do
            case "$status" in
                \#\#) break ;;
                \?\?) ((untracked++)); break ;;
                U?)   ((conflicts++)); break ;;
                ?U)   ((conflicts++)); break ;;
                DD)   ((conflicts++)); break ;;
                AA)   ((conflicts++)); break ;;
                ?M)   ((modified++)) ;;
                ?D)   ((modified++)) ;;
                ?\ )  ;;
                U)    ((conflicts++));;
                \ )   ;;
                *)    ((staged++));;
            esac

            # Slice off the second status character
            status=${status:0:(${#status}-1)}
        done
    done <<< "$git_status"

    local clean=0

    if [[ $staged -eq 0 && modified -eq 0 && conflicts -eq 0 ]]; then
        clean=1
    fi

    printf "$clean $staged $modified $conflicts $untracked"
}
