# important basics left to explain

- status (basics are explained, but not in depth...)
- commit --amend
- restore
- nomenclature of HEAD/repository/^/~/@{u}/...
- merge
- (clone - hard to do sensibly)
- range-diff

## less important basics

- add -p
- tag (interactively)
- revert
- config
    - alias (explains redeem-nuggit)
- submodule
- rm / mv
- worktree
- remote
- bisect
- merge-base
- ranges (HEAD...FETCH_HEAD)
- log -S
- grep

# "fancy" ideas for clues

- range-diff (merge-base)
- bisect
- blame
- grep

# List of places to hide

- reverted commit
- different branch
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
- `--word-diff --word-diff-regex=.` (nuggit hidden "inbetween" two commits)
- submodule
- `blame` first column
- untracked files (`git clean --dry-run` or `git status --ignored`)
- files in .gitignore
- files in .git/info/exclude
- merge commit (`git merge --no-commit`)
- file encrypted with filter
- rerere for specific conflict
- apply a number of patches (and maybe calculate the nuggit, so that it isn't obvious from the patches themselves?)
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
