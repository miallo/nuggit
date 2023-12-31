# Nuggits

This is an explanation/game on how to use the version control system `git`. It is not intended that you use other tools like `grep` to find the flags, but instead find them with the builtin git commands.

For many day-to-day tasks the graphical user interfaces for it might well work, but it will definitely get to its limits on this challenge, since it will get into the nitty-gritty details (if you want) so it is recommended to use the command line instead.

By default in most Projects there exists a README file, so with opening this file you already made the first step (I promise: even if you know git you probably get to know a thing or two about `git` that you didn't hear about. And if you did: please get in touch so that I can learn more from you and maybe even add some more ideas!)

## Game FAQ

Q: Why you get this folder in this way instead of the usual `git clone <url>`?
A: That is a good question and you will figure out the answer the more you get into the quests (many of which are impossible in a fresh clone).

Q: Can I use my favourite git GUI tool?
A: Well... For a few of the flags, yes, but some are well hidden in the stranger parts of git, so this project assumes running git from the command line from the beginning.

NOTE: This challenge uses git hooks. Because of the way you download this repository they are enabled and COULD run arbitrary code. I promise you they are just here for the benefit of the people learning git and don't do anything malicious. If you are paranoid, you should never download repositories like this!

# First steps with `git`

`git` takes snapshots of your code, so that you can e.g. go back in the history of a file.
