# Nuggits

This is an explanation/game on how to use the version control system `git`. It is not intended that you use other tools like `grep` to find the "nuggits" (little strings of text to show you that you make progress learning git ;) - otherwise known as flags in CTF challenges), but instead find them with the builtin git commands. For instructions on how to redeem them, see the FAQ below.

For many day-to-day tasks the graphical user interfaces for it might well work, but it will definitely get to its limits on this challenge, since it will get into the nitty-gritty details (if you want) so it is recommended to use the command line instead.

By default in most Projects there exists a README file, so with opening this file you already made the first step (I promise: even if you know git you probably get to know a thing or two about `git` that you didn't hear about. And if you did: please get in touch so that I can learn more from you and maybe even add some more ideas!)

## Game FAQ

Q: How to I redeem a nuggit (flag)?
A: Just run `./redeem_nuggit <name of the nuggit>` - it will show you if you are correct or not.

Q: Where do I see all my redeemed nuggits?
A: Once redeemed a file per nuggit is created in the folder "nuggits" containing the date you first redeemed it.

Q: Why you get this folder in this way instead of the usual `git clone <url>`?
A: That is a good question and you will figure out the answer the more you get into the quests (many of which are impossible in a fresh clone).

Q: Can I use my favourite git GUI tool?
A: Well... For a few of the nuggits, yes, but some are well hidden in the stranger parts of git, so this project assumes running git from the command line from the beginning.

NOTE: This challenge uses git hooks. Because of the way you download this repository they are enabled and COULD run arbitrary code. I promise you they are just here for the benefit of the people learning git and don't do anything malicious. If you are paranoid, you should never download repositories like this!

# First steps with `git`

`git` takes snapshots of your code, so that you can e.g. go back in the history of a file.
