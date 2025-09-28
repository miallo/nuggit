# What is this?

`git` is a nice version control system, but since it has many features, it can be a bit hard to understand, as this lovely xkcd-comic by Randall Munroe shows:

![A comic of stick figures describing how beautiful git is, but they just memorize a few commands. And when they run into an issue, they don't know how to deal with it and just copy the file and delete the folder](https://imgs.xkcd.com/comics/git.png "If that doesn't fix it, git.txt contains the phone number of a friend of mine who understands git. Just wait through a few minutes of 'It's really pretty simple, just think of branches as...' and eventually you'll learn the commands that will fix everything.")

But fear not! It does not have to be that way!

There are lots of tutorials online, which describe certain features, but in my experience they all have a drawback: certain actions require your repository to be in a certain state, otherwise commands will fail because you accidentally skipped a step. But that does not have to be this way! Here is a tutorial that explains git by you actually using it. The commands to will only uncover one info at a time, so you can't accidentally skip steps. (And hopefully it is at least a bit of fun, too ;-) ).

The tutorial itself is only in the folder "tutorial" that can be build (see below) and NOT in this repository. Do NOT look around in this repository unless you want to develop it, because otherwise you will be spoiled with the solutions.

Also: If you are playing for the "nuggits" (like CTF flags some strings that you can redeem to track your progress) don't snoop around in the .git-Folder unless explicitly told - it'll spoil the fun for you and as said before: you can find (almost) all flags by using git commands only ;)

Build instructions:
```sh
git clone https://github.com/miallo/nuggit.git
cd nuggit
./build.sh
cd tutorial
```
and the fun can begin!

Alternatively: If you don't want to run this "build"-script yourself (it basically just executes a bunch of git commands to create the folder "tutorial" and fills it with all the information you need), you can download a copy from GitHub, unzip it and (for some cursed reason thanks to GitHub the playable folder must also be in a tarball to remain playable) then you also need to extract the tarball that is contained.
On MacOS both can be achieved by double-clicking them in finder, but if you are using Linux or you already want to get warmed up using the terminal/command line, you can run those commands in your download folder:
```sh
unzip tutorial.zip
tar --extract --file=tutorial.tar
cd tutorial
```
and then you are ready!

## What git functions are already explained?

- diff (--staged)
- add
- commit (-m)
- show
- switch (-c)
- push
- pull
- log
- rebase
- (merge) <= only explained, but not interactively
- cherry-pick

## debugging

By default `./build.sh` does not show the git output to avoid leaking information. If you get an error you can run it again with `-v`/`--verbose`.

# Developing

If you want to work on this, [architecture](./architecture.md) contains a short introduction on how this project is structured.

The main implementation is found in [`./build.sh`](./build.sh). Under `src/` there are many of the text snippets / hooks that are used in build.sh.

## testing

To run the tests you simply need to execute:
```sh
./test.sh
```
It has two levels of debugging, so by default it just prints the test cases, but if run with `-v` it will also output every expect. If run with `-v -v` it will additionally print every output of the commands it executed.

WARNING: It will build the tutorial for you, since it has to reset the state inbetween to check incompatible "paths" (test with triggering the LocalCodeExecution trap, or not). That means it does not matter into which state you bring the tutorial directory before the run - it will be deleted and replaced by a fresh build before the first test is run.

For writing tests there is a tiny testing framework (loosely inspired by `jest`). It is by far not feature complete. Example:
```sh
sum() {
    a="$1" b="$2"
    echo "$(( a + b ))"
}
```
and the test code:
```sh
it 'adds 1 + 2 to equal 3' '
  expect "sum 1 2" to contain "3";
'
```
(Yes, right: it is so "tiny", it does not even have a "to equal" action yet, but only a "stdout contains substring" assertion... So far it was all we needed, but feel free to extend it!)
