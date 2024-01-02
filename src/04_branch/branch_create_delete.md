## Toggling between two branches

Sometimes you find yourself switching back and forth between two branches and it becomes tedious to always type the branch names, so there is a shortcut for it: instead of a branch name, you can simply write a `-` like: `git switch -`

## How to create a branch

To create a new branch from the commit you are currently on you can simply run `git switch -c my-new-branch` (short for `--create`). You can also create one based on a different commit (not the one you currently have checked out) by adding it (in this example the last commit on the main branch): `git switch main -c my-new-branch`.

## How to delete a branch

To delete a branch you can run `git branch -d my-new-branch` (short for `--delete`). That will not work if the branch has changes that are not merged yet (not in the main branch). In that case you need to add a `--force` (or `-f` for short) as well. Alternatively there is the shortcut `-D` that is the same as `--delete --force`.
