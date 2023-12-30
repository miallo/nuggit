#!/usr/bin/env bash

set -e
. ./lib.sh

if [ -e challenge ]; then
    warn "'challenge' already exists. moving to challenge2..."
    rm -rf challenge2
    mv challenge challenge2
fi

# initial setup

# TODO: figure out how to use --template="$DOCDIR/01_init"
git init --initial-branch=main challenge
cd challenge
reproducibility_setup

cp "$DOCDIR/01_init/"* .
git add .
commit -m "Initial Commit"


# hooks (should be installed last, since they are selfmutating and would be called e.g. by `git commit`)
rm .git/hooks/*
cp "$DOCDIR/hooks/"* .git/hooks/
