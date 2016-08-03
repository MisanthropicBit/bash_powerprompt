#!/usr/bin/env bash -i

__run_tests() {
    source test_functions.sh

    # NOTE: We run in interactive mode to properly expand variables such as PS1
    if [[ $- != *i* ]]; then
        __test_error "Error: Test runner is not running in interactive mode"
        exit 1
    fi

    local test_files=(test_simplistic_theme.sh test_default_theme.sh)
    #local test_files=($(find . -iname "*test*.sh" -o -iname "*test*.bash" | grep -v -e "$0" -e "test_functions.sh"))

    if [ -z "$test_files" ]; then
        __test_error "No tests collected" && exit 0
    fi

    local failed=0
    [ "$TRAVIS" == "true" ] && local on_travis=1 || local on_travis=0

    # Save the current theme if the tests are running locally
    if [ !$on_travis ]; then
        local current_theme="$BASH_POWERLINE_THEME"
    fi

    for f in ${test_files[@]}; do
        source "$f"
        local out=$(__test)
        local retval=$?

        if [[ $retval -ne 0 || -n "$out" ]]; then
            __test_fail "$f ($retval): $out"
            #printf "%s\n" "$out"
            failed=$((failed + 1))
        else
            __test_success "$f"
        fi
    done

    printf "\n${#test_files[@]} test(s) collected, "

    if [ "$failed" -gt 0 ]; then
        printf "%s failed (%.2f%%)\n" "$failed" "$(bc -l <<< "scale=2; $failed/${#test_files[@]}*100.0")"
        exit 1
    fi

    printf "0 failed\nAll tests passed\n"

    # Restore the current theme if the tests are running locally
    if [ !$on_travis ]; then
        export BASH_POWERLINE_THEME="$current_theme"
    fi
    
    exit 0
}

__run_tests
