#!/usr/bin/env bash

set -e

: "${verbose:=0}"
: "${destination:=tutorial}"

. ./lib.sh

parse_opts "$@"

. ./test_helpers/lib-test.sh
build_challenge() {
    echo "Building challenge..."
    ./build.sh --force
    cd "$destination"
    reproducibility_setup
}
build_challenge

check_redeem_without_local_code_execution() {
    while read -r line; do
        nuggit="$(printf "%s" "$line" | cut -d "	" -f 1)"
        [ "$nuggit" != LocalCodeExecution ] || continue
        [ "$nuggit" != WorkInProgress ] || continue # we want to do this after all the others, so we see that this is the first time that the "You almost got it" text is shown
        expect "git redeem-nuggit '$nuggit'" not to contain "You almost got it"
    done < "$DOCDIR/nuggits.tsv"
    # the second last nuggit should show the "Almost got it" text and resubmitting should show the same
    expect "git redeem-nuggit WorkInProgress" to contain "You almost got it! There is only a single nuggit left to redeem..."
    expect "git redeem-nuggit WorkInProgress" to contain "You almost got it! There is only a single nuggit left to redeem..."
}

it 'LocalCodeExecution should be nonexistent/unredeamable after the trap got triggered' '
expect "git commit -am \"Just a test to trigger hooks\"" to succeed
expect "! git redeem-nuggit LocalCodeExecution 2>&1" to contain "Unfortunately that is not a valid nuggit"
check_redeem_without_local_code_execution
'

extract_chapter_number() {
    git skip-to-nuggit-chapter <<< q | sed -r "s/([0-9]+)\\)\t$1/\\1/gp;d"
}

it 'git skip-to-nuggit-chapter should work' <<EOF
expect 'git skip-to-nuggit-chapter <<< "\$(extract_chapter_number branches)" 2>&1' to succeed
expect '[ -f branch.md ]' to succeed
expect 'git skip-to-nuggit-chapter <<< "\$(extract_chapter_number "push\\/pull")" 2>&1' to succeed
expect "git push 2>&1" to succeed
expect 'git skip-to-nuggit-chapter <<< "\$(extract_chapter_number log)" 2>&1' to succeed
expect '[ -f log.md ]' to succeed
expect 'git skip-to-nuggit-chapter <<< "\$(extract_chapter_number cherry-pick)" 2>&1' to succeed
expect '[ -f cherry-pick.md ]' to succeed
EOF

cd ..
build_challenge
echo "Running tests..."

redeem_nuggit() {
    expect "git redeem-nuggit '$1'" to contain Success
    expect "git show nuggits" to contain "$1"
}

it 'LocalCodeExecution nuggit in hooks' '
expect "cat .git/hooks/*" to contain "nuggit: LocalCodeExecution"
redeem_nuggit LocalCodeExecution
'

it 'chapter diff --staged' '
expect "git diff --staged" to contain "nuggit: CommitmentIssues"
redeem_nuggit CommitmentIssues
'

it 'chapter diff' '
expect "git diff" to contain "nuggit: WorkInProgress"
redeem_nuggit WorkInProgress
'

it 'chapter diff <commit>' '
diff_commit_command="$(get_sh_codeblock <(git diff --staged | cut -c 2-))"
expect "$diff_commit_command" to contain "nuggit: AbsoluteDifferentiable"
redeem_nuggit AbsoluteDifferentiable
'

it 'chapter commit' '
expect "git commit -m \"My first commit\"" to succeed
expect "git show" to contain "nuggit: BigCommitment"
redeem_nuggit BigCommitment
'

it 'LocalCodeExecution nuggit should be deleted after execution of any hook (in this case the commit)' '
expect "cat .git/hooks/*" not to contain "nuggit: LocalCodeExecution"
'

it 'restore should not show Switcheridoo nuggit' '
expect "git restore first-steps-with-git.md 2>&1" not to contain "nuggit: Switcheridoo"
'

it 'chapter branches' <<EOF
expect 'eval "\$(get_sh_codeblock <(\$diff_commit_command | cut -c 2-))"' to contain "nuggit: ShowMeMore"
redeem_nuggit ShowMeMore
EOF

it 'chapter working with branches' '
expect "git switch branches-explained 2>&1" to contain "nuggit: Switcheridoo"
redeem_nuggit Switcheridoo
'

it 'MyFirstBranch when creating new branch' '
expect "git switch -c my-new-branch 2>&1" to contain "nuggit: MyFirstBranch"
redeem_nuggit MyFirstBranch
'

it 'chapter push' '
expect "git switch -q working-with-others" to succeed
expect "git push 2>&1" to contain "nuggit: PushItToTheLimits"
redeem_nuggit PushItToTheLimits
'

it 'chapter pull' '
expect "! git switch history -q 2>&1" to succeed
expect "git pull 2>&1" to succeed
expect "cat working-with-others.md" to contain "nuggit: PullMeUnder"
redeem_nuggit PullMeUnder
'

it 'chapter log' <<EOF
expect "git switch history -q" to succeed
expect 'eval "\$(get_sh_codeblock log.md)"' to contain "nuggit: LogCat"
redeem_nuggit LogCat
EOF

it 'chapter tag' '
expect "git show the-first-tag" to contain "nuggit: AnnotateMeIfYouCan"
redeem_nuggit AnnotateMeIfYouCan
expect "git switch --detach -q the-first-tag" to succeed
'

it 'chapter rebase' <<EOF
# do a rebase
expect 'eval "\$(get_sh_codeblock combine_history.md)" 2>&1' to contain "nuggit: ItsAllAboutTheRebase"
redeem_nuggit ItsAllAboutTheRebase
EOF

it 'chapter interactive rebase' <<EOF
expect 'GIT_SEQUENCE_EDITOR="$DOCDIR/../test_helpers/interactive-rebase-sequence-editor.sh" eval "\$(get_sh_codeblock interactive-rebase.md)" 2>&1' to succeed
EOF

it 'chapter cherry-pick' <<EOF
expect 'cat cherry-pick.md' to contain "nuggit: YoureACherryBlossom"
redeem_nuggit YoureACherryBlossom
expect 'eval "\$(get_sh_codeblock cherry-pick.md)"' to succeed
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

it 'ThisWasATripmph shown in end chapter' '
expect "cat success.md" to contain "nuggit: ThisWasATriumph"
redeem_nuggit ThisWasATriumph
'

check_redeem() {
    while read -r line; do
        nuggit="$(printf "%s" "$line" | cut -d "	" -f 1)"
        expect "git redeem-nuggit '$nuggit'" to contain "You have found all the little nuggits?! Very impressive!"
        expect "git redeem-nuggit '$nuggit'" to contain "already redeemed"
        expect "git redeem-nuggit '$nuggit'" not to contain Success
        expect "git log nuggits" to contain "$nuggit"
    done < "$DOCDIR/nuggits.tsv"
}

it 'All nuggits should be redeemed at the end of the test' check_redeem

echo success!
