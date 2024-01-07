#!/usr/bin/env bash

ROOT="$(git rev-parse --show-toplevel)"
DOCDIR="$ROOT/src"

export ROOT DOCDIR

warn() {
    echo "$@" >&2
}

error() {
    RED='\033[0;31m'
    NC='\033[0m' # No Color
    printf "${RED}%s${NC}\n" "$@" >&2
}

# copied from https://github.com/git/git/blob/e79552d19784ee7f4bbce278fe25f93fbda196fa/t/test-lib-functions.sh#L133-L143
# For all sha stability it is important to increment the dates by a fixed time (60s)
test_tick () {
    if test -z "${test_tick+set}"
    then
        test_tick=1112911993
    else
        test_tick=$((test_tick + 60))
    fi
    GIT_COMMITTER_DATE="$test_tick -0700"
    GIT_AUTHOR_DATE="$test_tick -0700"
    export GIT_COMMITTER_DATE GIT_AUTHOR_DATE
}

commit() {
    # commit with fixed time so that the hashes are stable
    test_tick
    git commit "$@"
}

reproducibility_setup() {
    # Setup for reproducibility
    # Don't use $HOME/.gitconfig or global config
    export GIT_CONFIG_SYSTEM=""
    export GIT_CONFIG_GLOBAL=""

    # use fixed user
    git config user.name "Nuggit Challenge"
    git config user.email nuggit-challenge@gmail.com
}

replace_placeholders() {
    sed -e "s/INTERACTIVE_REBASE_BASE_COMMIT/$INTERACTIVE_REBASE_BASE_COMMIT/" \
        -e "s/BRANCH_COMMIT/$BRANCH_COMMIT/" \
        -e "s/CREDIT_WHERE_CREDIT_IS_DUE/$(printf "%q" "$CREDIT_WHERE_CREDIT_IS_DUE")"/ \
        -e "s/LOCAL_CODE_EXECUTION_HASH/$LOCAL_CODE_EXECUTION_HASH/" \
        -e "s/INTERACTIVE_REBASE_EXAMPLE_PICKS/$INTERACTIVE_REBASE_EXAMPLE_PICKS/" \
        -e "s/INTERACTIVE_REBASE_COMMIT/$INTERACTIVE_REBASE_COMMIT/" "$1"
}
