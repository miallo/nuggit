#!/usr/bin/env bash

. ./lib.sh

parse_opts "$@"

# ------------------------------------------------------------------------------------------- #
# setup for the script
if [ "$verbose" -eq 0 ]; then
    exec 3>&1 4>&2 >/dev/null 2>&1 # store stdin / stdout filedescriptors so that we can still print in case of an error
fi
on_error() {
    [ "$verbose" -eq 0 ] && exec 1>&3 2>&4 # restore file descriptors
    printf "❌ \e[3;1;31mERROR!\e[0m \e[31mAn error occured while creating chapter %s\e[0m\n" "$chapter">&2
    [ "$verbose" -eq 0 ] && printf "%s" 'Run again with `-v` for more verbose output' >&2
    exit 1
}
set -eE
trap on_error TERM ABRT QUIT ERR EXIT

shopt -s extglob

if [ -e challenge ]; then
    if [ "$delete_existing_dir" = true ]; then
        rm -rf challenge
    else
        warn "'challenge' already exists. moving to challenge2..."
        rm -rf challenge2
        mv challenge challenge2
    fi
fi

# ------------------------------------------------------------------------------------------- #
create_chapter initial setup
git init --initial-branch=main challenge
cd challenge
reproducibility_setup

# ------------------------------------------------------------------------------------------- #
create_chapter store nuggits
# Create an empty commit for our own nuggits "branch"
# don't use `git commit`, since that would find itself in the reflog
# the `printf "" | git mktree` simulates an empty tree
# (so basically: since there was no commit before, this is an empty commit)
git commit-tree "$(printf "" | git mktree)" -m "RootOfAllNuggits

Have a free nuggit!" > .git/nuggits

# TODO: once we have the origin and another "clone" in the .git folder, we should store the blobs in there, because it is trivial to list all of them with `git fsck --dangling | cut -d " " -f3 | xargs -n 1 git cat-file -p`
eval "$DOCDIR/store_nuggits.sh" # register the nuggits in our "git database" (aka some loose objects)
ALMOST_CREDITS_HASH="$(git hash-object -w "$DOCDIR/almost_credits.txt")"
# for the final credits do a little rot13, just to make life a bit harder if anyone e.g. greps through the loose objects...
CREDITS_HASH="$(tr 'A-Za-z' 'N-ZA-Mn-za-m' < "$DOCDIR/credits.txt" | git hash-object -w --stdin)"
NUMBER_OF_NUGGITS="$(wc -l <"$DOCDIR/nuggits")"

replace_placeholders "$DOCDIR/redeem.nuggit" > ./.git/redeem.nuggit
chmod a=rx ./.git/redeem.nuggit

# ------------------------------------------------------------------------------------------- #
create_chapter initial commit
cp -r "$DOCDIR/01_init/"* .
git add .
commit -m "Initial Commit"

# ------------------------------------------------------------------------------------------- #
create_chapter branches
git switch -c branches-explained
cp "$DOCDIR/04_branch/branch.md" .
git add branch.md
commit -m "WIP: add description on branches

nuggit: ShowMeMore"
# For reference in commit.md later
BRANCH_COMMIT="$(git rev-parse --short @)"

# ------------------------------------------------------------------------------------------- #
create_chapter working with branches
echo 'A slightly older alternative to `switch` is `checkout`, which also works, but it can do destructive things if you don'\''t pay attention, so that is why `switch` is generally preferred nowadays.' >> branch.md
git add branch.md
commit -m "WIP branch: add explanation on checkout"

cat "$DOCDIR/04_branch/branch_create_delete.md" >> branch.md
git add branch.md
commit -m "WIP branch: add explanation on how to create/delete"

cat "$DOCDIR/04_branch/branch_list.md" >> branch.md
git add branch.md
commit -m "WIP branch: add explanation on how to list local branches"

# ------------------------------------------------------------------------------------------- #
create_chapter commit
git switch --detach main
replace_placeholders "$DOCDIR/03_commit/commit.md" > commit.md
git add commit.md
commit -m "Add description on commit"
CHAPTER_COMMIT_COMMIT="$(git rev-parse --short @)"

# ------------------------------------------------------------------------------------------- #
create_chapter interactive rebase
git switch --detach main
printf "%s" '# Interactive rebase

An interactive rebase lets you (as the name suggests) interact with it instead of just step by step applying each patch. This can be incredibly useful after you created a lot of `git commit -m "WIP: Coffee break"`' > interactive-rebase.md
git add interactive-rebase.md
commit -m "WIP: Coffee break"
echo " commits, but after you are done with your feature, you don't want keep them forever and you don't want to bother the reviewer (and you yourself when you will eventually try to find a bug in your code and look at the log) with them." >> interactive-rebase.md
git add interactive-rebase.md
commit -m "WIP: finish sentence on interactive rebases"
INTERACTIVE_REBASE_EXAMPLE_PICKS="$(git log --oneline main..@ | sed 's/^/pick /' | sed 's/$/\\/g')
[...]"
# FIXME
CHAPTER_AMEND_COMMIT=CHAPTER_AMEND_COMMIT
replace_placeholders "$DOCDIR/07_rebase_merge/interactive-rebase-continued.md" >> interactive-rebase.md
git add interactive-rebase.md
commit -m "Finish describing interactive rebases

TODO: squash commits..."
INTERACTIVE_REBASE_COMMIT="$(git rev-parse --short @)"

# ------------------------------------------------------------------------------------------- #
create_chapter rebase/merge
git switch --detach main
replace_placeholders "$DOCDIR/07_rebase_merge/combine_history.md" > combine_history.md
git add combine_history.md
commit -m "Add description on how to combine branches"

# ------------------------------------------------------------------------------------------- #
create_chapter tags
cp "$DOCDIR/08_tags/tags.md" .
git add tags.md
commit -m 'Add description on tags

nuggit: LogCat'
git tag -a the-first-tag -m "nuggit: AnnotateMeIfYouCan"

# ------------------------------------------------------------------------------------------- #
create_chapter log
git switch main -c history
cp "$DOCDIR/06_log/log.md" .
git add log.md
commit -m "Add description on log"

# ------------------------------------------------------------------------------------------- #
create_chapter diff
git switch main
# uncommitted changes/status
# Needs to be second to last (only before hooks), so that the uncommitted changes are available initially
cat "$DOCDIR/02_status_diff/status.md" >> README.md
UNSTAGED_NUGGIT='nuggit: WorkInProgress'
STAGING_DIFF_DESCRIPTION='For seeing what would be committed next you can run `git diff --staged`. A synonym for "--staged" that you might see in some places is "--cached".'
STAGING_NUGGIT='nuggit: CommitmentIssues'
COMMIT_DESCRIPTION='To see the difference between your current working-directory (the files you see in the folder) and a commit, you can add a hash, and also if you want a path (add "--" before the path to tell git that the remaining arguments are paths:
```sh
git diff '"$CHAPTER_COMMIT_COMMIT"' -- commit.md
```'
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
num_of_diff_commit_lines="$(( $(wc -l < tmp) - $(echo "$COMMIT_DESCRIPTION" | wc -l) + 1))"
sed "$num_of_diff_commit_lines,$ d" tmp > README.md
git add README.md
sed "/$UNSTAGED_NUGGIT/{N;N;d;}" README.md > tmp
sed "/$STAGING_DIFF_DESCRIPTION/{N;N;d;}" tmp > README.md
rm tmp

# ------------------------------------------------------------------------------------------- #
create_chapter finalize setup
# should be done as the last thing before installing the hooks
remove_build_setup_from_config
add_player_config

# hooks (should be installed last, since they are self-mutating and would be called e.g. by `git commit`)
rm .git/hooks/* # remove all the .sample files, since they are just noise

LOCAL_CODE_EXECUTION_HASH="$(echo "LocalCodeExecution" | git hash-object --stdin | git hash-object --stdin)"
for filep in "$DOCDIR/hooks/"*; do
    file="$(basename "$filep")"
    replace_placeholders "$DOCDIR/hooks/$file" > ".git/hooks/$file.orig"
    chmod +x ".git/hooks/$file.orig"
done
while read -r hook; do
    replace_placeholders "$DOCDIR/hook_preamble.sh" > ".git/hooks/$hook"
    chmod +x ".git/hooks/$hook"
done < "$DOCDIR/all-git-hooks"
# Did you read the comment above?
trap - EXIT # If we get here: Success!, So remove the error handler
