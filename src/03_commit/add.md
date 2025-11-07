nuggit: DifferenceEngine

# Adding changes

Since you might be working on multiple things in parallel and it would not be very comprehensible to include all changes at once, you can tell git specifically what you want included in the next snapshot.

This can be done with

```sh
git add first-steps-with-git.md
```

which will "stage" the changes in the file README.md the next commit (meaning git will include those changes, all unstaged changes will not be included in the commit). If you simply run
