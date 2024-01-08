#!/usr/bin/env bash

# To avoid the player just running
# `git fsck --dangling | cut -d " " -f3 | xargs -n 1 git cat-file -p`
# to grep all the nuggits we don't store them in clear-text, but we store the hash of them.
# That way we know that we should get the object if we just hash the input twice, but
# the object themselves is just a hash that is not readable.
while read -r nuggit; do
    printf "%s \t" "$nuggit"
    echo "$nuggit" | git hash-object --stdin | git hash-object --stdin -w
done < "$DOCDIR/nuggits"
