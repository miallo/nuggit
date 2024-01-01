#!/usr/bin/env bash

set -e

. ./lib.sh

cd challenge

echo 'WorkInProgress in diff'
git diff | grep --quiet "Flag: WorkInProgress"

echo 'CommitmentIssues in diff --staged'
git diff --staged | grep --quiet "Flag: CommitmentIssues"

echo 'LocalCodeExecution flag in hooks'
grep --quiet "# Flag: LocalCodeExecution" .git/hooks/pre-auto-gc
grep --quiet "^exit 1" .git/hooks/pre-auto-gc
echo 'LocalCodeExecution flag should be deleted after execution of the hook'
# git gc --auto # <- not executing the script?
# git hook run pre-auto-gc || : # cannot use since only introduced with git 2.40.0, which is e.g. not included in Ubuntu LTS
./.git/hooks/pre-auto-gc || :
if ! [[ $(grep -L "# Flag: LocalCodeExecution" .git/hooks/*) ]]; then
    error "Selfdeleting flag was not removed after execution..."
    exit 1
fi

echo success!
