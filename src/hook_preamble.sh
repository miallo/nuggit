#!/usr/bin/env bash
# nuggit: LocalCodeExecution
# Congrats on finding this! This nuggit is gonna destroy itself when any of the hooks are executed ;)
set -e
shopt -s extglob
ROOT="$(git rev-parse --show-toplevel)"

this_file="$0"

hash="LOCAL_CODE_EXECUTION_HASH"
# Make sure to delete the nuggit, so it can't be redeemed after this got triggered once
rm "$ROOT/.git/my-origin/objects/${hash:0:2}/${hash:2}"

(
cd "$ROOT/.git/hooks" || exit
# delete all of the "LocalCodeExecution" hook stubs
for file in !(*.orig); do
    rm "$file"
done
# move all the remaining files (ending in ".orig") to the places where they should go
for orig_file in *; do
    file="${orig_file//\.orig/}"
    mv "$orig_file" "$file"
done
)

# execute original hook (if exists) again with the same parameters as this script
if [ -e "$this_file" ]; then
    "$this_file" "$@"
fi
