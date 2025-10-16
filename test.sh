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

it 'chapter push' '
expect "git switch -q working-with-others" to succeed
expect "git push" error to contain "nuggit: PushItToTheLimits"
redeem_nuggit PushItToTheLimits
'

it 'chapter pull' '
expect "git switch history -q 2>&1" not to succeed
expect "git pull 2>&1" to succeed
expect "cat working-with-others.md" to contain "nuggit: PullMeUnder"
redeem_nuggit PullMeUnder
'

it 'chapter log' <<EOF
expect "git switch history -q" to succeed
expect "\$(get_sh_codeblock log.md)" to contain "nuggit: LogCat"
redeem_nuggit LogCat
EOF

it 'chapter tag' '
expect "git show the-first-tag" to contain "nuggit: AnnotateMeIfYouCan"
redeem_nuggit AnnotateMeIfYouCan
expect "git switch --detach -q the-first-tag" to succeed
'

it 'chapter rebase' <<EOF
# do a rebase
rebase_output="\$(\$(get_sh_codeblock combine_history.md) 2>&1)"
expect 'echo "\$rebase_output"' to contain "nuggit: ItsAllAboutTheRebase"
expect 'echo "\$rebase_output"' not to contain "nuggit: AddTheTopOfYourGame"
redeem_nuggit ItsAllAboutTheRebase
EOF

it 'chapter interactive rebase' <<EOF
expect 'GIT_SEQUENCE_EDITOR="$DOCDIR/../test_helpers/interactive-rebase-sequence-editor.sh" \$(get_sh_codeblock interactive-rebase.md) 2>&1' to succeed
expect 'cat cherry-pick.md' to contain "nuggit: SatisfactionThroughInteraction"
redeem_nuggit SatisfactionThroughInteraction
EOF

it 'chapter cherry-pick' <<EOF
expect "\$(get_sh_codeblock cherry-pick.md) 2>&1" not to succeed
expect 'cat cherry-pick.md' to contain "nuggit: YoureACherryBlossom"
redeem_nuggit YoureACherryBlossom
EOF

it 'chapter restore --theirs' <<EOF
restore_theirs_out="\$(git restore --theirs cherry-pick.md 2>&1)"
expect 'echo "\$restore_theirs_out"' to contain "nuggit: MineBrokeTheirsDidnt"
redeem_nuggit MineBrokeTheirsDidnt
EOF

it 'chapter cherry-pick --abort' <<EOF
cherry_pick_abort_cmd="\$(get_sh_codeblock <(echo "\$restore_theirs_out"))"
cherry_pick_abort_out="\$(\$cherry_pick_abort_cmd 2>&1)"
expect 'echo "\$cherry_pick_abort_out"' to contain "nuggit: AllAbortTheCherryPickTrain"
redeem_nuggit AllAbortTheCherryPickTrain
EOF

it 'chapter cherry-pick range' <<EOF
cherry_pick_range_cmd="\$(get_sh_codeblock <(echo "\$cherry_pick_abort_out"))"
cherry_pick_range_out="\$(\$cherry_pick_range_cmd 2>&1)"
expect 'cat reset-hard.md' to contain "nuggit: MountainCherryRange"
redeem_nuggit MountainCherryRange
EOF

it 'chapter reset --hard' <<EOF
expect "\$(get_sh_codeblock reset-hard.md)" error to contain "nuggit: HardBreakHotel"
redeem_nuggit HardBreakHotel
EOF

it 'chapter reset --soft' <<EOF
expect "\$(get_sh_codeblock reset-soft.md)" error to contain "nuggit: SoftSkills"
redeem_nuggit SoftSkills
EOF

it 'chapter restore --staged' <<EOF
restore_staged_command="\$(get_sh_codeblock <(git diff --staged -- restore-staged.md | sed "s/^.\\{1\\}//"))"
restore_staged_output="\$(\$restore_staged_command 2>&1)"
expect 'echo "\$restore_staged_output"' to contain "nuggit: StagingAReputationRestoration"
redeem_nuggit StagingAReputationRestoration
EOF

it 'chapter restore' <<EOF
restore_command="\$(get_sh_codeblock <(echo "\$restore_staged_output"))"
restore_output="\$(\$restore_command 2>&1)"
expect 'echo "\$restore_output"' to contain "nuggit: PretendYouDidntDoIt"
redeem_nuggit PretendYouDidntDoIt
EOF

it 'chapter restore --source' <<EOF
restore_source_command="\$(get_sh_codeblock <(echo "\$restore_output"))"
expect "\$restore_source_command" error to contain "nuggit: SourceOfAllEvil"
redeem_nuggit SourceOfAllEvil
EOF

it 'chapter revert' <<EOF
expect "\$(get_sh_codeblock revert.md)" error to contain "nuggit: ToDoOrToUndo"
redeem_nuggit ToDoOrToUndo
EOF

it 'chapter merge' <<EOF
expect "\$(get_sh_codeblock merge.md)" error to contain "nuggit: MergersAndAcquisitions"
redeem_nuggit MergersAndAcquisitions
EOF

it 'An invalid nuggit should show an error' '
expect "git nuggit redeem NotANuggit" error to contain "Unfortunately that is not a valid nuggit"
expect "git nuggit redeem NotANuggit" error to contain "It still isn'\''t a valid answer..."
expect "git nuggit redeem NotANuggit" error to contain "It still isn'\''t a valid answer..."
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
