#!/usr/bin/env bash

echo "You have found $(( "$(git rev-list --count nuggits)" - 1)) of NUMBER_OF_NUGGITS nuggits"
