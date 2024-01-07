#!/usr/bin/env bash

. "$DOCDIR/redeem.nuggit" >/dev/null 2>&1

while read -r nuggit; do
    printf "%s \t" "$nuggit"
    success "$nuggit" | git hash-object --stdin -w
done < "$DOCDIR/nuggits"
