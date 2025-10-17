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
create_chapter "add warning alias to root project!"
git config --local --get alias.nuggit >/dev/null || git config --local --add alias.nuggit '!echo "You need to run this command in the \"tutorial\" folder!"'

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
git update-ref --create-reflog nuggits "$INITIAL_NUGGITS_HASH" -m "commit (initial): RootOfAllNuggits"

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
create_chapter merge
git switch --detach main
CHAPTER_MERGE_FOLLOW="--allow-unrelated-histories $END_COMMIT"
replace CHAPTER_MERGE_FOLLOW "$DOCDIR/13_merge/merge.md" > merge.md
git add merge.md
commit -m 'Add description on `git merge`'
git rm merge.md
commit -m 'Remove description on `git merge`'
CHAPTER_REVERT_FOLLOW="$(git rev-parse --short @)"

# ------------------------------------------------------------------------------------------- #
create_chapter revert
git switch --detach main
replace CHAPTER_REVERT_FOLLOW "$DOCDIR/14_revert/revert.md" > revert.md
git add revert.md
commit -m 'Add description on `git revert`'
CHAPTER_RESTORE_SOURCE_FOLLOW="$(git rev-parse --short @)"
CHAPTER_RESTORE_SOURCE_FILE="revert.md"


# ------------------------------------------------------------------------------------------- #
create_chapter restore staged
git switch --detach main
cp "$DOCDIR/12_restore/restore-staged.md" .
git add restore-staged.md
commit -m 'Add description on `git restore --staged`'
CHAPTER_RESET_SOFT_FOLLOW="$(git rev-parse --short @)"

# ------------------------------------------------------------------------------------------- #
create_chapter 'restore source'
CHAPTER_RESTORE_FILE='restore-staged.md'

# ------------------------------------------------------------------------------------------- #
create_chapter reset soft
git switch --detach main
replace CHAPTER_RESET_SOFT_FOLLOW "$DOCDIR/11_reset/reset-soft.md" > reset-soft.md
git add reset-soft.md
commit -m 'Describe `git reset --soft`'
CHAPTER_RESET_HARD_FOLLOW="$(git rev-parse --short @)"

# ------------------------------------------------------------------------------------------- #
create_chapter reset hard
git switch --detach main
printf 'nuggit: MountainCherryRange\n\n' > reset-hard.md
git add reset-hard.md
commit -m 'WIP: add cherry-pick range nuggit'
CHAPTER_CHERRY_PICK_ABORT_FOLLOW_1="$(git rev-parse --short @)"
replace CHAPTER_RESET_HARD_FOLLOW "$DOCDIR/11_reset/reset-hard.md" >> reset-hard.md
commit -m 'Describe `git reset --hard`' -- reset-hard.md
CHAPTER_CHERRY_PICK_ABORT_FOLLOW_2="$(git rev-parse --short @)"

# ------------------------------------------------------------------------------------------- #
create_chapter restore ours
git switch --detach main
cp "$DOCDIR/10_cherry_pick/cherry-pick-v2.md" cherry-pick.md
git add cherry-pick.md
commit -m 'WIP: Describe cherry-pick and merge conflicts'
CHAPTER_CHERRY_PICK_FOLLOW="$(git rev-parse --short @)"

# ------------------------------------------------------------------------------------------- #
create_chapter cherry-pick
git switch --detach main
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

nuggit: LogIcOfGit

To show the log including the diffs, add "--patch" or in short:
```sh
git log -p the-first-tag
```
'
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
# this is only done in the nuggit script on calling `start` - no setup here…
mkdir -p .git/nuggit-src
cp "$DOCDIR/02_status_diff/"* .git/nuggit-src/
cp "$DOCDIR/03_commit/"* .git/nuggit-src/

# ------------------------------------------------------------------------------------------- #
create_chapter finalize setup
git switch main
# should be done as the last thing before installing the hooks
remove_build_setup_from_config

git config --local --add alias.nuggit '!$(git rev-parse --show-toplevel)/.git/nuggit.sh'

# origin hooks
rm -f ".git/my-origin/hooks/"* # get rid of all the ".sample" files
cp "$DOCDIR/origin_hooks/"* ".git/my-origin/hooks"

mkdir ".git/another-downstream/docdir"
cp "$DOCDIR/another-downstream/"* ".git/another-downstream/docdir/"

replace NUMBER_OF_NUGGITS CHAPTER_INTERACTIVE_REBASE_FOLLOW CHAPTER_CHERRY_PICK_FOLLOW "$DOCDIR/nuggit.sh" > .git/nuggit.sh
chmod +x .git/nuggit.sh

rm -f .git/hooks/* # remove all the .sample files, since they are just noise
mkdir -p .git/nuggit-src/hooks

# search for text and then drop next line; afterwards replace placeholder with is_triggered_by-file content
is_triggered_by_placeholder='^\# is_triggered_by replaced by build setup, stub for shellcheck\:'
for filep in "$DOCDIR/hooks/"*; do
    file="$(basename "$filep")"

    replace CHAPTER_DIFF_FOLLOW CHAPTER_COMMIT_FOLLOW CHAPTER_RESTORE_FILE CHAPTER_RESTORE_SOURCE_FOLLOW CHAPTER_RESTORE_SOURCE_FILE CHAPTER_CHERRY_PICK_ABORT_FOLLOW_1 CHAPTER_CHERRY_PICK_ABORT_FOLLOW_2 "$DOCDIR/hooks/$file" |
    sed "/$is_triggered_by_placeholder/ {n;d;}" |
    sed "/$is_triggered_by_placeholder/{
        s/$is_triggered_by_placeholder//g
        r $DOCDIR/hook_is_triggered_by.sh"'
    }' > ".git/nuggit-src/hooks/$file.orig"
done
while read -r hook; do
  replace LOCAL_CODE_EXECUTION_HASH "$DOCDIR/hook_preamble.sh" > ".git/nuggit-src/hooks/$hook"
done < "$DOCDIR/all-git-hooks"
# debug_hooks
# Did you read the comment above that installing the hooks should be last?
trap - EXIT # If we get here: Success!, So remove the error handler
