#!/usr/bin/env bash
#This file is not really intended for you to look into too much - but I like
#how curious you are, so here is a nuggit for you:
#nuggit: CuriosityKilledTheCat
#
#Note for developers: comments starting with "#<space>" and empty lines are
#stripped from the build version to make reverse engineering this just a tiny
#bit harder ;)

nuggit="$1"

if [ -z "$nuggit" ]; then
    echo "no nuggit passed in..." >&2
    echo "Usage: \`$0 TestNuggit\`" >&2
    exit 1
fi

if [ "$nuggit" = TestNuggit ]; then
    echo "This is a test. You passed it! 👍"
    exit
fi

already_redeemed="'$nuggit' already redeemed"
tried_before="You tried '$nuggit' before. It still isn't a valid answer... 🙄"

# A helper function to write to the remote git objects
# This is done, because:
# a) we don't want to "pollute" the local objects, since we eventually want to
#    also teach the player about that and it would only be noise
# b) it makes it just a tiny bit harder to discover the nuggits
hash_object_write() {
    GIT_DIR=.git/my-origin git hash-object --stdin -w >/dev/null 2>&1
}
# A helper function to read from to the remote git objects
catfile() {
    GIT_DIR=.git/my-origin git cat-file "$@"
}

redeemed=0
# check if this nuggit was already_redeemed
catfile -e "$(echo "$already_redeemed" | git hash-object --stdin)" 2>/dev/null && redeemed=1
# The total number of nuggits is one bigger than the already committed ones
# because of the root commit, so we have to subtract 1 if this one was already
# redeemed
redeemed_nuggits="$(($(git rev-list --count nuggits) - redeemed))"

# For the second last nuggit we want to show a hint that one is still missing
# to give a hint that LocalCodeExecution is self-deleting.
# CREDITS_TREE is a tree-object and CREDITS_TREE:almost means the blob with the
# name "almost" inside of it
[ "$redeemed_nuggits" -ne $((NUMBER_OF_NUGGITS - 1)) ] || catfile -p CREDITS_TREE:almost;

# shellcheck disable=2170 # NUMBER_OF_NUGGITS will be replaced by an integer, once we "build" it.
[ "$redeemed_nuggits" -ne NUMBER_OF_NUGGITS ] || {
    # check if the player did not just add a commit to our "nuggits"
    # pseudobranch by looking up if we wrote the last number of redeemed
    # nuggits to the objects. This is just a very basic "cheat-detection"...
    catfile -e "$(git hash-object --stdin <<< "$((NUMBER_OF_NUGGITS - 1))" | git hash-object --stdin)" 2>/dev/null || { echo Naughty boy!; exit 1; }
    # print the final credits. See "almost" above for syntax description
    # Also do rot13 on the result in order to make it just a bit harder to just
    # find the blob and read it
    catfile -p CREDITS_TREE:final | tr 'A-Za-z' 'N-ZA-Mn-za-m';
}

# if we already have redeemed this nuggit, print that it was already redeemed and exit
catfile -p "$(echo "$already_redeemed" | git hash-object --stdin)" 2>/dev/null && exit
# if the user already tried to submit this wrong string, print the error and exit
catfile -p "$(echo "$tried_before" | git hash-object --stdin)" 2>/dev/null && exit 1

# Print the success message for this nuggit if it exists
catfile -p "NUGGIT_DESCRIPTION_TREE:$(echo "$nuggit" | git hash-object --stdin)/success" 2>/dev/null || {
    # if it does not exist, then this is not a valid nuggit (or it was
    # LocalCodeExecution and that was deleted)
    echo "Unfortunately that is not a valid nuggit :/ Try again!" >&2
    echo "$tried_before" | hash_object_write >/dev/null 2>&1
    exit 1
}

# Manage our own little "branch" manually

# get the tree object from the last commit in nuggits
tree="$(git rev-parse "nuggits^{tree}")"
# get the description from our "nuggit tree object" from the folder with
# the hash of the nuggit and inside of that the description file
description="$(catfile -p "NUGGIT_DESCRIPTION_TREE:$(echo "$nuggit" | git hash-object --stdin)/description")"
# add an empty commit with the parent being nuggits and "reset nuggits to that new commit"
git commit-tree "$tree" -p "$(cat .git/nuggits)" -m "$(printf "%s\n\n" "$nuggit" "$description")" > .git/nuggits.bak
# Manually update reflog for our "branch" to avoid dangling commits
printf "%s %s	commit: %s\n" "$(cat .git/nuggits)" "$(git show --format="%H %cn <%cE> %ct -0000" nuggits.bak)" "$nuggit" >> .git/logs/nuggits
# We can't directly pipe it into the file, because it will empty it before we read it...
# Therefore write it into a backup file and then replace it
mv .git/nuggits.bak .git/nuggits # update our "branch"

# Print some stats for the player, so they know if they still need to look for other nuggits
echo "Number of redeemed nuggits: $redeemed_nuggits of NUMBER_OF_NUGGITS"
# Write to our database, that this nuggit is now redeemed
echo "$already_redeemed" | hash_object_write
# Write as a "cheat-detection" for the final credits how many we have redeemed
git hash-object --stdin <<< "$redeemed_nuggits"| hash_object_write
