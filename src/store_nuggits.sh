#!/usr/bin/env bash

set -e

# To avoid the player just running
# `git fsck --dangling | cut -d " " -f3 | xargs -n 1 git cat-file -p`
# to grep all the nuggits we don't store them in clear-text, but we store the hash of them.
# That way we know that we should get the object if we just hash the input twice, but
# the object themselves is just a hash that is not readable.
while read -r line; do
    nuggit="$(printf "%s" "$line" | cut -d "	" -f 1)"
    nuggit_hash="$(echo "$nuggit" | git hash-object --stdin)"

    nuggit_description="$(printf "%s" "$line" | cut -d "	" -f 2-)"
    END_BLOB_HASH="$(git hash-object -w --stdin <<< "$nuggit_description")"
    printf "100644 blob %s	%s\n" "$END_BLOB_HASH" "$nuggit_hash" >> nuggit_description_tree_tmp

    printf "%s \t" "$nuggit"
    echo "$nuggit" | git hash-object --stdin | git hash-object --stdin -w
done < "$DOCDIR/nuggits"

NUGGIT_DESCRIPTION_TREE="$(git mktree < nuggit_description_tree_tmp)"
rm nuggit_description_tree_tmp
export NUGGIT_DESCRIPTION_TREE
