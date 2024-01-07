#!/bin/sh

# Mac sed has a different format for -i, so manually replace that file
# hack: just replace "pick" with "fixup" until line 1000 (which does not exist), but I can't be bothered to find a nicer way not to change the first line...
sed '2,1000s/^pick/fixup/' < "$1" > "$1.bak"
mv "$1.bak" "$1"
