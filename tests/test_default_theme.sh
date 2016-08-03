#!/usr/bin/env bash

__test() {
    export BASH_POWERLINE_THEME="default"

    local expected_ps1=$(printf "\[\033[38;5;113;48;5;m\]\\\\u \[\033[38;5;15;48;5;m\]at \[\033[38;5;74;48;5;m\]\W \[\033[38;5;15;48;5;m\]on \[\033[38;5;99;48;5;m\]themes \[\033[38;5;15;48;5;m\]→\[\033[0m\] ")

    __test_assert_equals "$PS1" "$expected_ps1"
}
