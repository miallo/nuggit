> [!IMPORTANT]
> The tutorial lives in the "*tutorial*" folder (see [build instructions](#build-instructions) below).
>
> Since it contains spoilers, **don't explore the rest of this repo** (like the src folder) until you are done with the play through!

# What is this?

`git` is a brilliant version control system but to say it is _self-explanatory_ is a bit of a stretch 😅 (until now). As this classic xkcd comic shows, many users just memorize a few commands and panic when things go wrong:

![A comic of stick figures describing how beautiful git is, but they just memorize a few commands. And when they run into an issue, they don't know how to deal with it and just copy the file and delete the folder](https://imgs.xkcd.com/comics/git.png "If that doesn't fix it, git.txt contains the phone number of a friend of mine who understands git. Just wait through a few minutes of 'It's really pretty simple, just think of branches as...' and eventually you'll learn the commands that will fix everything.")

This tutorial takes a different approach: You will learn git by actively using it. Executing one command you learn reveals the information about the next command and so on. And most importantly: hopefully, you'll have fun along the way 😉

## Build instructions

Run these commands in your terminal:

```sh
git clone https://github.com/miallo/nuggit.git # Yay! You already learned about your first git command!
cd nuggit
./build.sh
cd tutorial
ls
# Look! Another README!
```
and the fun can begin! The whole "game" will now take place in this folder alone. Let's start by reading the README.md *inside of that folder* 😊

*NOTE:* If you just want to learn, you don't need to continue reading 😉

## Don't want to build it yourself?

Q: Why can't you get the "tutorial" folder with `git clone <url>` but have to build it?
A: That is a good question and you will figure out the answer the more you get into the quests (many of which are impossible in a fresh clone)…

Alternatively: If you don't want to run this "build"-script yourself (it basically just executes a bunch of git commands to create the folder "tutorial" and fills it with all the information you need), you can download it:
```sh
curl https://nuggit.lohmann.sh/tutorial.zip --output tutorial.zip
unzip tutorial.zip
tar --extract --file=tutorial.tar
cd tutorial
ls
# Look! Another README!
```
and then you are ready! The whole "game" will now take place in this folder only. Let's start by reading the README.md in that folder 😊

Note: for some cursed reason thanks to GitHub, the folder must also be inside of a tarball to remain playable…

## Which git functions are already explained?

- diff (--staged/@{u})
- add
- commit (-m)
- show
- switch (-c)
- push
- pull
- log
- rebase
- merge
- cherry-pick (range/--abort)
- reset (--hard/--soft)
- restore (--staged/--source/--ours)
- revert

## Developing

If you want to work on this challenge and improve it, [architecture](./architecture.md) contains a short introduction on how this project is structured.
