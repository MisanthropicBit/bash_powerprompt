#!/usr/bin/env bash -i

__run_tests() {
    source test_functions.sh

    local test_files=$(find . -name "*test*.sh" | grep -v -e "$0" -e "test_functions")

    if [ -z "$test_files" ]; then
        __test_error "No tests collected" && exit 1
    fi

    printf "\033[32m~>\033[0m Collected %d test(s)...\n" "${#test_files[@]}"

    local passed=0
    local failed=0

    while read -r f; do
        source "$f"
        __test

        if [ $? -eq 0 ]; then
            passed=$((passed + 1))
        else
            failed=$((failed + 1))
        fi
    done <<< "$test_files"

    if [ "$failed" -gt 0 ]; then
        printf "\n\033[32m~>\033[0m %d test(s) \033[32mpassed\033[0m, %d test(s) \033[31mfailed\033[0m (%.2f %%)\n" "$passed" "$failed" "$(bc -l <<< "scale=2; $passed/$failed*100.0")"
    else
        printf "\033[32m~>\033[0m %b\n" "\033[32mAll tests passed\033[0m"
    fi
}

__run_tests
