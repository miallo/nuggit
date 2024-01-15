When you run
```sh
git rebase -i CHAPTER_INTERACTIVE_REBASE_FOLLOW
```
(or `--interactive`), an editor will open, showing a list of all the commits that would be applied.

CAREFUL: in contrast to the output of `git log` where the newest commit is at the top, in this list the last commit is at the bottom!

The output starts with a block of lines that look like this:
```
INTERACTIVE_REBASE_EXAMPLE_PICKS
```
But what does this mean? Fortunately at the bottom of the file it shows a short summary on all the possible commands.

In short: when you just save and quit, it will be exactly as a normal rebase. But with this version you can do more! None-exhaustive, but very useful:
- reorder commits by just swapping the lines
- "reword" a commit message: keep all the changes in code, but change the commit message (an editor will open with the old message, as soon as this line of the rebase todo is reached)
- "squash" or combine two (or more) commits into a single one:
    - put the lines with relevant commits directly below each other
    - keep the first commit "pick" (at least for the simple version - go wild if you know what you are doing 😉)
    - change the "pick" of the lines below of the commits you want to combine into the previous one to "squash"
    - When saving/quitting and so the interactive rebase starts it will open a text editor again, this time with all the commit messages one below the other. Feel free to combine them into a single meaningful one
- if you want the same as squashing, but you don't care about the commit message of this commit (e.g. you just fixed a bug that you want to squash into an older commit and you (read "I") are lazy and just type `git commit -am "fixi"`, because this commit is just a short-lived tool that enables the interactive rebase squashing), you can replace the "squash" with "fixup" and it won't leave you to remove the "fixi" from the combined commit message.
- "drop" commits: make them (and their changes!) disappear, e.g. if I have a branch with multiple unrelated changes and want to hand them in meaningful chunks to review, I tend to:
    - first create a new branch with all the changed
    - do an interactive rebase and kick out all the not needed commits
    CAREFUL: an alternative to replacing the "pick" with a "drop" is just to delete the line! This can accidentally happen (or intentionally because in my editor it is faster than replacing the "pick" 😅)
- "edit": Allows you to add new changes to a previous commit (TODO: explain amending)

git actually only cares about the action (e.g. "pick") and the following commit hash. The commit message in the end is just for decoration. Changing it in the "todo file" does nothing to the commit - use "reword" instead.

Also note: there is a shorthand notation for all (documented) actions, so e.g. "f" for "fixup"
