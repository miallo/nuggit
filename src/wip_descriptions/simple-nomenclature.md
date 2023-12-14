# Nomenclature

This is the simple way to describe commonly used words in git. For simplification reasons some definitions contain statements that are in fact wrong (noted with a "\*"), but helpful for a first understanding. Once you are comfortable with these I would recommend you to look into the [advanced nomenclature](./advanced-nomenclature.md). Also that contains more advanced concepts that you might come across later.

- _Commit_\*: a set of changes bundled together with a _Commit-Message_ describing what happened. Each commit has a unique _Hash_ that references it.
- _Commit-Message_: A string describing the changes of a commit. The first line of it is called the title and it is shown in many places. It should give a general idea on what was done and should not be longer than ~50 characters. If that is not enough, you can append an empty line and afterwards you are free to write 
- _Hash_: a hexadecimal (= digits + letters from a-f) string that is up to 40 characters long. It is usually abbreviated to 8 characters, but can be truncated more or less, as long as there is no other hash that starts with the same characters.
- _Staging_\*: Preparing git to tell it which changes you want to bundle together in the next commit
- _Status_: overview of the current project state telling you
