#!/usr/bin/env bash

. ./lib.sh

parse_opts "$@"
: "${destination:=tutorial}"

# ------------------------------------------------------------------------------------------- #
# setup for the script
if [ "$verbose" -eq 0 ]; then
    exec 3>&1 4>&2 >/dev/null 2>&1 # store stdin / stdout filedescriptors so that we can still print in case of an error
fi
on_error() {
    [ "$verbose" -eq 0 ] && exec 1>&3 2>&4 # restore file descriptors
    printf "❌ ${RED_BOLD_ITALIC}ERROR! ${RED}An error occured while creating chapter %s${RESET}\n" "$chapter">&2
    [ "$verbose" -eq 0 ] && printf "%s" 'Run again with `-v` for more verbose output' >&2
    exit 1
}
set -eE
trap on_error TERM ABRT QUIT ERR EXIT

shopt -s extglob

if [ -e "$destination" ]; then
    if [ "$delete_existing_dir" = true ]; then
        rm -rf "$destination"
    else
        warn "'$destination' already exists. moving to ${destination}2..."
        rm -rf "${destination}2"
        mv "$destination" "${destination}2"
    fi
fi

# ------------------------------------------------------------------------------------------- #
create_chapter initial setup
git init "${git_init_params[@]}" tutorial
cd tutorial
reproducibility_setup

# ------------------------------------------------------------------------------------------- #
create_chapter origin
git init --bare "${git_init_params[@]}" ./.git/my-origin
git remote add origin ./.git/my-origin

# ------------------------------------------------------------------------------------------- #
create_chapter store nuggits
# Create an empty commit for our own nuggits "branch"
# don't use `git commit`, since that would find itself in the reflog
# the `printf "" | git mktree` simulates an empty tree
# (so basically: since there was no commit before, this is an empty commit)
INITIAL_NUGGITS_HASH="$(git commit-tree "$(printf "" | git mktree)" -m "RootOfAllNuggits

Have a free nuggit!")"
# NOTE: This intentionally does NOT create `refs/heads/nuggits`, since that would e.g. show up in `git branch --list`.
# Instead create this "branch" toplevel in `.git/nuggits`
git update-ref nuggits "$INITIAL_NUGGITS_HASH"
# Write initial reflog entry for our "branch" to avoid dangling references
initialise_reflog "nuggits" "nuggits" "commit (initial): RootOfAllNuggits"

store_nuggits
ALMOST_CREDITS_HASH="$(remote_hash_object_write "$DOCDIR/almost_credits.txt")"
# for the final credits do a little rot13, just to make life a bit harder if anyone e.g. greps through the loose objects...
FINAL_CREDITS_HASH="$(tr 'A-Za-z' 'N-ZA-Mn-za-m' < "$DOCDIR/credits.txt" | remote_hash_object_write --stdin)"
CREDITS_TREE="$(printf "100644 blob %s	almost\n100644 blob %s	final\n" "$ALMOST_CREDITS_HASH" "$FINAL_CREDITS_HASH" | remote_mktree)"

NUMBER_OF_NUGGITS="$(($(wc -l <"$DOCDIR/nuggits.tsv")))"

replace NUMBER_OF_NUGGITS CREDITS_TREE NUGGIT_DESCRIPTION_TREE "$DOCDIR/redeem-nuggit.sh" | sed -e 's/\s*# .*$//' -e '/^[[:space:]]*$/d' > ./.git/redeem.nuggit
chmod a=rx ./.git/redeem.nuggit

# ------------------------------------------------------------------------------------------- #
create_chapter final commit
END_BLOB_HASH="$(git hash-object -w "$DOCDIR/credits/the-end.md")"
END_TREE_HASH="$(printf "100644 blob %s	success.md" "$END_BLOB_HASH" | git mktree)"
END_COMMIT="$(git commit-tree "$END_TREE_HASH" -m "Success!")"
# Write reflog entry for the end commit to avoid dangling references
initialise_reflog "success" "$END_COMMIT" "commit (initial): Success!"

# ------------------------------------------------------------------------------------------- #
create_chapter initial commit
cp  "$DOCDIR/01_init/README.md" .
git add .
commit -m "Initial Commit"

# ------------------------------------------------------------------------------------------- #
create_chapter branches
git switch main -c branches-explained
cp "$DOCDIR/04_branch/branch.md" .
git add branch.md
commit -m "WIP: add description on branches

nuggit: ShowMeMore"
# For reference in commit.md later
CHAPTER_COMMIT_FOLLOW="$(git rev-parse --short @)"

# ------------------------------------------------------------------------------------------- #
create_chapter working with branches
git switch branches-explained
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
replace CHAPTER_COMMIT_FOLLOW "$DOCDIR/03_commit/show.md" > show.md
git add show.md
commit -m 'Add description on `git show`'
CHAPTER_DIFF_FOLLOW="$(git rev-parse --short @)"

# ------------------------------------------------------------------------------------------- #
create_chapter cherry-pick
git switch --detach main
CHAPTER_CHERRY_PICK_FOLLOW="$END_COMMIT"
replace CHAPTER_CHERRY_PICK_FOLLOW "$DOCDIR/10_cherry_pick/cherry-pick.md" > cherry-pick.md
git add cherry-pick.md
commit -m "Describe cherry-pick"
CHAPTER_INTERACTIVE_REBASE_FOLLOW="$(git rev-parse --short @)"

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
replace CHAPTER_INTERACTIVE_REBASE_FOLLOW INTERACTIVE_REBASE_EXAMPLE_PICKS "$DOCDIR/07_rebase_merge/interactive-rebase-continued.md" >> interactive-rebase.md
git add interactive-rebase.md
commit -m "Finish describing interactive rebases

TODO: squash commits..."
CHAPTER_REBASE_FOLLOW="$(git rev-parse --short @)"

# ------------------------------------------------------------------------------------------- #
create_chapter rebase/merge
git switch --detach main
replace CHAPTER_REBASE_FOLLOW "$DOCDIR/07_rebase_merge/combine_history.md" > combine_history.md
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
create_chapter push
git switch main -c working-with-others # found via "git branch --list"
git push origin main
git push origin the-first-tag
git push --set-upstream origin @
cp "$DOCDIR/09_push_pull/push.md" working-with-others.md
git add working-with-others.md
commit -m "Explain 'git push'"

# ------------------------------------------------------------------------------------------- #
# chapter pull, see origin_hooks/post_update

# ------------------------------------------------------------------------------------------- #
create_chapter log
(
    cd .git
    git clone ./my-origin another-downstream
    cd another-downstream
    reproducibility_setup 2

    git switch main -c history
    cp "$DOCDIR/06_log/log.md" .
    git add log.md
    commit -m "Add description on log"
    git push --set-upstream origin @
)

# ------------------------------------------------------------------------------------------- #
create_chapter diff
git switch main
cp "$DOCDIR/01_init/first-steps-with-git.md" .
# uncommitted changes/status
# Needs to be second to last (only before hooks), so that the uncommitted changes are available initially
cat "$DOCDIR/02_status_diff/status.md" >> first-steps-with-git.md
{
    cat "$DOCDIR/03_commit/add.md"
    echo # newline for readability
    cat "$DOCDIR/03_commit/commit.md"
} >> first-steps-with-git.md
git add first-steps-with-git.md
commit -m 'first-steps-with-git: add explanation on status and diff'

# tmp file, because gnused and MacOS/FreeBSD sed handle "-i" differently
# `{N;N;d:}` for deleting the following (empty) line as well
sed -e "/$(head -n 1 "$DOCDIR/03_commit/commit.md")/,+$(wc -l < "$DOCDIR/03_commit/commit.md")d" first-steps-with-git.md > tmp
mv tmp first-steps-with-git.md
# num_of_diff_staged_commit_lines="$(( $(wc -l < tmp) - $(wc -l < "$DOCDIR/03_commit/commit.md") + 1))"
# sed "$num_of_diff_staged_commit_lines,$ d" tmp > first-steps-with-git.md
git add first-steps-with-git.md
num_of_diff_commit_lines="$(( $(wc -l < first-steps-with-git.md) - $(wc -l < "$DOCDIR/03_commit/add.md")))"
sed "$num_of_diff_commit_lines,$ d" first-steps-with-git.md > tmp
mv tmp first-steps-with-git.md

# ------------------------------------------------------------------------------------------- #
create_chapter finalize setup
# should be done as the last thing before installing the hooks
remove_build_setup_from_config
add_player_config

# origin hooks
rm ".git/my-origin/hooks/"* # get rid of all the ".sample" files
cp "$DOCDIR/origin_hooks/"* ".git/my-origin/hooks"

mkdir ".git/another-downstream/docdir"
cp "$DOCDIR/another-downstream/"* ".git/another-downstream/docdir/"

# Scripts for aliases
replace CHAPTER_INTERACTIVE_REBASE_FOLLOW "$DOCDIR/skip_to_chapter.sh" > .git/skip_to_chapter.sh
chmod +x .git/skip_to_chapter.sh
replace NUMBER_OF_NUGGITS "$DOCDIR/progress.sh" > .git/progress.sh
chmod +x .git/progress.sh

# hooks (should be installed last, since they are self-mutating and would be called e.g. by `git commit`)
rm .git/hooks/* # remove all the .sample files, since they are just noise

for filep in "$DOCDIR/hooks/"*; do
    file="$(basename "$filep")"
    replace CHAPTER_DIFF_FOLLOW CHAPTER_COMMIT_FOLLOW "$DOCDIR/hooks/$file" > ".git/hooks/$file.orig"
    chmod +x ".git/hooks/$file.orig"
done
while read -r hook; do
    replace LOCAL_CODE_EXECUTION_HASH "$DOCDIR/hook_preamble.sh" > ".git/hooks/$hook"
    chmod +x ".git/hooks/$hook"
done < "$DOCDIR/all-git-hooks"
# debug_hooks
# Did you read the comment above that installing the hooks should be last?
trap - EXIT # If we get here: Success!, So remove the error handler
