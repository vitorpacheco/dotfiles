# Dotfiles Repository - Agent Guidelines

This repository manages personal dotfiles and system configuration for Linux (Ubuntu/Debian, Arch) environments.

## Build/Test/Install Commands

This is a dotfiles management repository with no formal build system. Use the main install script:

```bash
# Show help
./install --help

# Install specific components (use one or more flags)
./install --config          # Install config-files/ to ~/.config/
./install --user-config     # Install user-files/ to ~/
./install --packages        # Run package installation scripts
./install --installers      # Run installer scripts
./install --apps            # Run app installation scripts
./install --local-scripts   # Copy scripts/ to ~/.local/scripts/
./install --gnome           # Run GNOME-specific scripts (auto-detects DE)
./install --icons           # Run icons/install.sh
./install --utils="script.sh"  # Run specific utility from utils/

# Full installation (typical workflow)
./install --config --user-config --packages --installers --apps --local-scripts

# Update git submodules (nvim, tmux plugins)
git submodule update --init --recursive
```

## Code Style Guidelines

### Shell Scripts (bash)

**Shebang:** Use `#!/usr/bin/env bash` (preferred) or `#!/bin/bash`

**Error Handling:**
- Main install script uses `set -e` for strict error handling
- Scripts should check if commands exist: `command -v "$1" >/dev/null 2>&1`
- Use `||` for graceful fallbacks: `bash "$script" || log_error "Failed"`

**Naming Conventions:**
- Functions: `snake_case` (e.g., `install_config_files`, `show_help`)
- Constants/Environment: `UPPER_CASE` (e.g., `DOTFILES_DIR`, `CONFIG_DIR`)
- Local variables: `lower_case` (e.g., `script_path`, `current_dir`)

**Output/Logging:**
- Use color-coded logging functions:
  ```bash
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  NC='\033[0m'
  
  log_info() { echo -e "${YELLOW}[INFO] $1${NC}"; }
  log_success() { echo -e "${GREEN}[SUCCESS] $1${NC}"; }
  log_error() { echo -e "${RED}[ERROR] $1${NC}"; }
  ```
- Use prefixed tags: `[APT]`, `[YAY]`, `[TMUX]`, `[PKG]`, `[CONFIG-FILES]`

**Multi-Distro Support:**
- Check `/etc/os-release` for distro detection
- Support Ubuntu/Debian (apt) and Arch (yay) at minimum
- Use arrays for package lists: `UBUNTU_PACKAGES=(...)`, `ARCH_PACKAGES=(...)`

### Zsh Configuration

**File Organization:**
- Split into focused files: `envs`, `aliases`, `functions`, `binds`, `init`
- Platform-specific: `ubuntu`, `macos`, `omarchy`
- Main entry: `rc` sources all components

**Style:**
- Use `setopt` for configuration (not `set -o`)
- Aliases in `aliases` file, functions in `functions` file
- End files with: `# vi: ft=zsh`
- Use double brackets for conditionals: `[[ -d ~/.local/share/omarchy ]]`

### General File Patterns

**Config Files:**
- TOML: `config.toml`, `languages.toml`
- YAML: `config.yml`, `theme.yml`
- JSON: `settings.json`, `config.json`
- All config files end with vi modeline: `# vi: ft=<filetype>`

**Script Locations:**
- `apps/` - Application installers (Flatpak, Docker, VS Code, etc.)
- `installers/` - Tool setup scripts (tmux, oh-my-zsh, mise, etc.)
- `packages/` - System package installation
- `scripts/` - Utility scripts copied to ~/.local/scripts/
- `utils/` - One-off utility scripts
- `gnome/` - GNOME desktop configuration

## Testing

No formal test suite. Test scripts manually:
```bash
# Test a specific script
bash scripts/test-script.sh

# Dry-run package script (check for syntax errors)
bash -n packages/01-base-packages.sh

# Run install with single component
./install --config
```

## Git Workflow

- Only use git commands when explicitly requested by user
- Submodules: nvim config, tmux plugins - run `git submodule update --init --recursive`

## Important Notes

- Repository supports Ubuntu/Debian and Arch Linux primarily
- Uses Catppuccin Mocha theme consistently across tools
- Heavy focus on terminal/CLI tooling (tmux, zsh, fzf, Helix)
- Wayland/Hyprland oriented with extensive configs for waybar, rofi, swaync
- `set +h` in zsh rc disables command hashing for mise compatibility
- The `install` script is the main orchestrator - always use it for changes
