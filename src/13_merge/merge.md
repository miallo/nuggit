# Workflow with keeping all history

If you prefer to keep history exactly as it played out, you can use a "merge" workflow. So far we have used rebases to "lie" that we did all our work chronologically. This is far easier to understand when you have to review or want to look at how features where built, but it requires rewriting the history. In that rebase case before a merge you want to make every commit as good and precise as possible at the cost of modifying them after you did them.

Some teams want to keep all stages of developing a feature, including all the failed attempts, rewrites and lunch break commits. This can be valuable e.g. if you want to merge multiple commits and run into merge conflicts. With the rebase based workflow you have to resolve conflicts in every commit (making them easier to read afterwards, but possibly a lot more conflicts), whereas in a merge based workflow you only have to resolve them once.

To merge the changes of a different branch/commit, run:
```sh
git merge CHAPTER_MERGE_FOLLOW
```
