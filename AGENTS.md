# AGENTS Guide for This Dotfiles Repository

This repository is a Bash-first dotfiles installer for Linux (Ubuntu/Debian, Arch) and macOS.
Use this guide as the default operating contract for coding agents.

## Repository Layout

- Entrypoint: `./install`
- Profile orchestration and CLI flow: `lib/profiles.sh`
- Core helpers and globals: `lib/core.sh`
- Preflight checks: `lib/preflight.sh`
- Install actions: `lib/installers.sh`
- Health checks: `lib/health.sh`
- Shared package/logging helpers: `packages/lib.sh`
- Config sources: `config-files/` and `user-files/`
- Script groups: `packages/`, `installers/`, `apps/`, `utils/`, `scripts/`

**Notable Scripts:**
- `scripts/llm-server` - Local LLM server launcher (llama.cpp wrapper with model registry, router mode, benchmark)

## Additional Instruction Sources

Checked paths (higher priority first):

- `.cursorrules`: not present
- `.cursor/rules/`: not present
- `.github/copilot-instructions.md`: not present
- `.opencode/agent/anti-slop.md`: present - contains AI slop cleanup guidelines

If any of these files are added later, treat them as higher-priority local instructions.

## Build / Lint / Test Commands

There is no compile step or unit-test suite at repo root.
Validation is done with shell syntax checks, installer health checks, and dry-runs.

### Primary Commands

```bash
make help
make install-all
make install-minimal
make install-omarchy
make check
make validate
make dry-run
```

### Install Script Commands

```bash
./install --help
./install --profile=full
./install --profile=minimal
./install --profile=omarchy
./install --profile=kool
./install --check
./install --dry-run --profile=full
./install --restore
```

### Single-Test Equivalent (One Changed Script)

Use this when you only touched one shell script.

```bash
bash -n ./install
bash -n lib/core.sh
bash -n lib/installers.sh
bash -n installers/02-oh-my-zsh.sh
bash -n packages/04-node.sh
bash -n apps/02-docker.sh
```

### Slice Tests (One Functional Area)

```bash
./install --dry-run --config
./install --dry-run --user-config
./install --dry-run --installers
./install --dry-run --packages
./install --dry-run --apps
./install --dry-run --local-scripts
```

## Code Style Guidelines

## 1) Shell Baseline

- Use `#!/usr/bin/env bash` for executable shell scripts.
- Use `set -euo pipefail` unless file conventions explicitly differ.
- Prefer guard clauses and explicit return paths in functions.
- Use `[[ ... ]]` instead of `[` for Bash conditionals.
- Quote expansions by default: `"$var"`, `"${arr[@]}"`.

## 2) Imports and Module Wiring

- Source required libraries near the top of each script.
- Resolve relative paths from `SCRIPT_DIR`; avoid fragile `pwd` assumptions.
- Typical wiring pattern:

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/core.sh"
```

## 3) Naming and Types

- Functions: `snake_case` (`install_config_files`, `run_installation`).
- Local variables: `lower_snake_case` and declare with `local`.
- Globals/constants/flags: `UPPER_CASE` (`DRY_RUN`, `DOTFILES_DIR`).
- Arrays: plural and intent-revealing names (`packages`, `failed`).
- Keep names concise and specific; avoid verbose boolean-style names.

## 4) Formatting and Structure

- Match existing file formatting (many shell files use tabs).
- Prefer multiline `if` and `case` blocks over dense one-liners.
- Keep functions single-purpose where practical.
- Avoid unnecessary wrappers for trivial behavior.
- Add comments only when they explain intent that code cannot show directly.

## 5) Error Handling and Logging

- In functions, prefer `return`; reserve `exit` for top-level script flow.
- Check dependencies with `command -v <cmd> >/dev/null 2>&1`.
- Reuse logging helpers from `packages/lib.sh`:
  - `log_info`
  - `log_success`
  - `log_warn`
  - `log_error`
  - `log_debug` (only meaningful when `DEBUG=true`)
- Avoid ad-hoc `echo` status lines when a logger exists.
- Error messages should include operation context and target.

## 6) Idempotency and Safety

- Assume install commands may run repeatedly.
- Preserve idempotency; avoid duplicate appends and unsafe rewrites.
- Respect `DRY_RUN=true`; do not mutate files in dry-run mode.
- Prefer existing helpers like `backup_if_exists` and `create_symlink`.

## 7) Platform-Aware Logic

- Reuse existing helpers instead of open-coding OS checks:
  - `detect_os`, `get_package_manager`, `is_macos`, `is_linux`
  - `is_omarchy`, `is_kool`, `is_gnome`, `is_hyprland`
- Keep cross-platform behavior aligned unless a task requires divergence.

## 8) Validation Workflow for Agent Changes

When editing this repo, do the smallest safe change and validate it.

1. Run `bash -n <changed-file>` for each touched shell file.
2. Run `make validate` for broader script/library edits.
3. Run a relevant dry-run, for example `./install --dry-run --config`.
4. Update docs when changing flags, profiles, or install behavior.

## Quick Completion Checklist

- Validation commands executed for touched scripts.
- No unrelated files modified.
- No secrets or credentials introduced.
- Dry-run path still works for changed flow.
