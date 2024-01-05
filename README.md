# What is this?

This is the (WIP) script for creating a `git` challenge. To create a local "playable" copy run `./create_challenge.sh`. The challenge itself is only in the then created folder "challenge" and NOT in this repository. Do NOT look around in this repository unless you want to develop this challenge, because otherwise you will be spoiled with the solutions ;)


## testing

To run the tests you simply need to execute:
```sh
./test.sh
```
WARNING: It will build the challenge for you, since it basically only ever makes sense to run this on a freshly built dir

There is a small testing library roughly mimicking `jest` in its usage.
