#!/usr/bin/env bash

set -e

. ./lib.sh

cd challenge

echo 'LocalCodeExecution flag in hooks'
grep --quiet "# Flag: LocalCodeExecution" .git/hooks/pre-auto-gc
grep --quiet "^exit 1" .git/hooks/pre-auto-gc
echo 'LocalCodeExecution flag should be deleted after execution of the hook'
# git gc --auto # <- not executing the script?
git hook run pre-auto-gc
if ! [[ $(grep -L "# Flag: LocalCodeExecution" .git/hooks/*) ]]; then
    error "Selfdeleting flag was not removed after execution..."
    exit 1
fi

echo success!
