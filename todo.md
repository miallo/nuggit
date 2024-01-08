# "fancy" ideas for clues

- range-diff (merge-base)
- bisect
- blame
- grep

# List of places to hide

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
- hooks (e.g. automatically add nuggit to commit message)
    - post-merge
    - post-rewrite e.g. for commit --amend
    - pre-rebase
- `--word-diff --word-diff-regex=.` (nuggit hidden "inbetween" two commits)
- submodule
- `blame` first column
- untracked files (`git clean --dry-run` or `git status --ignored`)
- files in .gitignore
- COMMIT_MESSAGE
- merge commit (`git merge --no-commit`)
- file encrypted with filter
- rerere for specific conflict
- apply a number of patches (and maybe calculate the nuggit, so that it isn't obvious from the patches themselves?)
- files in .git/info/exclude
- custom subcommand (requires setting up the $PATH)
- git reflog => detached commit
- random object in .git/objects (`git prune --dry-run` or hint of hash?)
    - tree / file / blob
    - git cat-file -p <hash>


# Tools

- noninteractive interactive rebase (for reflog)
    - replace content of todo file with custom content:
        - streameditor.sh:
            ```sh
            #!/usr/bin/env bash
            cat > "$1" << EOF
            r commit
            pick commit2
            EOF
            ```
        - `GIT_EDITOR="sed -i -e 's/old text in commit msg/fancy new text/g'" GIT_SEQUENCE_EDITOR="./streameditor.sh" git rebase -i HEAD~6`



## hooks left to do:

See documentation in the git repository under Documentation/githooks.txt

- applypatch-msg
- pre-applypatch
- post-applypatch
- pre-commit
- pre-merge-commit
- commit-msg
- post-commit
- pre-rebase
- post-merge
- pre-push
- pre-receive
- update
- proc-receive
- post-receive
- post-update
- reference-transaction
- push-to-checkout
- post-rewrite
- sendemail-validate
- fsmonitor-watchman
- p4-changelist
- p4-prepare-changelist
- p4-post-changelist
- p4-pre-submit
- post-index-change
