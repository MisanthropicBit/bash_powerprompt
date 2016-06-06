#!/usr/bin/env bash -i

__test() {
    #if [[ $- != *i* ]]; then
    #    __test_error "Test '$0' is not running in interactive mode" && exit 1
    #fi

    local expected_ps1="\[\033[38;5;113;48;5;m\]albo \[\033[38;5;15;48;5;m\]at \[\033[38;5;74;48;5;m\]tests \[\033[38;5;15;48;5;m\]on \[\033[38;5;99;48;5;m\]themes \[\033[38;5;15;48;5;m\]→\[\033[0m\] " 

    #diff <(printf "$PS1") <(printf "$expected_ps1")
    #cmp -b <(printf "$PS1") <(printf "$expected_ps1")

    __test_assert_equals "$(printf "%s" "$PS1")" "$(printf "%b" "$expected_ps1")"
}
