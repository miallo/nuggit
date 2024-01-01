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

echo 'ShowMeMore in branch commit'
exec $(sed -n '/^```sh$/,/^```$/{n;p;}' commit.md) | grep --quiet "Flag: ShowMeMore"

echo 'LocalCodeExecution flag should be deleted after execution of any hook (in this case the commit)'
if ! [[ $(grep -L "# Flag: LocalCodeExecution" .git/hooks/*) ]]; then
    error "Selfdeleting flag was not removed after execution..."
    exit 1
fi

echo success!
