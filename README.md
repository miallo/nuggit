# What is this?

`git` s a brilliant version control system—but it can be confusing. As this classic xkcd comic shows, many users just memorize a few commands and panic when things go wrong:

![A comic of stick figures describing how beautiful git is, but they just memorize a few commands. And when they run into an issue, they don't know how to deal with it and just copy the file and delete the folder](https://imgs.xkcd.com/comics/git.png "If that doesn't fix it, git.txt contains the phone number of a friend of mine who understands git. Just wait through a few minutes of 'It's really pretty simple, just think of branches as...' and eventually you'll learn the commands that will fix everything.")

This tutorial takes a different approach: you will learn git by using it. Commands reveal info step by step, so you won't skip anything and hopefully, you'll have fun along the way 😉
The tutorial lives in the "*tutorial*" folder (see build instructions below). Since it contains spoilers, **don't explore the rest of this repo** (like the src folder) until you are done with the play through!

Build instructions:
```sh
git clone https://github.com/miallo/nuggit.git
cd nuggit
./build.sh
cd tutorial
ls
# Look! Another README!
```
and the fun can begin! The whole "game" will now take place in this folder alone. Let's start by reading the README.md *inside of that folder* 😊

## Don't want to build it yourself?

Alternatively: If you don't want to run this "build"-script yourself (it basically just executes a bunch of git commands to create the folder "tutorial" and fills it with all the information you need), you can download it:
```sh
curl -L https://nuggit-cache.lohmann.sh/ --output tutorial.zip
unzip tutorial.zip
tar --extract --file=tutorial.tar
cd tutorial
ls
# Look! Another README!
```
and then you are ready! The whole "game" will now take place in this folder only. Let's start by reading the README.md in that folder 😊

Note: for some cursed reason thanks to GitHub, the folder must also be inside of a tarball to remain playable…

## Which git functions are already explained?

- diff (--staged)
- add
- commit (-m)
- show
- switch (-c)
- push
- pull
- log
- rebase
- merge
- cherry-pick
- reset (--hard/--soft)
- restore (--staged/--source)

## Meta

*NOTE:* If you just want to learn, you don't need to continue reading 😉

## Developing

If you want to work on this, [architecture](./architecture.md) contains a short introduction on how this project is structured.

The main implementation is found in [`./build.sh`](./build.sh). Under `src/` there are many of the text snippets / hooks that are used in build.sh.

### debugging

By default `./build.sh` does not show the git output to avoid leaking information. If you get an error you can run it again with `-v`/`--verbose`.

### testing

To run the tests you simply need to execute:
```sh
./test.sh
```
It has three levels of verbosity: by default it just prints the test cases, but if run with `-v` it will also output every expect. If run with `-v -v` it will additionally print every output of the commands it executed.

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
