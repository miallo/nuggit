# "fancy" ideas for clues

- range-diff (merge-base)
- bisect
- blame
- grep

# List of places to hide

- commit message
- reverted commit
- remote (fetch)
- different branch
    - orphan branch (no common ancestor)
        - git log --all --decorate
- tag
    - `git describe`
    - all tags
- different remote
- stash
- .git/config (e.g. author)
    - alias
- hooks (e.g. automatically add flag to commit message)
    - post-checkout
    - post-merge
    - post-rewrite e.g. for commit --amend
    - pre-rebase
    - Selfdestructing flags:
        ```sh
        # ----- >8 ------
        # This flag is gonna destroy itself when executing
        sed -n '/--- >8 ---/q;p' "${BASH_SOURCE[0]}" > tmp
        mv tmp "${BASH_SOURCE[0]}"
        ```
- `--word-diff --word-diff-regex=.` (flag hidden "inbetween" two commits)
- submodule
- `blame` first column
- untracked files (`git clean --dry-run` or `git status --ignored`)
- files in .gitignore
- COMMIT_MESSAGE
- merge commit (`git merge --no-commit`)
- file encrypted with filter
- rerere for specific conflict
- apply a number of patches (and maybe calculate the flag, so that it isn't obvious from the patches themselves?)
- files in .git/info/exclude
- custom subcommand (requires setting up the $PATH)
- git reflog => detached commit
- random object in .git/objects (`git prune --dry-run` or hint of hash?)
    - tree / file / blob
    - git cat-file -p <hash>


## all hooks

See documentation in the git repository under Documentation/githooks.txt

- applypatch-msg
- pre-applypatch
- post-applypatch
- pre-commit
- pre-merge-commit
- prepare-commit-msg
- commit-msg
- post-commit
- pre-rebase
- post-checkout
- post-merge
- pre-push
- pre-receive
- update
- proc-receive
- post-receive
- post-update
- reference-transaction
- push-to-checkout
- pre-auto-gc
- post-rewrite
- sendemail-validate
- fsmonitor-watchman
- p4-changelist
- p4-prepare-changelist
- p4-post-changelist
- p4-pre-submit
- post-index-change
