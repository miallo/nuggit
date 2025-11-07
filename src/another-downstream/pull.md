nuggit: PullMeUnder

# Nomenclature: origin / upstream / remote

- "remote": a remote is the server that git talkes to when pushing/pulling. Most of the time there is only one remote and it is called "origin" (Actually there can be more than one of them, but we will talk about that later...)
- "origin": In git you will often stumble over the word "origin". What that basically means is "the server to which you are sending your changes". More specifically: it is what your local git instance thinks the server looks like, because it has its own local copy of the server branches as well. This is very useful, because you can use quite a bit of git without needing an internet connection.
- "upstream": the upstream branch to one of your local ones is the one that corresponds to it on the server. Usually it is the same branch name, but with the prefix "origin/" (e.g. origin/main)

# Get other changes

When you run `git pull`, two things happen, that git does automatically for you:

- git downloads all changes that are in the server, that you don't know about and updates the local view of the branches (there is a separate comand that does only that: `git fetch`) - this does NOT update any of your branches.
- if there were any updates to the upstream branch, it will update your current branch with the changes and also update all the files in your working directory for you. It can do that with a merge or a rebase (TODO: explain merge/rebase)
