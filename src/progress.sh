#!/usr/bin/env bash

echo "You have found $(( $(git rev-list --count nuggits) - 1)) of NUMBER_OF_NUGGITS nuggits"

# The first nuggit is the RootOfAllNuggits
if [[ $(git rev-list --count nuggits) -gt 1 ]]; then
    printf "You redeemed your first nuggit %s 😃\n" "$(git log --pretty="%cr" --reverse nuggits | sed -n '2{p;q;}')"
fi
