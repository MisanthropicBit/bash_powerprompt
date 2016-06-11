#!/usr/bin/env bash -i

__run_tests() {
    source test_functions.sh

    local test_files=($(find . -name "*test*.sh" -o -name "*test*.bash" | grep -v -e "$0" -e "test_functions.sh"))

    if [ -z "$test_files" ]; then
        __test_error "No tests collected" && exit 1
    fi

    local failed=0

    #trap 'printf "line number is %s" $LINENO' ERR

    for f in ${test_files[@]}; do
        source "$f"
        local out=$(__test)

        if [ -n "$out" ]; then
            printf "\033[31m✗ $f:\033[0m\n$out\n"
            failed=$((failed + 1))
        else
            printf "\033[32m✓ $f\033[0m\n"
        fi
    done

    printf "\n${#test_files[@]} test(s) collected, "

    if [ "$failed" -gt 0 ]; then
        printf "%s failed (%.2f%%)\n" "$failed" "$(bc -l <<< "scale=2; $failed/${#test_files[@]}*100.0")"
        exit 1
    fi

    printf "0 failed\n"
    exit 0
}

__run_tests
