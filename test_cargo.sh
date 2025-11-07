#!/usr/bin/env bash

set -e

: "${verbose:=0}"
: "${destination:=tutorial}"

. ./lib.sh

parse_opts "$@"

. ./test_helpers/lib-test.sh
build_challenge() {
    echo "Building challenge..."
    if [[ -n "$test_remote" ]]; then
        rm -rf tutorial tutorial.tar tutorial.zip "$destination"
        curl https://nuggit.lohmann.sh/tutorial.zip --output tutorial.zip
        unzip tutorial.zip
        tar --extract --file=tutorial.tar
        if [[ "$destination" != tutorial ]]; then
            mv tutorial "$destination"
        fi
    else
        ./build_orig.sh --force
    fi
    cd "$destination"
    reproducibility_setup
}
build_challenge

if [[ -z "$skipCodeExecTests" ]]; then

check_redeem_without_local_code_execution() {
    while read -r line; do
        nuggit="$(printf "%s" "$line" | cut -d "	" -f 1)"
        [ "$nuggit" != LocalCodeExecution ] || continue
        [ "$nuggit" != TheStageIsYours ] || continue # we want to do this after all the others, so we see that this is the first time that the "You almost got it" text is shown
        expect "git nuggit redeem '$nuggit'" not to contain "You almost got it"
    done < "$DOCDIR/nuggits.tsv"
    # the second last nuggit should show the "Almost got it" text and resubmitting should show the same
    expect "git nuggit redeem TheStageIsYours" to contain "You almost got it! There is only a single nuggit left to redeem..."
    expect "git nuggit redeem TheStageIsYours" to contain "You almost got it! There is only a single nuggit left to redeem..."
}

it 'LocalCodeExecution should be nonexistent/unredeamable after the trap got triggered' <<EOF
expect "\$(get_sh_codeblock README.md)" to succeed
expect 'git commit -am "Just a test to trigger hooks" 2>/dev/null' to succeed
expect "git nuggit redeem LocalCodeExecution" error to contain "Unfortunately that is not a valid nuggit"
check_redeem_without_local_code_execution
EOF

extract_chapter_number() {
    git nuggit skip-to-chapter <<< q | sed -r "s/([0-9]+)\\)\t$1/\\1/gp;d"
}

it 'git nuggit skip-to-chapter should work' <<EOF
expect 'git nuggit skip-to-chapter <<< "\$(extract_chapter_number branches)" 2>&1' to succeed
expect '[ -f branch.md ]' to succeed
expect 'git nuggit skip-to-chapter <<< "\$(extract_chapter_number "push\\/pull")" 2>&1' to succeed
expect "git push 2>&1" to succeed
expect 'git nuggit skip-to-chapter <<< "\$(extract_chapter_number log)" 2>&1' to succeed
expect '[ -f log.md ]' to succeed
expect 'git nuggit skip-to-chapter <<< "\$(extract_chapter_number cherry-pick)" 2>&1' to succeed
expect '[ -f cherry-pick.md ]' to succeed
EOF

cd ..
build_challenge
fi
echo "Running tests..."

redeem_nuggit() {
    expect "git nuggit redeem '$1'" to contain Success
}

it 'ReadTheDocs should start the game' <<EOF
expect "[ -e first-steps-with-git.md ]" not to succeed
expect "cat README.md" to contain "nuggit: ReadTheDocs"
expect "\$(get_sh_codeblock README.md)" to succeed
expect "git show nuggits" to contain "ReadTheDocs"
expect "[ -e first-steps-with-git.md ]" to succeed
EOF

it 'LocalCodeExecution nuggit in hooks' '
expect "cat .git/hooks/*" to contain "nuggit: LocalCodeExecution"
redeem_nuggit LocalCodeExecution
'

it 'chapter diff --staged' '
diff_staged_commit_command="$(get_sh_codeblock first-steps-with-git.md)"
expect "$diff_staged_commit_command" to contain "nuggit: TheStageIsYours"
redeem_nuggit TheStageIsYours
'

it 'chapter commit' '
expect "GIT_EDITOR="cat" git commit" to succeed
expect "git show" to contain "nuggit: BigCommitment"
redeem_nuggit BigCommitment
'
########################

it 'chapter diff' '
diff_command="$(get_sh_codeblock <(git log --pretty=%B @~...))"
expect "$diff_command" to contain "nuggit: DifferenceEngine"
redeem_nuggit DifferenceEngine
'

it 'chapter add' '
add_command="$(get_sh_codeblock <(git diff | sed "s/^.\{1\}//"))"
expect "$add_command" error to contain "nuggit: AddTheTopOfYourGame"
redeem_nuggit AddTheTopOfYourGame
'

it 'LocalCodeExecution nuggit should be deleted after execution of any hook (in this case `git add`)' '
expect "cat .git/hooks/*" not to contain "nuggit: LocalCodeExecution"
'

it 'restore should not show Switcheridoo nuggit' '
expect "git restore first-steps-with-git.md" error not to contain "nuggit: Switcheridoo"
'

it 'chapter commit short message' <<EOF
commit_message_output="\$(git commit -m "My first commit" 2>&1)"
expect "echo '\$commit_message_output'" to contain "nuggit: ShortMessageService"
redeem_nuggit ShortMessageService
EOF

it 'chapter diff commit' <<EOF
diff_absolute_command="\$(get_sh_codeblock <(echo "\$commit_message_output"))"
diff_absolute_output="\$(\$diff_absolute_command)"
expect 'echo "\$diff_absolute_output"' to contain "nuggit: AbsoluteDifferentiable"
redeem_nuggit AbsoluteDifferentiable
EOF

it 'chapter branches' <<EOF
show_cmd="\$(get_sh_codeblock <(echo "\$diff_absolute_output" | sed "s/^.//"))"
expect '\$show_cmd' to contain "nuggit: ShowMeMore"
redeem_nuggit ShowMeMore
EOF

it 'chapter working with branches' '
expect "git switch branches-explained" error to contain "nuggit: Switcheridoo"
redeem_nuggit Switcheridoo
'

it 'MyFirstBranch when creating new branch' '
expect "git switch -c my-new-branch" error to contain "nuggit: MyFirstBranch"
redeem_nuggit MyFirstBranch
'

it 'chapter upstream' '
expect "git switch -q working-with-others" to succeed
diffu_cmd="$(get_sh_codeblock working-with-others.md)"
expect "$diffu_cmd" to contain "nuggit: WhereIsTheLiveStream"
redeem_nuggit WhereIsTheLiveStream
'

cargo test -- --nocapture

it 'An invalid nuggit should show an error' '
expect "git nuggit redeem NotANuggit" error to contain "Unfortunately that is not a valid nuggit"
expect "git nuggit redeem NotANuggit" error to contain "It still isn'\''t a valid answer..."
expect "git nuggit redeem NotANuggit" error to contain "It still isn'\''t a valid answer..."
'

it 'CuriosityKilledTheCat in redeem script' '
expect "cat .git/redeem.nuggit" to contain CuriosityKilledTheCat
redeem_nuggit CuriosityKilledTheCat
'

check_redeem() {
    expect "git nuggit redeem ThisWasATriumph" to contain "You have found all the little nuggits?! Very impressive!"
    while read -r line; do
        nuggit="$(printf "%s" "$line" | cut -d "	" -f 1)"
        redeem_out="$(git nuggit redeem "$nuggit" || :)"
        expect "echo '$redeem_out'" to contain "already redeemed"
        expect "echo '$redeem_out'" not to contain Success
        expect "git log --oneline nuggits" to contain "$nuggit"
    done < "$DOCDIR/nuggits.tsv"
}

it 'All nuggits should be redeemed at the end of the test' check_redeem

echo success!
