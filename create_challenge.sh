#!/usr/bin/env bash

while [ $# -gt 0 ]; do
    opt="$1"; shift
    case "$opt" in
        -v|--verbose)
            verbose=true
            ;;
        -f|--force|--delete-existing-challenge)
            delete_existing_dir=true
            ;;
        *)
            echo "ERROR! Unknown option '$opt'. Useage: $0 [-v|--verbose] [-f|--force|--delete-existing-challenge]" >&2
            exit 1
            ;;
    esac
done

if [ "$verbose" != true ]; then
    exec 3>&1 4>&2 >/dev/null 2>&1 # store stdin / stdout filedescriptors so that we can still print in case of an error
fi
on_error() {
    [ "$verbose" != true ] && exec 1>&3 2>&4 # restore file descriptors
    printf "❌ \e[3;1;31mERROR!\e[0m \e[31mAn error occured while creating chapter %s\e[0m\n" "$chapter">&2
    [ "$verbose" != true ] && printf "%s" 'Run again with `-v` for more verbose output' >&2
    exit 1
}
set -eE
trap on_error TERM ABRT QUIT ERR EXIT

shopt -s extglob
. ./lib.sh

if [ -e challenge ]; then
    if [ "$delete_existing_dir" = true ]; then
        rm -rf challenge
    else
        warn "'challenge' already exists. moving to challenge2..."
        rm -rf challenge2
        mv challenge challenge2
    fi
fi

LOCAL_CODE_EXECUTION_HASH="$(echo "LocalCodeExecution" | git hash-object --stdin | git hash-object --stdin)"
NUMBER_OF_NUGGITS="$(wc -l <"$DOCDIR/nuggits")"

create_chapter initial setup
# TODO: figure out how to use --template="$DOCDIR/01_init"
initial_branch=main
git init --initial-branch="$initial_branch" challenge
cd challenge
reproducibility_setup

# Create an empty commit for our own nuggits "branch"
# don't use `git commit`, since that would find itself in the reflog
# the `printf "" | git mktree` simulates an empty tree
# (so basically: since there was no commit before, this is an empty commit)
git commit-tree "$(printf "" | git mktree)" -m "RootOfAllNuggits

Have a free nuggit!" > .git/nuggits

cp -r "$DOCDIR/01_init/"* .
git add .
commit -m "Initial Commit"

create_chapter branches
git switch -c branches-explained
cp "$DOCDIR/04_branch/branch.md" .
git add branch.md
commit -m "WIP: add description on branches

nuggit: ShowMeMore"
# For reference in commit.md later
BRANCH_COMMIT="$(git rev-parse --short @)"

echo 'A slightly older alternative to `switch` is `checkout`, which also works, but it can do destructive things if you don'\''t pay attention, so that is why `switch` is generally preferred.' >> branch.md
git add branch.md
commit -m "WIP branch: add explanation on checkout"

cat "$DOCDIR/04_branch/branch_create_delete.md" >> branch.md
git add branch.md
commit -m "WIP branch: add explanation on how to create/delete"

cat "$DOCDIR/04_branch/branch_list.md" >> branch.md
git add branch.md
commit -m "WIP branch: add explanation on how to list local branches"

create_chapter commit
git switch main
replace_placeholders "$DOCDIR/03_commit/commit.md" > commit.md
git add commit.md
commit -m "Add description on commit"

create_chapter rebase/merge
git switch --detach main
# TODO: create interactive rebase commit
INTERACTIVE_REBASE_COMMIT="INTERACTIVE_REBASE_COMMIT"
replace_placeholders "$DOCDIR/07_rebase_merge/combine_history.md" > combine_history.md
git add combine_history.md
commit -m "Add description on how to combine branches"

create_chapter tags
cp "$DOCDIR/08_tags/tags.md" .
git add tags.md
commit -m 'Add description on tags

nuggit: LogCat'
git tag -a the-first-tag -m "nuggit: AnnotateMeIfYouCan"

create_chapter log
git switch main -c history
cp "$DOCDIR/06_log/log.md" .
git add log.md
commit -m "Add description on log"

create_chapter diff
git switch main
# uncommitted changes/status
# Needs to be second to last (only before hooks), so that the uncommitted changes are available initially
cat "$DOCDIR/02_status_diff/status.md" >> README.md
UNSTAGED_NUGGIT='nuggit: WorkInProgress'
STAGING_DIFF_DESCRIPTION='For seeing what would be committed next you can run `git diff --staged`. A synonym for "--staged" that you might see in some places is "--cached".'
STAGING_NUGGIT='nuggit: CommitmentIssues'
COMMIT_DESCRIPTION='To commit all changes in the staging area you can run `git commit` and an editor will open where you can type a commit message. Further information can be found in "commit.md"'
{
    echo "$UNSTAGED_NUGGIT"
    echo # newline for readability
    echo "$STAGING_DIFF_DESCRIPTION"
    echo # newline for readability
    echo "$STAGING_NUGGIT"
    echo # newline for readability
    echo "$COMMIT_DESCRIPTION"
} >> README.md
git add README.md
commit -m 'README: add explanation on status and diff'

# tmp file, because gnused and MacOS/FreeBSD sed handle "-i" differently
# `{N;N;d:}` for deleting the following (empty) line as well
sed "/$STAGING_NUGGIT/{N;N;d;}" README.md > tmp
sed "/$COMMIT_DESCRIPTION/{N;N;d;}" tmp > README.md
git add README.md
sed "/$UNSTAGED_NUGGIT/{N;N;d;}" README.md > tmp
sed "/$STAGING_DIFF_DESCRIPTION/{N;N;d;}" tmp > README.md
rm tmp

create_chapter store nuggits
# nuggits
# TODO: once we have the origin and another "clone" in the .git folder, we should store the blobs in there, because it is trivial to list all of them with `git fsck --dangling | cut -d " " -f3 | xargs -n 1 git cat-file -p`
eval "$DOCDIR/store_nuggits.sh" # register the nuggits in our "git database" (aka some loose objects)
ALMOST_CREDITS_HASH="$(git hash-object -w "$DOCDIR/almost_credits.txt")"
# for the final credits do a little rot13, just to make life a bit harder if anyone e.g. greps through the loose objects...
CREDITS_HASH="$(tr 'A-Za-z' 'N-ZA-Mn-za-m' < "$DOCDIR/credits.txt" | git hash-object -w --stdin)"

replace_placeholders "$DOCDIR/redeem.nuggit" > ./.git/redeem.nuggit
chmod a=rx ./.git/redeem.nuggit

# should be done as the last thing before installing the hooks
remove_build_setup_from_config
add_player_config

create_chapter hooks
# hooks (should be installed last, since they are self-mutating and would be called e.g. by `git commit`)
rm .git/hooks/*

for filep in "$DOCDIR/hooks/"*; do
    file="$(basename "$filep")"
    replace_placeholders "$DOCDIR/hooks/$file" > ".git/hooks/$file.orig"
    chmod +x ".git/hooks/$file.orig"
done
while read -r hook; do
    replace_placeholders "$DOCDIR/hook_preamble.sh" > ".git/hooks/$hook"
    chmod +x ".git/hooks/$hook"
done < "$DOCDIR/all-git-hooks"

trap - EXIT
