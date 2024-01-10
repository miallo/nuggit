When you run
```sh
git rebase -i INTERACTIVE_REBASE_BASE_COMMIT
```
(or `--interactive`), an editor will open, showing a list of all the commits that would be applied.

CAREFUL: in contrast to the output of `git log` where the newest commit is at the top, in this list the last commit is at the bottom!

The output starts with a block of lines that look like this:
```
INTERACTIVE_REBASE_EXAMPLE_PICKS
```
But what does this mean? Fortunately at the bottom of the file it shows a short summary on all the possible commands.

In short: when you just save and quit, it will be exactly as a normal rebase. But if you change the

TODO: TODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODOTODO
