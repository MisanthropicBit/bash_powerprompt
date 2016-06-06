__test_error() {
    printf "\033[31mError:\033[0m %s\n" "$1"
    return 1
}

__test_assertion_failed() {
    printf "\033[31mAssertion failed:\033[0m '%s'
                   %s
                  '%s'\n" "$1" "$2" "$3"
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
