#!/usr/bin/env bash

set -e
shopt -s extglob
. ./lib.sh

if [ -e challenge ]; then
    warn "'challenge' already exists. moving to challenge2..."
    rm -rf challenge2
    mv challenge challenge2
fi

# initial setup

# TODO: figure out how to use --template="$DOCDIR/01_init"
git init --initial-branch=main challenge
cd challenge
reproducibility_setup

cp "$DOCDIR/01_init/"* .
git add .
commit -m "Initial Commit"

# branches
git switch -c branches-explained
cp "$DOCDIR/04_branch/branch.md" .
git add branch.md
commit -m "WIP: add description on branches

Flag: ShowMeMore"
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

git switch main

# commit
sed "s/BRANCH_COMMIT/$BRANCH_COMMIT/" "$DOCDIR/03_commit/commit.md" > commit.md
git add commit.md
commit -m "Add description on commit"

# uncommitted changes/status
# Needs to be second to last (only before hooks), so that the uncommitted changes are available initially
cat "$DOCDIR/02_status_diff/status.md" >> README.md
UNSTAGED_FLAG='Flag: WorkInProgress'
STAGING_DIFF_DESCRIPTION='For seeing what would be committed next you can run `git diff --staged`. A synonym for "--staged" that you might see in some places is "--cached".'
STAGING_FLAG='Flag: CommitmentIssues'
COMMIT_DESCRIPTION='To commit all changes in the staging area you can run `git commit` and an editor will open where you can type a commit message. Further information can be found in "commit.md"'
{
    echo "$UNSTAGED_FLAG"
    echo # newline for readability
    echo "$STAGING_DIFF_DESCRIPTION"
    echo # newline for readability
    echo "$STAGING_FLAG"
    echo # newline for readability
    echo "$COMMIT_DESCRIPTION"
} >> README.md
git add README.md
commit -m 'README: add explanation on status and diff'

# tmp file, because gnused and MacOS/FreeBSD sed handle "-i" differently
# `{N;N;d:}` for deleting the following (empty) line as well
sed "/$STAGING_FLAG/{N;N;d;}" README.md > tmp
sed "/$COMMIT_DESCRIPTION/{N;N;d;}" tmp > README.md
git add README.md
sed "/$UNSTAGED_FLAG/{N;N;d;}" README.md > tmp
sed "/$STAGING_DIFF_DESCRIPTION/{N;N;d;}" tmp > README.md
rm tmp

# hooks (should be installed last, since they are self-mutating and would be called e.g. by `git commit`)
rm .git/hooks/*

for file in $(ls "$DOCDIR/hooks"); do
    cp "$DOCDIR/hooks/$file" ".git/hooks/$file.orig"
done
while read -r hook; do
    cp "$DOCDIR/hook_preamble.sh" ".git/hooks/$hook"
done < "$DOCDIR/all-git-hooks"
