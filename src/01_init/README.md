# Nuggits

This is an explanation/game on how to use the version control system `git`. It is not intended that you use other tools like `grep` to find the "nuggits" (little strings of text to show you that you make progress learning git ;) - otherwise known as flags in CTF challenges), but instead find them with the builtin git commands. For instructions on how to redeem them, see the FAQ below.

For many day-to-day tasks the graphical user interfaces for it might well work, but it will definitely get to its limits on this tutorial, since it will get into the nitty-gritty details (if you want) so it is recommended to use the command line instead.

By default in most projects there exists a README file, so with opening this file you already made the first step (I promise: even if you know git you probably get to know a thing or two about `git` that you didn't hear about. And if you did: please get in touch so that I can learn more from you and maybe even add some more ideas!)

## Game FAQ

Q: What is a nuggit?
A: A nuggit is almost like a nugget a small golden piece, but with more git in it! It is a single word, e.g. "TestNuggit" and you will always find it in the format "nuggit: TestNuggit".

Q: How do I redeem a nuggit?
A: Just run `git redeem-nuggit <name of the nuggit>` - it will show you if you are correct or not. (No, redeem-nuggit is not a builtin git command, but an "alias" in this repository, we'll come to that later...)

Q: What custom commands are there for nuggits?
A: The commands that will only work in this project are:
- `git redeem-nuggit <name of the nuggit>` - submit a nuggit
- `git nuggit-progress` - get an overview of how many nuggits you already collected
- `git log nuggits` - list all the nuggits you have found including a short summary of what the command does you got it for.

Q: Why you get this folder in this way instead of the usual `git clone <url>`?
A: That is a good question and you will figure out the answer the more you get into the quests (many of which are impossible in a fresh clone).

Q: Can I use my favourite git GUI tool?
A: Well... For a few of the nuggits, yes, but some are well hidden in the stranger parts of git, so this project assumes running git from the command line from the beginning.

Q: I want to learn more about a git command - how?
A: As a first step, just run `git <command> --help` - otherwise: the internet is your friend.

NOTE: This tutorial uses git hooks extensively for it to work. Because of the way you downloaded this repository they are enabled by default and could run arbitrary code. I promise you they are just here for the benefit of learning git and don't do anything malicious. If it makes you feel better: For testing this tutorial I have a test suite that I am regularly running on my machine that triggers all of them.
If you are still paranoid, you should never download repositories like this! Instead you can come and take a look how this was created and help to complete it - with git there are infinitely many things to learn and we will never be done...


Also: if your editor of choice asks you if you want to trust this project - say yes, otherwise its git integration will not work ;)

Once you are done, with it, you will hopefully be the person, people come to when they have questions about git:
![A comic of stick figures describing how beautiful git is, but they just memorize a few commands. And when they run into an issue, they don't know how to deal with it and just copy the file and delete the folder](https://imgs.xkcd.com/comics/git.png "If that doesn't fix it, git.txt contains the phone number of a friend of mine who understands git. Just wait through a few minutes of 'It's really pretty simple, just think of branches as...' and eventually you'll learn the commands that will fix everything.")
(Credits to xkcd/Randall Munroe - I can highly recommend all of the comics!)

# What do I need to do?

You will be guided step by step and there will be explanations and example code snippets. Hint: just try them out when you encounter them ;)
These commands can be in some files that you will find (if you executed a command but don't find further actions, take a look at the files and see if anything new is there). But they can also be in the output of certain git commands, so make sure to read them. If there are things you don't understand yet, because it is just the way git shows them, hopefully things will become more clear later when you get a better understanding.
In some places you might need to use a command that you previously learned, but hopefully in most places we tell you what to do.

If you encounter a situation, where you don't know what to do: [open an issue](https://github.com/miallo/nuggit/issues/new).

If you already know about certain git features, you can run `git skip-to-nuggit-chapter` to be presented with a list of places of the tutorial to jump to. Note: you will not collect the nuggits you skipped ;)

Let's start looking at [./first-steps-with-git.md](./first-steps-with-git.md)
