#!/usr/bin/env bash
# This file is not really intended for you to look into too much - but I like how curious you are, so here is a nuggit for you: CuriosityKilledTheCat

nuggit="$1"

already_redeemed() {
    echo "'$1' already redeemed"
}

if [ -z "$nuggit" ]; then
    echo "no nuggit passed in..." >&2
    echo "Usage: \`$0 TestNuggit\`" >&2
    exit 1
fi

if [ "$nuggit" = TestNuggit ]; then
    echo "This is a test. You passed it! 👍"
    exit
fi

already_redeemed=0
git cat-file -e "$(already_redeemed "$nuggit" | git hash-object --stdin)" 2>/dev/null && already_redeemed=1
redeemed_nuggits="$(($(git rev-list --count nuggits) - already_redeemed))"

[ "$redeemed_nuggits" -ne $((NUMBER_OF_NUGGITS - 1)) ] || git cat-file -p CREDITS_TREE:almost;

# shellcheck disable=2170
[ "$redeemed_nuggits" -ne NUMBER_OF_NUGGITS ] || {
    git cat-file -e "$(git hash-object --stdin <<< "$((NUMBER_OF_NUGGITS - 1))" | git hash-object --stdin)" 2>/dev/null || { echo Noughty boy!; exit 1; }
    git cat-file -p CREDITS_TREE:final | tr 'A-Za-z' 'N-ZA-Mn-za-m';
}

git cat-file -p "$(already_redeemed "$nuggit" | git hash-object --stdin)" 2>/dev/null && exit
git cat-file -p "$(echo "You tried '$nuggit' before. It still isn't a valid answer... 🙄" | git hash-object --stdin)" 2>/dev/null && exit 1

git cat-file -p "NUGGIT_DESCRIPTION_TREE:$(echo "$nuggit" | git hash-object --stdin)/success" 2>/dev/null || {
    echo "Unfortunately that is not a valid nuggit :/ Try again!" >&2
    echo "You tried '$nuggit' before. It still isn't a valid answer... 🙄" | git hash-object --stdin -w >/dev/null 2>&1
    exit 1
}

commit_nuggit() { # Manage our own little "branch" manually
    local tree
    # get the tree object from the last commit in nuggits
    tree="$(git rev-parse "nuggits^{tree}")"
    description="$(git cat-file -p "NUGGIT_DESCRIPTION_TREE:$(echo "$1" | git hash-object --stdin)/description")"
    # add an empty commit with the parent being nuggits and "reset nuggits to that new commit"
    git commit-tree "$tree" -p "$(cat .git/nuggits)" -m "$1

$description" > .git/nuggits.bak
    # We can't directly pipe it into the file, because it will empty it before we read it...
    mv .git/nuggits.bak .git/nuggits
}
commit_nuggit "$nuggit"

echo "Number of redeemed nuggits: $redeemed_nuggits of NUMBER_OF_NUGGITS"
already_redeemed "$nuggit" | git hash-object --stdin -w >/dev/null 2>&1
git hash-object --stdin <<< "$redeemed_nuggits"| git hash-object --stdin -w >/dev/null 2>&1
