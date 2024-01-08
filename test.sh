#!/usr/bin/env bash

set -e

. ./lib.sh
. ./lib-test.sh
echo "Building..."
./create_challenge.sh
cd challenge
reproducibility_setup

check_redeem_without_local_code_execution() {
    while read -r nuggit; do
        [ "$nuggit" != LocalCodeExecution ] || continue
        [ "$nuggit" != WorkInProgress ] || continue # we want to do this after all the others, so we see that this is the first time that the "You almost got it" text is shown
        expect "./redeem.nuggit '$nuggit'" not to contain "You almost got it"
    done < "$DOCDIR/nuggits"
    expect "./redeem.nuggit WorkInProgress" to contain "You almost got it! There is only a single flag left to redeem..."
    expect "./redeem.nuggit WorkInProgress" to contain "You almost got it! There is only a single flag left to redeem..."
}

it 'LocalCodeExecution should be nonexistent/unredeamable after the trap got triggered' '
git commit -am "Just a test to trigger hooks"
expect "! ./redeem.nuggit LocalCodeExecution 2>&1" to contain "Unfortunately that is not a valid nuggit"
check_redeem_without_local_code_execution
'

echo "Building once more..."
cd ..
./create_challenge.sh
echo "Running tests..."
cd challenge
reproducibility_setup

redeem_nuggit() {
    expect "./redeem.nuggit '$1'" to contain Success
}

it 'LocalCodeExecution flag in hooks' '
expect "cat .git/hooks/*" to contain "nuggit: LocalCodeExecution"
redeem_nuggit LocalCodeExecution
'

it 'WorkInProgress in diff' '
expect "git diff" to contain "nuggit: WorkInProgress"
redeem_nuggit WorkInProgress
'

it 'CommitmentIssues in diff --staged' '
expect "git diff --staged" to contain "nuggit: CommitmentIssues"
redeem_nuggit CommitmentIssues
'

it 'CommitMirInsAbendteuerland in new commit message' '
git commit -m "My first commit" --quiet
expect "git show" to contain "nuggit: CommitMirInsAbendteuerland"
redeem_nuggit CommitMirInsAbendteuerland
'

it 'LocalCodeExecution flag should be deleted after execution of any hook (in this case the commit)' '
expect "cat .git/hooks/*" not to contain "nuggit: LocalCodeExecution"
'

it 'restore should not show Switcheridoo flag' '
expect "git restore README.md 2>&1" not to contain "nuggit: Switcheridoo"
'

it 'ShowMeMore in branch commit' <<EOF
expect 'eval "\$(get_sh_codeblock commit.md)"' to contain "nuggit: ShowMeMore"
redeem_nuggit ShowMeMore
EOF

it 'Switcheridoo when switching to "branches-explained"' '
expect "git switch branches-explained 2>&1" to contain "nuggit: Switcheridoo"
redeem_nuggit Switcheridoo
'

it 'MyFirstBranch when creating' '
expect "git switch -c my-new-branch 2>&1" to contain "nuggit: MyFirstBranch"
redeem_nuggit MyFirstBranch
git switch history -q
'

it 'LogCat for log' <<EOF
expect 'eval "\$(get_sh_codeblock log.md)"' to contain "nuggit: LogCat"
redeem_nuggit LogCat
EOF

it 'AnnotateMeIfYouCan in annotated tag' '
expect "git show the-first-tag" to contain "nuggit: AnnotateMeIfYouCan"
redeem_nuggit AnnotateMeIfYouCan
git switch --detach -q the-first-tag
'

xit 'TODO: find title for combine_history testcase' <<EOF
expect 'eval "\$(get_sh_codeblock combine_history.md)"' to contain "FIXME TODO"
EOF

it 'An invalid nuggit should show an error' '
expect "! ./redeem.nuggit NotANuggit 2>&1" to contain "Unfortunately that is not a valid nuggit"
expect "! ./redeem.nuggit NotANuggit 2>&1" to contain "It still isn'\''t a valid answer..."
expect "! ./redeem.nuggit NotANuggit 2>&1" to contain "It still isn'\''t a valid answer..."
'

it 'CuriosityKilledTheCat in redeem script' '
expect "cat redeem.nuggit" to contain CuriosityKilledTheCat
redeem_nuggit CuriosityKilledTheCat
'

check_redeem() {
    while read -r nuggit; do
        expect "./redeem.nuggit '$nuggit'" to contain "You have found all the little nuggits?! Very impressive!"
        expect "./redeem.nuggit '$nuggit'" to contain "already redeemed"
        expect "./redeem.nuggit '$nuggit'" not to contain Success
    done < "$DOCDIR/nuggits"
}

it 'All nuggits should be redeemed at the end of the test' check_redeem

echo success!
