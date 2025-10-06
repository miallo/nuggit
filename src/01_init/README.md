# Nuggits

This is an explanation/game on how to use the version control system `git`. It is not intended that you use other tools like `grep` to find the "nuggits" (little strings of text to show you that you make progress learning git ;) - like flags in CTF challenges). Instead you will find them by using the git commands while they are explained. For instructions on how to redeem them, see the FAQ below.

For many day-to-day tasks the graphical user interfaces for it might well work, but for this tutorial we need to use the command line instead.

## Game FAQ

Q: What is a nuggit?
A: A nuggit is almost like a nugget a small golden piece, but with more git in it! It is a single word, e.g. "TestNuggit" and you will always find it in the format "nuggit: TestNuggit".

Q: How do I redeem a nuggit?
A: Just run `git nuggit redeem <name of the nuggit>` - it will show you if you are correct or not. (No, "nuggit" is not a builtin git command, but an "alias" that was set up in this repository, we'll come to that later...)

Q: What custom commands are there for nuggits?
A: The commands that will only work in this project are:
- `git nuggit redeem <name of the nuggit>` - submit a nuggit
- `git nuggit progress` - get an overview of how many nuggits you already collected
- `git log nuggits` - list all the nuggits you have found including a short summary of what the command does you got it for.

Q: I want to learn more about a git command - how?
A: As a first step, just run `git <command> --help` - otherwise: the internet is your friend.

NOTE: This tutorial uses git hooks extensively for it to work. Because of the way you downloaded/built this repository they are enabled by default and could run arbitrary code.

Also: if your editor of choice asks you if you want to "trust this project" - say yes, otherwise its git integration will not work ;)

# What do I need to do?

You will be guided step by step and there will be explanations and example code snippets. Hint: just try them out when you encounter them ;)
You will often find new explanations/commands in files, but also sometimes in the output of a command you executed.

In some places you might need to use a command that you previously learned, but hopefully in most places we tell you what to do.

If you encounter a situation, where you don't know what to do: [open an issue](https://github.com/miallo/nuggit/issues/new).

Now lets start with redeeming your first
```
nuggit: ReadTheDocs
```
to set things up:

```sh
git nuggit redeem ReadTheDocs
```
