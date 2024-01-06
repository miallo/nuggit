#!/usr/bin/env bash

success() {
    # use \r to overwrite the line saying "running" => add spaces to the end to cover the longer line
    printf "\r✅ \e[32m%s\e[0m                 \n" "$1"
}

failure() {
    printf "❌ \e[3;1;31m%s\e[0m\e[1;31m failed\e[0m\n" "$1"
    exit 1
}

get_sh_codeblock() {
    # shellcheck disable=2016
    sed -n '/^```sh$/,/^```$/{n;p;}' "$1"
}

# skipping/commenting out a testcase
xit() {
    testname="$1"
    printf "⏭️  \e[33m%s\e[0m skipped\n" "$testname"
}

# running a testcase
it(){
    testname="$1"; shift
    code="$1"
    if [ -z "$code" ]; then # read from stdin
        # this allows also for 'it "name" <<EOF' syntax
        code="$(cat -)"
    fi
    printf "running %s" "$testname"
    if eval "$code" >/dev/null; then
        success "$testname"
    else
        failure "$testname"
    fi
}

# Assertion
expect() {
    local contains not
    command="$1"; shift
    if [ "$1" = not ]; then
        not="Not "
        shift
    fi
    to="$1"; shift
    contain="$1"; shift
    string="$1"
    if [ "$to" != to ] || [ "$contain" != contain ] || [ $# -ne 1 ]; then
        echo >&2
        printf "ERROR: usage of \`expect\`:\n    expect \"echo hi\" to contain \"hi\"\nor\n    expect \"echo ho\" not to contain hi\n" >&2
        echo "Command: $command" >&2
        echo "not?: $not" >&2
        echo "To: $to" >&2
        echo "contain: $contain" >&2
        echo "string: $string" >&2
        return 1
    fi
    output="$(eval "$command")"

    [[ $output == *"$string"* ]] || contains=1
    if { [ -n "$not" ] && [ -z "$contains" ]; } || { [ -z "$not" ] && [ -n "$contains" ]; }; then
        echo >&2
        printf "> %s\n\n    %sExpected: %s\n    Received: %s\n" "$command" "$not" "$string" "$output" >&2
        return 1
    fi
}


