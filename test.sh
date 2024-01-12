#!/usr/bin/env bash

set -e

: "${verbose:=0}"

. ./lib.sh

parse_opts "$@"

. ./test_helpers/lib-test.sh
build_challenge() {
    echo "Building challenge..."
    ./create_challenge.sh --force
}
build_challenge
cd challenge
reproducibility_setup

check_redeem_without_local_code_execution() {
    while read -r nuggit; do
        [ "$nuggit" != LocalCodeExecution ] || continue
        [ "$nuggit" != WorkInProgress ] || continue # we want to do this after all the others, so we see that this is the first time that the "You almost got it" text is shown
        expect "git redeem-nuggit '$nuggit'" not to contain "You almost got it"
    done < "$DOCDIR/nuggits"
    expect "git redeem-nuggit WorkInProgress" to contain "You almost got it! There is only a single nuggit left to redeem..."
    expect "git redeem-nuggit WorkInProgress" to contain "You almost got it! There is only a single nuggit left to redeem..."
}

it 'LocalCodeExecution should be nonexistent/unredeamable after the trap got triggered' '
expect "git commit -am \"Just a test to trigger hooks\"" to succeed
expect "! git redeem-nuggit LocalCodeExecution 2>&1" to contain "Unfortunately that is not a valid nuggit"
check_redeem_without_local_code_execution
'

cd ..
build_challenge
echo "Running tests..."
cd challenge
reproducibility_setup

redeem_nuggit() {
    expect "git redeem-nuggit '$1'" to contain Success
}

it 'LocalCodeExecution nuggit in hooks' '
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

it 'diff <commit>' '
diff_commit_command="$(get_sh_codeblock <(git diff --staged | cut -c 2-))"
expect "$diff_commit_command" to contain "nuggit: AbsoluteDifferentiable"
redeem_nuggit AbsoluteDifferentiable
'

it 'CommitMirInsAbendteuerland in new commit message' '
expect "git commit -m \"My first commit\"" to succeed
expect "git show" to contain "nuggit: CommitMirInsAbendteuerland"
redeem_nuggit CommitMirInsAbendteuerland
'

it 'LocalCodeExecution nuggit should be deleted after execution of any hook (in this case the commit)' '
expect "cat .git/hooks/*" not to contain "nuggit: LocalCodeExecution"
'

it 'restore should not show Switcheridoo nuggit' '
expect "git restore README.md 2>&1" not to contain "nuggit: Switcheridoo"
'

it 'ShowMeMore in branch commit' <<EOF
expect 'eval "\$(get_sh_codeblock <(\$diff_commit_command | cut -c 2-))"' to contain "nuggit: ShowMeMore"
redeem_nuggit ShowMeMore
EOF

it 'Switcheridoo when switching to "branches-explained"' '
expect "git switch branches-explained 2>&1" to contain "nuggit: Switcheridoo"
redeem_nuggit Switcheridoo
'

it 'MyFirstBranch when creating' '
expect "git switch -c my-new-branch 2>&1" to contain "nuggit: MyFirstBranch"
redeem_nuggit MyFirstBranch
expect "git switch history -q" to succeed
'

it 'LogCat for log' <<EOF
expect 'eval "\$(get_sh_codeblock log.md)"' to contain "nuggit: LogCat"
redeem_nuggit LogCat
EOF

it 'AnnotateMeIfYouCan in annotated tag' '
expect "git show the-first-tag" to contain "nuggit: AnnotateMeIfYouCan"
redeem_nuggit AnnotateMeIfYouCan
expect "git switch --detach -q the-first-tag" to succeed
'

xit 'TODO: find title for combine_history testcase' <<EOF
expect 'eval "\$(get_sh_codeblock combine_history.md)"' to contain "FIXME TODO"
EOF

it 'An invalid nuggit should show an error' '
expect "! git redeem-nuggit NotANuggit 2>&1" to contain "Unfortunately that is not a valid nuggit"
expect "! git redeem-nuggit NotANuggit 2>&1" to contain "It still isn'\''t a valid answer..."
expect "! git redeem-nuggit NotANuggit 2>&1" to contain "It still isn'\''t a valid answer..."
'

it 'CuriosityKilledTheCat in redeem script' '
expect "cat .git/redeem.nuggit" to contain CuriosityKilledTheCat
redeem_nuggit CuriosityKilledTheCat
'

check_redeem() {
    while read -r nuggit; do
        expect "git redeem-nuggit '$nuggit'" to contain "You have found all the little nuggits?! Very impressive!"
        expect "git redeem-nuggit '$nuggit'" to contain "already redeemed"
        expect "git redeem-nuggit '$nuggit'" not to contain Success
    done < "$DOCDIR/nuggits"
}

it 'All nuggits should be redeemed at the end of the test' check_redeem

echo success!
