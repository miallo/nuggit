# Commit

A "commit" is snapshot of the project with some metadata like a time stamp, a commit message describing the changes and the "parent commit(s)", i.e. what the previous state was that this change was based on.
An alternative view that git often shows to you for a commit is the dynamically calculated "diff" to the previous commit, so only the changes. For most day-to-day uses this might be a good impression, but keep in mind that it is not what happens in reality.

A commit can be addressed by a "hash". That is a seemingly random string of numbers and letters from a-f (hexadecimal numbers). The full length of a hash is 40 characters, but it can be truncated, as long as it is unique. That means that in many places 8-10 characters are enough.

To view the commit message and diff for a commit there exists the command `git show`. By default it will show the last commit, but you can also show a specific one like this:
```sh
git show c3e18a3e94
```
