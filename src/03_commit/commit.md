nuggit: TheStageIsYours

# Commit

A "commit" is snapshot of the project with some metadata like a time stamp, a commit message describing the changes and the "parent commit(s)", i.e. what the previous state was that this change was based on.

## How to create a commit

To commit changes you have staged before, simply run
```sh
git commit
```
which will prompt you for a commit message (a description for the changes) in an editor (by default the one set in your terminal in the variable EDITOR, or it will default to `vim`). `vim` is an editor I love and use, but for beginners it might be a bit complex - if you don't feel at home (yet) in the commandline, you can set another one like e.g. `nano` with `git config core.editor nano` (or search on the web for "git config core.editor <name of your editor>" to see how to set up yours). This only has to be done once.

