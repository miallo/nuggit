#!/usr/bin/env bash

ROOT="$(git rev-parse --show-toplevel)"
DOCDIR="$ROOT/src"

export ROOT DOCDIR

warn() {
    echo "$@" >&2
}

# copied from https://github.com/git/git/blob/e79552d19784ee7f4bbce278fe25f93fbda196fa/t/test-lib-functions.sh#L133-L143
# For all sha stability it is important to increment the dates by a fixed time (60s)
test_tick () {
    if test -z "${test_tick+set}"
    then
        test_tick=1112911993
    else
        test_tick=$(($test_tick + 60))
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
    GIT_CONFIG_SYSTEM=""
    GIT_CONFIG_GLOBAL=""

    # use fixed user
    git config user.name "Nuggit Challenge"
    git config user.email nuggit-challenge@gmail.com
}
