# Advanced Concepts

- _Commit_\*: A commit is not in fact the set of changes, but a snapshot of the whole project at a time. This is the reason why git does not particularly want you to commit large binary files, because if a single bit is changed, git will store a whole new copy of the file.
- _Hash_: Not only commits have hashes
- _Porcelain_/_Plummbing_ commands: Porcelain commands are the one that a normal user would use (like `status`, `commit`, `log`, ... or in the real world analogy: the sink/toilet), so the high level ones. They themselves call the low level Plummbing commands in various combination to achieve the goal (real world: the toilet uses the plumbing to get fresh and get rid of the waste water). git provides you with them, in case you want/need to dig into some details, but for everyday use, you won't need them
-
