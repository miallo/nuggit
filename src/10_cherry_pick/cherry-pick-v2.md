nuggit: YoureACherryBlossom

# Cherry-Picking

If you don't want to take all the changes from a branch, but only want a specific commit (i.e. you are very selective about the changes you want to have), you can run

```sh
git cherry-pick <TODO: add example commit hash>
```

But sometimes there are changes with different commits in the same vacinity where git doesn't know how to resolve them automatically. This is called a _merge conflict_ (no matter if you are doing a merge, rebase, cherry-pick or revert).

You can either manually inspect and fix the conflict, or restore the file in the state of the commit you are trying to apply:

```sh
git restore --theirs cherry-pick.md
```

(to undo the changes in the file from the commit that is trying to be applied right now, exchange the `--theirs` with `--ours`)
