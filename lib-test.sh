#!/usr/bin/env bash

success() {
    # use \r to overwrite the line saying "running" => add spaces to the end to cover the longer line
    printf "\r✅ \e[32m%s\e[0m                 \n" "$1"
}

failure() {
    printf "❌ \e[3;1;31m%s\e[0m\e[1;31m failed\e[0m\n" "$1" >&2
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
    eval "set -eE
trap 'failure $(printf "%q" "$testname")' ERR EXIT
$code
trap - EXIT # Remove the trap handler, so that it does not fire at the end of the script
" >/dev/null
    success "$testname"
}

# Assertion
expect() {
    local not result error show_error
    command="$1"; shift
    if [ "$1" = not ]; then
        not="not "
        shift
    fi
    to="$1"; shift # For readability only
    if [ "$to" != to ]; then
        error="ERROR: usage of \`expect\` requires 'to', e.g.:
    expect \"echo hi\" ${not}to <action> [<argument of action>]"
        show_error=1
    else
        action="$1"; shift
        case "$action" in
            contain)
                if [ $# -ne 1 ]; then
                    error="ERROR: usage of \`expect ${not}to contain <string>\`. E.g.:
        expect \"echo hi\" ${not}to contain 'hi'
but got
        expect '$command' ${not}to contain $*"
                    show_error=1
                else
                    string="$1"
                    output="$(eval "$command")"

                    [[ $output == *"$string"* ]] || result=1
                    error="> $command
        ${not}Expected: $string
        Received: $output"
                fi
                ;;
            *)
                error="ERROR: unknown action '$action' in \`expect ${not}to $action ...\`"
                show_error=1
                ;;
        esac
    fi
    if [ -n "$show_error" ] || { [ -n "$not" ] && [ -z "$result" ]; } || { [ -z "$not" ] && [ -n "$result" ]; }; then
        echo >&2
        echo "$error" >&2
        return 1
    fi
}


