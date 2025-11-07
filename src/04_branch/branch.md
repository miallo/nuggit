# Branches

A branch is a way in git to work on different features of a project in parallel. That way you can work on something until it's finished.

In practise a branch in git is nothing more than a human readable label that points to a commit and if you commit while being on a branch that pointer will automatically be updated for you.
You can check out what a branch really is for git: it is just a file with a hash. You can view it with whatever editor you use or just display the content with `cat .git/refs/heads/branches-explained` for the branch `"branches-explained"`.

To switch to a branch you can e.g. run

```sh
git switch branches-explained
```

when you want to work on that feature.
