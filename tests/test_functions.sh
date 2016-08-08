__test_success() {
    printf "\033[32m✓\033[0m %s\n" "$1"
    return 0
}

__test_error() {
    printf "\033[31m%s\033[0m\n" "$1"
    return 1
}

__test_skip() {
    printf "\033[33m-\033[0m %s (\033[33mskipped\033[0m: %s)\n" "$1" "$2"
    return 0
}

__test_fail() {
    printf "\033[31m✗\033[0m %s:" "$1"
}

__test_assertion_failed() {
    printf '    \033[31mAssertion failed:\033[0m \"%b\" %s \"%b\"' "$1" "$2" "$3"
    return 1
}

__test_assert_equals() {
    if [ $# -ne 2 ]; then
        __test_error "Not enough arguments given for __test_assert_equals, got $# but expected 2"
    fi

    if [ "$1" != "$2" ]; then
        __test_assertion_failed "$1" "!=" "$2"
    fi
}
