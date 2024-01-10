# Architecture

Creating such an interactive repo that references itself everywhere is a bit tedious, since you basically have to think in reverse: The creation script has to finish where the player starts their journey. So when adding new "chapters" you (usually) need to add them at earlier point in the creation script, so that you can reference them. In general it is a good idea to mention only things that happened earlier in the script (even if you could mention e.g. a tag and only later create it), so basically to insert more or less at the top, but there are exceptions like the remote, where we want upstream mostly to have the current state and even if we could distinguish creating the repo and pushing to it, this does not make sense and so we want to do that last, even if we reference it before.

## How it works - Overview

### How to refer to other commits

If you want to link to a different commit, make sure that you don't do this absolute (as in run the creation script and then copy the hash), but instead put in a placeholder that can be dynamically replaced if the hash of that commit changes (e.g. if someone fixes a typo, adds a new commit before, ...). In ./lib.sh there is a function `replace_placeholders` that gets a file as an input and writes the content to stdout with the known placeholders replaced.

### How nuggits are hidden

- Some of the nuggits are static, as in the very first one `git diff`, `git show`, ... - those use "the normal builtin features" as the player knows them.
- Others like `git commit` adding a nuggit to the commit message make use of hooks (in this case `pre-commit-message`) to inject themselves when the player does an action

### The "database" of redeemed nuggits

When the player tries to redeem a nuggit, we don't want the redeeming script just to contain a list of all the nuggits, since the player could just open that file (maybe even by accident) and see the list. Instead they are stored as loose objects in the .git/objects folder themselves. but because the user could just run
```sh
git fsck --dangling | cut -d " " -f3 | xargs -n 1 git cat-file -p
```
to get all the objects in plain text, we don't store the nuggits, but their hashes (yes, it feels a bit like hash-ception). They are stored as blobs and so for trying to retrieve them we first hash the input twice and use `git cat-file -p` on the result. If that object does not exist, it wasn't a nuggit. So yes, we are using git exactly as it was designed: as a content addressable database :D

For the player to be able to run `git log nuggits`, we have another trick up our sleeves: we have a "pseudo branch". "Pseudo branch" as in "not found under `.git/refs/heads/nuggits`", but instead at `.git/nuggits`. That way it is not found with `git branch --list` or `git tag --list`, because that would just irritate the player later in the gameplay. But for the log we rely on gits way to dereference refs where it also searches from the toplevel of the git folder. But from the content side it is indeed (just as a normal branch) a file containing a commit hash.

When the player redeems a valid nuggit, we basically want to commit to that branch, but we obviously can't just `git switch nuggits && git commit --allow-empty -m "$nuggit" && git switch -`, since we
b) don't want to update worktree/index and
a) don't know if the player has unstaged changes,
c) don't want to pollute the reflog.

So what do we do then? Easy: We use the plumbing commands to create the commit and then manually update our "branch".

Once a nuggit is redeemed, we write another object to the "database" with the format `'$nuggit' already redeemed`. That way we can look it up in our "database" before we tell the user they redeemed a new one.

As a side-note, we don't just rely on the number of commits in our nuggits branch, since the user could easily tinker with that. But with each newly redeemed nuggit we also write the total number of redeemed nuggits to the objects. That way we can at least cross reference a tiny bit if the player has tinkered with our system (but of course they could just open the script and reverse that as well...)
