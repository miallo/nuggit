# Commit

A "commit" is snapshot of the project with some metadata like a time stamp, a commit message describing the changes and the "parent commit(s)", i.e. what the previous state was that this change was based on.

## How to create a commit

To commit changes, first you need to tell git what to add, e.g. `git add README.md` - this will "stage" all changes for the next commit (meaning git will include those changes, all unstaged changes will not be included in the commit). If you simply run `git commit` it will open an editor for the commit message (by default the one set in your terminal in the variable EDITOR, or it will default to `vim`). `vim` is a nice, but for beginners a bit complex editor - if you don't feel at home (yet) in the commandline, you can (once) set another one like e.g. `nano` with `git config core.editor nano` (or search on the web for "git config core.editor <name of your editor>" to see how to set up yours).

If you want to commit all the changes, you can skip the separate `git add` and run `git commit -a` (short for `--all`), which will automatically stage all changes in "tracked files" (files that git previously had under its version controll) for you before the commit.

## How to show a commit

An alternative view that git often shows to you for a commit is the dynamically calculated "diff" to the previous commit, so only the changes. For most day-to-day uses this might be a good impression, but keep in mind that it is not what happens in reality.

A commit can be addressed by a "hash". That is a seemingly random string of numbers and letters from a-f (hexadecimal numbers). The full length of a hash is 40 characters, but it can be truncated, as long as it is unique. That means that in many places 8-10 characters are enough.

To view the commit message and diff for a commit there exists the command `git show`. By default it will show the last commit, but you can also show a specific one like this:
```sh
git show c3e18a3e94
```
