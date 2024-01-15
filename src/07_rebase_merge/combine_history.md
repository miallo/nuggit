# Combine the works of two branches

If you have been working on a feature branch and there were new commits on the main branch in the meanwhile you need to somehow combine the works.
There are two schools of thought working with git:
- preserve the history at all costs ("merge")
- have a clean history that is easy to review and does not have artifacts like incomplete patches in a single commit ("rebase")

## Rebase

Rebasing means taking the commits in your branch (or to be more precise in the language: taking all commits from the merge-base aka. "last common ancestor" to the commit you rebase onto) and automatically replaying your changes ("applying the patches") one by one (technically there are two versions of a rebase, but that is for later...). `git` will try its best to do that automatically for you, but it can run into _conflicts_ if changes are made in the same line (or very close to another) on both branches (see below)

Since a commit consists not only of the diff, but is a complete snapshot of the repository at that time and also it has additional meta data like the parent commit and the commit date, the rebased commits might at a glance look the same to you, but they will have a different hash.

So to sum it up: with the rebase-workflow the end result will look like you had the changes from the main branch all along while working on the feature, which makes it a lot easier to understand what changed when and why, because you don't have to mentally keep track of all commits in the branches that were eventually merged at the same time, but can step through the history one by one. This comes at the cost of having to retroactively "rewrite the history".

Suppose you want to get all the changes from the commit CHAPTER_REBASE_FOLLOW, then you would run:
```sh
git rebase CHAPTER_REBASE_FOLLOW
```

Another benefit of rebases is that the history of the branches can be cleaned up retroactively (e.g. when you want to safe snapshots of the code while developing, even though it is not completely functional yet, or it works, but after you implemented it you have ideas on how to refactor it).
**TODO:** _finish doc on interactive rebases and refere to that here..._

## Merge

Another approach with git is to keep the commits as they are and instead merge the branches.
Meaning to create a new commit containing the changes of the other branch and with a reference on that branch (or more specifically the commit the branch is on at that point). This has the benefit of a "stable history" with the drawback that afterwards every single step will forever be recorded (including your `git commit -m "WIP - still not working but now for a lunchbreak"`).

Especially in long lived branches it can become almost impossible to track what actually changed and why, because you might be merging in changes quite often, mixed with your own changes.

# Conflicts

No matter if you rebase or merge, `git` can only try its best to figure out how to combine the changes automatically for you. What it does is that it looks at the "context" (the surrounding lines of the ones that changed) and try to find them. If the line you worked on (or the context) changed, then git does not know how you want to do it and you will run into a so called "merge conflict" (yes, it is also named that for rebases for reasons we will go into later). At that point, the merge/rebase will stop and in the file you will see things like

Suppose previously there was the text
```
Rebases are prefered because
they are simply better than merges.
```
and your college changed it in the main branch to
```
Rebases are prefered because
they are easier to review.
```
and in your branch you changed it to
```
Rebases are prefered because
they allow cleaning up your work in progress steps.
```
then the resulting conflict would look like
```
Rebases are prefered because
<<<<<<< HEAD
they are easier to review.
=======
they allow cleaning up your work in progress steps.
>>>>>>> branch-a
```

Now you would take a look at it and change it maybe to
```
Rebases are prefered because
they allow cleaning up your work in progress steps and are easier to review.
```
to keep both his and your changes. After saving the file you tell git that you have resolved the conflict with `git add <filename>` and then you can run `git rebase --continue` (or the same with `merge` if that is what you were doing).

NOTE: since git (in both rebases and merges) only looks at the plain text and does not have an understanding on what you are actually working on (is it just plain text or code), you might NOT get a merge conflict with the result still being unusable, e.g. if in the main branch a variable gets renamed and in your branch you are still using the old name, but not anywhere close to other previous uses of it. Then rebase/merge would succeed with your path still using the old variable, but the result would not work. So you have to be careful with either, especially when refactoring code and in parallel changing it in a separate branch ;) There are tools included in git that can be helpful for this situation - but that is for later...
