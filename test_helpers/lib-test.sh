#!/usr/bin/env bash

success() {
    # use \r to overwrite the line saying "running" => add spaces to the end to cover the longer line
    printf "\r✅ \e[32m%s\e[0m                 \n" "$1"
}

failure() {
    printf "\n❌ \e[3;1;31m%s\e[0m\e[1;31m failed\e[0m" "$1" >&2
    trap - ERR EXIT # Remove the trap handler, so that it does not call itself
    exit 1
}

get_sh_codeblock() { # FIXME: function name is a lie, as it only returns the first line
    # shellcheck disable=2016
    sed -n '/^```sh$/{n;p;}' "$1"
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
    if [ "$test_verbose" -gt 0 ]; then
        printf "\n"
    fi
    eval "set -eE
trap 'failure $(printf "%q" "$testname")' ERR EXIT
$code
trap - EXIT # Remove the trap handler, so that it does not fire at the end of the script
"
    success "$testname"
}

# Assertion
expect() {
    local invert_result result error
    expect_err() {
        echo >&2
        echo "$1" >&2
        exit 1
    }
    if [ "$test_verbose" -ge 1 ]; then
        printf "\e[34mexpect %s\e[0m " "$(pretty_escape "$@")"
    fi
    command="$1"; shift
    if [ "$1" = not ]; then
        invert_result=true
        shift
    fi
    to="$1"; shift # For readability only
    if [ "$to" != to ]; then
        expect_err "ERROR: usage of \`expect\` requires 'to', e.g.:
    expect \"echo hi\" ${invert_result+not }to <action> [<argument of action>]"
    else
        action="$1"; shift
        case "$action" in
            contain)
                if [ $# -ne 1 ]; then
                    expect_err "\
usage:  expect <command> ${invert_result+not }to contain <string>
E.g.:
        expect \"echo hi\" ${invert_result+not }to contain '${invert_result+not }hi'
but got:
        expect $(pretty_escape "$command" ${invert_result+not }to contain "$@")"
                fi
                string="$1"
                output="$(eval "$command")"

                [[ $output =~ "$string" ]] || result=1
                error="> $command
    ${invert_result+Not }Expected: $string
    Received: $output"
                ;;
            succeed)
                output=$(eval "$command") || result=1
                error="> $command should ${invert_result+not }succeed
    Output: $output"
                ;;
            *)
                expect_err "ERROR: unknown action '$action' in \`expect ${invert_result+not }to $(pretty_escape action) ...\`"
                ;;
        esac
    fi
    if [ "$test_verbose" -ge 2 ]; then printf "\n%s\n" "$output"; fi
    if { [ "$invert_result" = true ] && [ -z "$result" ]; } || { [ "$invert_result" != true ] && [ -n "$result" ]; }; then
        if [ "$test_verbose" -ge 1 ]; then printf "❗️\n"; fi
        expect_err "$error"
    fi
    if [ "$test_verbose" -ge 1 ]; then printf "☑️\n"; fi
}

pretty_escape() {
    while [ $# -gt 0 ]; do
        if ! [[ "$(printf "%q" "$1")" == *\\* ]]; then # No special characters to escape, so print raw
            printf "%s" "$1"
        else
            num_single_quote_escapes=$(($(tr -dc "'" <<< "$1" | wc -m) * 3)) # three extra chars for '\''
            # NOTE: "!" can, but does not have to be special - we stick to the safe side and assume it is
            # See: https://www.gnu.org/software/bash/manual/html_node/Double-Quotes.html
            # special chars: $`"\!
            num_double_quote_escapes=$(tr -dc '$`"\!' <<< "$1" | wc -m) # special chars in single quote == num of backticks required
            if [ "$num_single_quote_escapes" -gt "$num_double_quote_escapes" ]; then
                printf '"%s"' "$(sed -r 's/([$`"\!])/\\\1/g' <<< "$1")"
            else
                printf "'%s'" "$(sed -r "s/'/'"'\\'"''/g" <<< "$1")"
            fi
        fi
        shift
        [ $# -eq 0 ] || printf " "
    done
}

debug_replace_hooks() {
    while read -r hook; do
        {
            echo "#!/bin/sh"
            printf "%s\n" 'printf "\e[32m%s\e[0m: %s\n" "$0" "$*"'
        } > ".git/hooks/$hook"
        chmod +x ".git/hooks/$hook"
    done < "$DOCDIR/all-git-hooks"
}
