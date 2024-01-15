# Cherry-Picking

nuggit: YoureACherryBlossom

If you don't want to take all the changes from a branch, but only want a specific commit (i.e. you are very selective about the changes you want to have), you can run
```sh
git cherry-pick CHAPTER_CHERRY_PICK_FOLLOW
```
It will apply the changes that were introduced by that commit (so in this sense it makes a commit not feel like a snapshot of the program, but a diff to the previous one).
