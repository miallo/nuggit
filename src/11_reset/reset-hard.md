# Reset your changes

`git reset` is a command used in Git to undo changes in your repository. It can modify the staging area and the working directory, allowing you to revert to a previous commit. There are three main modes: *soft*, which keeps changes in the staging area; *mixed*, which unstages changes but keeps them in the working directory; and *hard*, which discards all changes and resets the working directory to the specified commit.

You can use this to point the branch you have checked out to a different commit like:
```sh
git reset --hard CHAPTER_RESET_HARD_FOLLOW
```

But be careful! This can delete changes you have made in a way that not even git can restore them!

Usually you would do this e.g. if you have a commit with some changes which you later figure out you don't need. Or another situation I find myself using it is when I run `git fetch` and figure out a coworker already found a better solution to what I have been working on.
