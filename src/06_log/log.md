# The git log

If you want to investigate the history of a commit there is `git log`.
By default it will show the history of the current commit, but it can also view it for a different commit:
```sh
git log CHAPTER_LOG_FOLLOW
```

When doing so you can use the arrow keys for scrolling, since the default PAGER it uses is `less` and that does not work with the scroll wheel. Many of the keyboard shortcuts you might know from other command line programms also work, like searching with `/switch` and pressing enter will search for the next occurence for the word "switch". It also has many more useful key mappings you can find with pressing "h" (for help) - like "q" for quit.
