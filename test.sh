#!/usr/bin/env bash

set -e

. ./lib.sh
. ./lib-test.sh

echo "Building..."
./create_challenge.sh >/dev/null 2>&1
echo "Running tests..."

cd challenge

it 'LocalCodeExecution flag in hooks' '
expect "cat .git/hooks/*" to contain "nuggit: LocalCodeExecution"
'

it 'WorkInProgress in diff' '
expect "git diff" to contain "nuggit: WorkInProgress"
'

it 'CommitmentIssues in diff --staged' '
expect "git diff --staged" to contain "nuggit: CommitmentIssues"
'

it 'CommitMirInsAbendteuerland in new commit message' '
git commit -m "My first commit" --quiet
expect "git show" to contain "nuggit: CommitMirInsAbendteuerland"
'

it 'LocalCodeExecution flag should be deleted after execution of any hook (in this case the commit)' '
expect "cat .git/hooks/*" not to contain "nuggit: LocalCodeExecution"
'

it 'restore should not show Switcheridoo flag' '
expect "git restore README.md 2>&1" not to contain "nuggit: Switcheridoo"
'

it 'ShowMeMore in branch commit' <<EOF
expect 'eval "\$(get_sh_codeblock commit.md)"' to contain "nuggit: ShowMeMore"
EOF

it 'Switcheridoo when switching to "branches-explained"' '
expect "git switch branches-explained 2>&1" to contain "nuggit: Switcheridoo"
'

it 'MyFirstBranch when creating' '
expect "git switch -c my-new-branch 2>&1" to contain "nuggit: MyFirstBranch"
git switch history -q
'

it 'LogCat for log' <<EOF
expect 'eval "\$(get_sh_codeblock log.md)"' to contain "nuggit: LogCat"
EOF

it 'AnnotateMeIfYouCan in annotated tag' '
expect "git show the-first-tag" to contain "nuggit: AnnotateMeIfYouCan"
git switch --detach -q the-first-tag
'

xit 'TODO: find title for combine_history testcase' <<EOF
expect 'eval "\$(get_sh_codeblock combine_history.md)"' to contain "FIXME TODO"
EOF

echo success!
