#!/usr/bin/env bash
# Flag: LocalCodeExecution
# Congrats on finding this! This flag is gonna destroy itself when any of the hooks are executed ;)
shopt -s extglob
ROOT="$(git rev-parse --show-toplevel)"

this_file="$0"

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