# Nuggits

This is an explanation/game on how to use the version control system `git`. It is not intended that you use other tools like `grep` to find the "nuggits" (little strings of text to show you that you make progress learning git ;) - otherwise known as flags in CTF challenges), but instead find them with the builtin git commands. For instructions on how to redeem them, see the FAQ below.

For many day-to-day tasks the graphical user interfaces for it might well work, but it will definitely get to its limits on this challenge, since it will get into the nitty-gritty details (if you want) so it is recommended to use the command line instead.

By default in most Projects there exists a README file, so with opening this file you already made the first step (I promise: even if you know git you probably get to know a thing or two about `git` that you didn't hear about. And if you did: please get in touch so that I can learn more from you and maybe even add some more ideas!)

## Game FAQ

Q: What is a nuggit?
A: A nuggit is almost like a nugget a small golden piece, but with more git in it! It is a single word, e.g. "TestNuggit" and you will always find it in the format "nuggit: TestNuggit".

Q: How to I redeem a nuggit?
A: Just run `git redeem-nuggit <name of the nuggit>` - it will show you if you are correct or not. (No, redeem-nuggit is not a builtin git command, but an "alias" in this repository, we'll come to that later...)

Q: Where do I see all my redeemed nuggits and the time when I redeemed them?
A: Just run `git log nuggits` :)

Q: Why you get this folder in this way instead of the usual `git clone <url>`?
A: That is a good question and you will figure out the answer the more you get into the quests (many of which are impossible in a fresh clone).

Q: Can I use my favourite git GUI tool?
A: Well... For a few of the nuggits, yes, but some are well hidden in the stranger parts of git, so this project assumes running git from the command line from the beginning.

NOTE: This challenge uses git hooks extensively for it to work. Because of the way you downloaded this repository they are enabled by default and could run arbitrary code. I promise you they are just here for the benefit of learning git and don't do anything malicious. If it makes you feel better: For testing this challenge I have a test suite that I am regularly running on my machine that triggers all of them.
If you are still paranoid, you should never download repositories like this! Instead you can come and take a look how this was created and help to complete it - with git there are infinitely many things to learn and we will never be done...


Also: if your editor of choice asks you if you want to trust this project - say yes, otherwise its git integration will not work ;)

# First steps with `git`

`git` takes snapshots of your code, so that you can e.g. go back in the history of a file.
