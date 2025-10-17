# Working with others

Git on its own is a nice tool, but the real strength comes from when you interact with others. And since they (mostly) don't always sit beside you at the same computer, one alternative would be to send over the files via email. That would get messy very fast and it also does not scale that well to many people, so git has a builtin way to interact with servers that can store all the code and make it accessible to other people.

# What is "upstream"?

Git has some strange nomenclature. a local git repository clone can have multiple remote repositories connected. E.g. you might have "forked a repo" (taken the code of someone else to modify it yourself). And now you want to be able to
a) fetch the new changes of the other person and
b) work on your own fork

e.g. to later open a "_pull-request_" ("PR" in short, or GitLab calls it "_merge-request_", aka "MR") for the original owner to accept your changes.

By default there is only one remote repo connected and it is called the "_origin_". In other circumstances it is called the "_upstream_". They sometimes refer to the same concept of "the remote repository", and sometimes to the specific remote. The convention is "origin" for your fork and "upstream" for the original repo.

Changes are not automatically synced in either way.

The word "upstream" is also used for which remote branch a local one is connected to. You can refer to this branch by `@{upstream}` or in short `@{u}`, so e.g. to see the changes compared to what your git thinks the remote branch connected to this one is:
```sh
git diff @{u}
```

nuggit: WhereIsTheLiveStream

# Pushing changes

To publish your local changes for a branch that the server already knows about, just run

```sh
git push
```
