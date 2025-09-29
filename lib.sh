#!/usr/bin/env bash

: "${verbose:=0}"

export verbose
export delete_existing_dir
export git_init_params=("--initial-branch=main")

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
            --ref-format=reftable|--object-format=sha256)
                git_init_params+=("$opt")
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

# colors
RESET='\033[0m'
RED="\e[0;31m"
RED_BOLD='\033[0;31m'
RED_BOLD_ITALIC='\e[3;1;31m'
GREEN="\e[0;32m"
YELLOW="\e[0;33m"
BLUE="\e[0;34m"

warn() {
    printf "$YELLOW%s$RESET\n" "$*" >&2
}

error() {
    printf "$RED_BOLD%s$RESET\n" "$@" >&2
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
    git config user.email "nuggit${emailSuffix}@lohmann.sh"

    # initialize the commit date
    test_tick
}

remove_build_setup_from_config() {
    # remove the things that we only needed for the builds to be reproducible
    git config --local --remove-section user
}

add_player_config() {
    git config --local --add alias.redeem-nuggit '!$(git rev-parse --show-toplevel)/.git/redeem.nuggit'
    git config --local --add alias.skip-to-nuggit-chapter '!$(git rev-parse --show-toplevel)/.git/skip_to_chapter.sh'
    git config --local --add alias.nuggit-progress '!$(git rev-parse --show-toplevel)/.git/progress.sh'
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
    printf "${GREEN}Creating chapter '%s'$RESET\n" "$chapter"
}

remote_git_dir=.git/my-origin
remote_mktree() {
    GIT_DIR="$remote_git_dir" git mktree
}
remote_hash_object_write() {
    GIT_DIR="$remote_git_dir" git hash-object -w "$@"
}

# register the nuggits in our "git database" (aka some loose objects)
store_nuggits() {
    # To avoid the player just running
    # `git fsck --dangling | cut -d " " -f3 | xargs -n 1 git cat-file -p`
    # to grep all the nuggits we don't store them in clear-text, but we store the hash of them.
    # We create a folder with subfolders of the names of the nuggit hashes, and
    # each of them contains a file for the `git log nuggits`-description and
    # the custom success message when redeeming it
    NUGGIT_DESCRIPTION_TREE="$(remote_mktree < <(while read -r line; do
        nuggit="$(printf "%s" "$line" | cut -d "	" -f 1)"
        nuggit_folder_name="$(echo "$nuggit" | git hash-object --stdin)"
        nuggit_description="$(printf "%s" "$line" | cut -d "	" -f 2)"
        nuggit_success_message="$(printf "%s" "$line" | cut -d "	" -f 3)"
        nuggit_description_file_hash="$(remote_hash_object_write --stdin <<< "$nuggit_description")"
        success_file_hash="$(echo "Success! What a nice nuggit for your collection! 🏅 $nuggit_success_message" | remote_hash_object_write --stdin)"
        description_tree_hash="$(printf "100644 blob %s	description\n100644 blob %s	success\n" "$nuggit_description_file_hash" "$success_file_hash"| remote_mktree)"
        if [ "$nuggit" = LocalCodeExecution ]; then
            printf "%s" "$description_tree_hash" > tmp
        fi
        # piped into mktree, this creates a sub-folder in general one with the name of the hashed nuggit to avoid easy discovery
        printf "40000 tree %s	%s\n" "$description_tree_hash" "$nuggit_folder_name"
    done < "$DOCDIR/nuggits.tsv"))"
    LOCAL_CODE_EXECUTION_HASH="$(cat tmp)"
    rm tmp
}

debug_hooks() {
    path_to_dot_git="${1:-.git}"
    while read -r hook; do
        echo '#/bin/sh
    echo "$0: $@"
        ' >> "$path_to_dot_git/hooks/$hook"
        chmod +x "$path_to_dot_git/hooks/$hook"
    done < "$DOCDIR/all-git-hooks"
    for hook in "$path_to_dot_git/hooks/"*; do
        echo 'echo "$0: $@"' >> "$hook"
    done
}

initialise_reflog() {
    ref_name="$1"; shift
    ref="$1"; shift
    message="$1"; shift
    if [ "$(git config --get extensions.objectFormat)" = "sha256" ]; then
        old_oid="0000000000000000000000000000000000000000000000000000000000000000"
    else
        old_oid="0000000000000000000000000000000000000000"
    fi
    new_oid="$(git show --format="%H %cn <%cE> %ct -0000" "$ref")"

    git reflog write "$ref_name" "$old_oid" "$new_oid" "$message" 2>/dev/null || (
        # manual fall back for git<2.52 without `reflog write` feature
        mkdir -p .git/logs
        printf "%s %s	%s\n" "$old_oid" "$new_oid" "$message" > ".git/logs/$ref_name"
    )
}
