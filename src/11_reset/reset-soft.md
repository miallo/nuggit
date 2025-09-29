# Remove commits, but not your changes

If you e.g. have a lunch break and decide to run `git commit -am "lunch break"`, you might not want this to end up in your final merge request. Now you can run `git reset @~` (_without_ "--hard"!), to remove the commit but keep the changes.

If you want to keep your changes staged after the reset, you can run
```sh
git reset --soft CHAPTER_RESET_SOFT_FOLLOW
```
