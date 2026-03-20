# Git Alias Workflow

Practical guide for the Git aliases defined in `config-files/zsh/aliases`.

## Core aliases

- `g` -> `git`
- `gst` -> `git status`
- `gaw` -> `git add`
- `gcmsg` -> `git commit --message`
- `gp` -> `git push`
- `gpsup` -> `git push --set-upstream origin $(git_current_branch)`
- `gpr` -> `git pull --rebase`
- `grt` -> `cd "$(git rev-parse --show-toplevel || echo .)"`

## Daily branch workflow

```bash
grt
gst
gpr
gcb feature/my-task

# work
gaw .
gcmsg "feat: implement my task"
gpsup
```

## Worktree workflow

### 1) List current worktrees

```bash
gwtls
```

### 2) Create a worktree for an existing branch

```bash
gwta ../dotfiles-main main
```

For an existing local feature branch:

```bash
gwta ../dotfiles-feature feature/my-task
```

### 3) Create a worktree and branch at the same time

```bash
gwta ../dotfiles-fix-lock -b fix/lock-merge
```

### 4) Work in that tree

```bash
cd ../dotfiles-fix-lock
gst
gaw .
gcmsg "fix: resolve lockfile merge"
gpsup
```

### 5) Remove the worktree when done

```bash
cd -
gwtrm ../dotfiles-fix-lock
```

## Merge conflict workflow (quick)

- Start mergetool: `g mergetool`
- In Neovim diff mode:
  - `<leader>gl` -> take LOCAL
  - `<leader>gr` -> take REMOTE
- Then save and finish:

```bash
gaw <file>
gc
```

## Useful extras

- `gwt` -> `git worktree`
- `gwtmv` -> `git worktree move`
- `gwtrm` -> `git worktree remove`
- `gprv` -> `git pull --rebase -v`
- `gprom` -> `git pull --rebase origin $(git_main_branch)`
