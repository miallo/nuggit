# What is this?

This is the (WIP) script for creating an interactive `git` repo that is a completely self-contained `git` tutorial (and hopefully at least a bit fun, too ;-) ).
The challenge itself is only in the folder "challenge" that can be build (see below) and NOT in this repository. Do NOT look around in this repository unless you want to develop this challenge, because otherwise you will be spoiled with the solutions. Also: don't snoop around in the .git-Folder unless explicitly told - it'll spoil the fun for you and as said before: you can find all flags by using git commands ;)

You can download a copy from GitHub, unzip it and (for some cursed reason thanks to GitHub it must also be in a tarball to remain playable) then you also need to extract the tarball.
On MacOS both can be achieved by double-clicking them in finder, but if you are using Linux or you already want to get warmed up using the terminal/command line, you can run those commands in your download folder:
```sh
unzip challenge.zip
tar --extract --file=challenge.tar
cd challenge
```
and then you are ready!

If instead you want to create a local "playable" copy, you can simply run `./create_challenge.sh` and you will find the folder "challenge".

## debugging

By default `./create_challenge.sh` does not show the git output to avoid leaking information. If you get an error you can run it again with `-v`/`--verbose`.

## testing

To run the tests you simply need to execute:
```sh
./test.sh
```
It has two levels of debugging, so by default it just prints the test cases, but if run with `-v` it will also output every expect. If run with `-v -v` it will additionally print every output of the commands it executed.

WARNING: It will build the challenge for you, since it has to reset the state inbetween to check incompatible "paths" (test with triggering the LocalCodeExecution trap, or not). That means it does not matter into which state you bring the challenge directory before the run - it will be deleted and replaced by a fresh build before the first test is run.

There is a small testing library roughly mimicking `jest` in its usage.
