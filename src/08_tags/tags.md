# Tags

A tag is (like a branch) a human readable way to refer to a specific commit. The difference is that a tag "stays attached" to that commit, even if you check it out and create a new commit (whereas the branch would be updated to point to the new commit). That means that they are useful to tag releases.

When simply trying to switch to a tag with `git switch the-first-tag` you will get an error:
    > hint: If you want to detach HEAD at the commit, try again with the --detach option.
so you need to run `git switch --detach the-first-tag` instead. Why? This is gits way to warn you that you could loose work when you start working and then commit your work, since you don't have a simple way to refer to that commit later, because it does not have a "nice name".

Is that bad? No, not at all - you just have to keep this in mind. And even if you create a new commit while being in a detached HEAD state and you switched back to a different branch, there are ways to recover it - but that will be a story for later ;)
