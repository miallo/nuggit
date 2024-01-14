#!/usr/bin/env bash

: "${verbose:=0}"

export verbose
export delete_existing_dir

parse_opts() {
    while [ $# -gt 0 ]; do
        opt="$1"; shift
        case "$opt" in
            -v|--verbose)
                verbose=$((verbose + 1))
                ;;
            -f|--force)
                delete_existing_dir=true
                ;;
            *)
                echo "ERROR! Unknown option '$opt'. Useage: $0 [-v|--verbose] [-f|--force]" >&2
                exit 1
                ;;
        esac
    done
}

ROOT="$(git rev-parse --show-toplevel)"
DOCDIR="$ROOT/src"

export ROOT DOCDIR

warn() {
    printf "\e[33m%s\e[0m\n" "$*" >&2
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

# shellcheck disable=SC2120 # the parameter is optional
reproducibility_setup() {
    # Setup for reproducibility
    # Don't use $HOME/.gitconfig or global config
    export GIT_CONFIG_SYSTEM=""
    export GIT_CONFIG_GLOBAL=""

    nameSuffix="${1:-}"
    emailSuffix="${nameSuffix:+"+$nameSuffix"}" # = if we have a nameSuffix: prefix it with a plus
    # use fixed user, else empty
    git config user.name "Nuggit$nameSuffix Challenge"
    git config user.email "nuggit-challenge${emailSuffix}@gmail.com"

    # initialize the commit date
    test_tick
}

remove_build_setup_from_config() {
    # remove the things that we only needed for the builds to be reproducible
    git config --local --remove-section user
}

add_player_config() {
    git config --local --add alias.redeem-nuggit '!$(git rev-parse --show-toplevel)/.git/redeem.nuggit'
}

# Useage:
# replace MV_VAR1 MY_VAR2 [...] input_file > output_file
replace () {
    local input_file="${!#}" # last argument
    local variable_names=("${@:1:$#-1}") # all but the last argument
    for var in "${variable_names[@]}"; do
        printf "s/%s/%s/g\n" "$var" "${!var}" # search variable name and replace with variable content
    done | sed -f- "$input_file" # read sed instructions from std-in
}

create_chapter() {
    chapter="$*"
    printf "\e[32mCreating chapter '%s'\e[0m\n" "$chapter"
}
