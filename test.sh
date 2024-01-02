#!/usr/bin/env bash

set -e

. ./lib.sh

cd challenge

echo 'LocalCodeExecution flag in hooks'
grep --quiet "# Flag: LocalCodeExecution" .git/hooks/*

echo 'WorkInProgress in diff'
git diff | grep --quiet "Flag: WorkInProgress"

echo 'CommitmentIssues in diff --staged'
git diff --staged | grep --quiet "Flag: CommitmentIssues"

echo 'CommitMirInsAbendteuerland in new commit message'
git commit -m 'My first commit' --quiet
git show | grep --quiet "Flag: CommitMirInsAbendteuerland"

echo 'LocalCodeExecution flag should be deleted after execution of any hook (in this case the commit)'
if ! [[ $(grep -L "# Flag: LocalCodeExecution" .git/hooks/*) ]]; then
    error "Selfdeleting flag was not removed after execution..."
    exit 1
fi

echo 'restore should not show Switcheridoo flag'
git restore README.md 2>&1 | grep --quiet "Flag: Switcheridoo" && exit 1 || :

echo 'ShowMeMore in branch commit'
exec $(sed -n '/^```sh$/,/^```$/{n;p;}' commit.md) | grep --quiet "Flag: ShowMeMore"

echo 'Switcheridoo when switching to "branches-explained"'
git switch branches-explained 2>&1 | grep --quiet "Flag: Switcheridoo"

echo 'MyFirstBranch when creating'
git switch -c my-new-branch 2>&1 | grep --quiet "Flag: MyFirstBranch"

git switch history
echo 'LogCat for log'
exec $(sed -n '/^```sh$/,/^```$/{n;p;}' log.md) | grep --quiet "Flag: LogCat"

echo 'AnnotateMeIfYouCan in annotated tag'
git show the-first-tag | grep --quiet "Flag: AnnotateMeIfYouCan"

echo success!
