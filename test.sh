#!/usr/bin/env bash

set -e

. ./lib.sh
. ./lib-test.sh

echo "Building..."
./create_challenge.sh >/dev/null 2>&1
echo "Running tests..."

cd challenge

it 'LocalCodeExecution flag in hooks' '
expect "cat .git/hooks/*" to contain "Flag: LocalCodeExecution"
'

it 'WorkInProgress in diff' '
expect "git diff" to contain "Flag: WorkInProgress"
'

it 'CommitmentIssues in diff --staged' '
expect "git diff --staged" to contain "Flag: CommitmentIssues"
'

it 'CommitMirInsAbendteuerland in new commit message' '
git commit -m "My first commit" --quiet
expect "git show" to contain "Flag: CommitMirInsAbendteuerland"
'

it 'LocalCodeExecution flag should be deleted after execution of any hook (in this case the commit)' '
expect "cat .git/hooks/*" not to contain "Flag: LocalCodeExecution"
'

it 'restore should not show Switcheridoo flag' '
expect "git restore README.md 2>&1" not to contain "Flag: Switcheridoo"
'

it 'ShowMeMore in branch commit' <<EOF
expect 'eval "\$(get_sh_codeblock commit.md)"' to contain "Flag: ShowMeMore"
EOF

it 'Switcheridoo when switching to "branches-explained"' '
expect "git switch branches-explained 2>&1" to contain "Flag: Switcheridoo"
'

it 'MyFirstBranch when creating' '
expect "git switch -c my-new-branch 2>&1" to contain "Flag: MyFirstBranch"
git switch history -q
'

it 'LogCat for log' <<EOF
expect 'eval "\$(get_sh_codeblock log.md)"' to contain "Flag: LogCat"
EOF

it 'AnnotateMeIfYouCan in annotated tag' '
expect "git show the-first-tag" to contain "Flag: AnnotateMeIfYouCan"
'

echo success!
