## First steps with `git`

One of the most used git commands is `git status` to see the current state (as in: Do I have uncommitted changes? Do I have commits locally that are not synced yet with the server ("pushed")?)

Since you might not want to include all your current changes in the commit (e.g. because you found a typo in a README and for clarity/separation it should be a different checkpoint than a code change you are working on), `git` has a "staging area". This just describes all the changes you are about to commit. The output of `status` "Changes to be committed" tells you about files that are changed and that you would commit.

To check what you are about to commit run

```sh
git diff --staged
```

(a synonym for "--staged" that you might see in some older references is "--cached").
