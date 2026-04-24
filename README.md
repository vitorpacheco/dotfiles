# Dotfiles

Personal dotfiles repository for Linux (Ubuntu/Debian, Arch) and macOS environments.

## 🚀 Quick Start

```bash
# Clone the repository
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles

# Run full installation
./install --profile=full

# Or use make
make install-all
```

## 📋 Supported Platforms

- **Linux**
  - Ubuntu/Debian (apt)
  - Arch Linux (yay/pacman)
  - Hyprland with JaKooLit dotfiles (Ubuntu 25.10+)
- **macOS** (Apple Silicon & Intel)
  - Homebrew for package management

## 🛠️ Installation Options

### Profiles

```bash
# Minimal: Essential configs only (zsh, git, tmux, ghostty)
./install --profile=minimal

# Full: Everything (packages, apps, configs, installers)
./install --profile=full

# Omarchy: Configs + Omarchy-specific overrides (tmux, hyprland)
./install --profile=omarchy

# Kool: Configs + Kool Hyprland overrides (ghostty, hyprland, waybar)
./install --profile=kool
```

### Individual Components

```bash
# Install configuration files only
./install --config

# Install user configs to home directory
./install --user-config

# Run installer scripts (tmux, zsh, mise, ghostty, etc.)
./install --installers

# Install system packages
./install --packages

# Install applications (Docker, Chrome, etc.)
./install --apps

# Symlink local scripts
./install --local-scripts

# GNOME settings (Linux only)
./install --gnome

# Icon themes (Linux only)
./install --icons

# Omarchy overrides (Linux only)
./install --omarchy-overrides

# Kool Hyprland overrides (Linux only)
./install --kool-overrides

# Run specific utility scripts
./install --utils="check_ryzen_perf.sh,lombok.sh"
```

### Dry Run Mode

Preview changes without applying:

```bash
./install --dry-run --profile=full
```

## 📁 Repository Structure

```
.
├── install                 # Main installation script
├── Makefile               # Make targets for common tasks
├── lib/                   # Core library modules
│   ├── core.sh           # Core variables and utilities
│   ├── profiles.sh       # Profile handling and orchestration
│   ├── installers.sh     # Installation functions
│   ├── preflight.sh      # Pre-flight checks
│   └── health.sh         # Health check functions
├── packages/
│   ├── lib.sh            # Shared library (logging, OS detection)
│   ├── 01-base-packages.sh
│   ├── 02-go.sh
│   ├── 03-java.sh
│   ├── 04-node.sh
│   └── 05-brew.sh
├── installers/
│   ├── 01-tmux.sh
│   ├── 02-oh-my-zsh.sh
│   ├── 03-homebrew.sh
│   ├── 04-mise.sh
│   ├── 05-bat-themes.sh
│   └── 06-ghostty.sh     # Ghostty terminal installer
├── apps/
│   ├── 01-flatpak.sh     # Linux only
│   ├── 02-docker.sh
│   ├── 03-ollama.sh
│   └── 04-chrome.sh
├── config-files/         # Configuration files
│   ├── nvim/            # Neovim config (submodule)
│   ├── zsh/
│   ├── tmux/
│   │   ├── omarchy-overrides.conf    # Omarchy-specific tmux binds
│   │   └── kool-overrides.conf       # Kool-specific tmux binds
│   ├── hypr/
│   │   ├── omarchy-overrides.conf    # Omarchy Hyprland overrides
│   │   └── kool-overrides.conf       # Kool Hyprland overrides (Nord theme)
│   ├── waybar/
│   │   └── kool-waybar.conf          # Kool waybar layout/style config
│   ├── ghostty/
│   │   └── config                    # Universal ghostty config (Nord theme)
│   └── ...
├── user-files/          # Dotfiles for home directory
│   ├── zshrc
│   ├── gitconfig
│   └── tmux.conf
├── scripts/             # Utility scripts
│   ├── tmux-sessionizer # Tmux workspace selector
│   └── llm-server       # Local LLM server (llama.cpp wrapper with model registry, router, benchmark)
├── docs/                # Extra workflow documentation
│   └── git-alias-workflow.md
├── gnome/               # GNOME desktop settings (Linux)
├── icons/               # Icon themes (Linux)
└── utils/               # Additional utilities
```

## 📚 Documentation

- Git aliases and worktree flow: `docs/git-alias-workflow.md`

## 🤖 LLM Server

Local LLM server powered by llama.cpp with automatic model management:

```bash
# Setup llama.cpp (clone, build with CUDA/Metal)
llm-server setup

# Start a specific model
llm-server qwen3_5_u9b
llm-server qwen3_6
llm-server qwen3_6 --vision
llm-server gemma4_e4b_ggml

# Start router mode (small CPU + big GPU models)
llm-server router
llm-server router --vision              # Enable vision/multimodal
llm-server router --big qwen3_6         # Use Qwen3.6 35B-A3B
llm-server router --big gemma4_e4b_ggml # Use specific big model

# Benchmark a model
llm-server benchmark qwen3_5_u9b
```

**Available models:** qwen3_5_u9b, qwen3_5_u4b, qwen3_5_u2b, qwen3_5_u08b, qwen3_6, gemma4_e4b, gemma4_e4b_q8, gemma4_e4b_ggml, nemotron-nano, qwen3_coder_next, glm_4_7_flash

**Router mode:** Runs multiple models simultaneously with API-based routing—small model on CPU for fast autocompletion, big models on GPU for complex tasks. Ideal for IDE integrations like Continue.

## 🔧 What's Installed

### Base Packages

Essential command-line tools:

- **Shell & Tools**: zsh, tmux, git, git-delta, fzf, bat, eza, fd
- **System**: htop/btop, fastfetch, rofi, plocate
- **Terminal**: ghostty (Nord theme)
- **Development**: neovim, lazygit, lazydocker, jq
- **Cloud**: awscli, awscli-local
- **Prompt**: oh-my-posh, spaceship

### Development Environments

- **Go**: Latest version via mise
- **Java**: Zulu 21 via mise + Maven, Gradle, Quarkus, Spring Boot
- **Node.js**: Latest version via mise + npm, yarn, pnpm + global packages

### Applications

- **Development**: Docker, VS Code (via Homebrew on macOS), Ollama
- **Browsers**: Google Chrome, Zen Browser
- **Communication**: Discord, Telegram
- **Productivity**: Obsidian, Bitwarden
- **Media**: VLC, Steam

### Configuration Files

- **Zsh**: Full configuration with Oh-My-Zsh, theme, aliases, functions
- **Neovim**: Complete configuration (submodule)
- **Tmux**: TPM plugins, keybindings, status bar + sessionizer
- **Git**: Delta integration, aliases
- **Ghostty**: Universal terminal config with Nord theme (Omarchy compatible)
- **Rofi**: Application launcher
- **Waybar**: Status bar (Hyprland)

### Hyprland Support (Linux)

- **Omarchy Overrides**: Custom keybinds, window rules, input settings
- **Kool Overrides**: Omarchy-style keybinds + Nord theme + dual keyboard layout (us/br)
- **Waybar**: Layout and style configuration for Kool installations

## 🎨 Themes

The dotfiles support multiple themes consistently across tools:

### Catppuccin Mocha (Default)
- Terminal (legacy configs)
- Editor (Neovim, VS Code)
- Git (delta)

### Nord (Hyprland + Ghostty)
- **Hyprland**: Window borders, decorations, animations
- **Ghostty**: Terminal background, foreground, cursor
- **Waybar**: Status bar styling (with Kool integration)
- Color palette: Polar Night, Snow Storm, Frost, Aurora

### Omarchy Integration
On Omarchy systems, the theme is dynamically loaded from `~/.config/omarchy/current/theme/`.
On other systems (macOS, Ubuntu, Arch), the Nord theme is used as the default.

## 🔍 Maintenance Commands

```bash
# Check installation health
./install --check

# Restore backed up files
./install --restore

# Update nvim submodule
make update-nvim

# Update all submodules
make update-submodules

# Preview changes (dry run)
make dry-run

# Validate all script syntax
make validate

# Update waybar config (Kool)
# Edit: config-files/waybar/kool-waybar.conf
# Then run: ./install --kool-overrides
```

## 📝 Features

- **Cross-Platform**: Works on Ubuntu/Debian, Arch Linux, and macOS
- **Hyprland Support**: Omarchy and JaKooLit (Kool) dotfiles integration
- **Universal Terminal**: Ghostty with Nord theme, compatible with Omarchy
- **Waybar Config**: Automatic layout/style selection for Kool installations
- **Dual Keyboard Layout**: us + pt-br with compose key support
- **Dry Run Mode**: Preview all changes before applying
- **Backup System**: Automatically backs up existing files before overwriting
- **Health Check**: Verify installation integrity and detect broken symlinks
- **Modular**: Install only what you need
- **Idempotent**: Safe to run multiple times
- **Logging**: All actions logged to `~/.dotfiles-install.log`

## 🐧 Hyprland & Kool Support

This dotfiles repository provides enhanced support for Hyprland window manager configurations:

### Omarchy Integration
For [Omarchy](https://omarchy.io/) users:
- Detects Omarchy installation automatically
- Applies custom keybinds for tmux and hyprland
- Loads dynamic themes from `~/.config/omarchy/current/theme/`
- Adds web app launchers (Signal, Obsidian, etc.)

### JaKooLit (Kool) Integration
For [JaKooLit Hyprland dotfiles](https://github.com/JaKooLit) users:
- **Detection**: Automatically detects Kool installation via `~/.config/hypr/UserConfigs/`
- **Keybinds**: Omarchy-style keybinds (SUPER+W for close, SUPER+SPACE for rofi, etc.)
- **Theme**: Nord color scheme for hyprland decorations and borders
- **Terminal**: Ghostty with $term variable
- **File Manager**: Nautilus with $files variable
- **Editor**: Neovim (nvim) with $editor variable
- **Keyboard**: Dual layout (us + pt-br) with compose:caps
- **Waybar**: Automatic layout/style selection via `config-files/waybar/kool-waybar.conf`

### Usage

```bash
# Install Kool dotfiles first, then:
./install --profile=kool

# Or just the overrides (if you already have configs):
./install --kool-overrides

# Customize waybar:
# 1. Edit: config-files/waybar/kool-waybar.conf
# 2. Set: WAYBAR_CONFIG="[TOP] Default"
# 3. Set: WAYBAR_STYLE="[Dark] Wallust Obsidian Edge.css"
# 4. Run: ./install --kool-overrides
```

## 🐛 Troubleshooting

### macOS Specific

1. **Homebrew not found**: Install manually from https://brew.sh
2. **Xcode Command Line Tools**: Run `xcode-select --install`
3. **Apple Silicon PATH issues**: Ensure `/opt/homebrew/bin` is in PATH
4. **Ghostty installation**: Uses Homebrew cask on macOS

### Linux Specific

1. **yay not found (Arch)**: Install yay first: https://github.com/Jguer/yay
2. **Permission errors**: Some scripts require sudo (will prompt)
3. **GNOME settings not applying**: Ensure you're running a GNOME session
4. **Hyprland/Kool issues**: 
   - Ensure JaKooLit dotfiles are installed first
   - Check `~/.config/hypr/UserConfigs/` exists
   - Run `./install --kool-overrides` after Kool installation
5. **Ghostty installation (Ubuntu)**: Uses snap with `--classic` flag

### General

1. **Check log**: `cat ~/.dotfiles-install.log`
2. **Verify health**: `./install --check`
3. **Restore backups**: `./install --restore`
4. **Waybar config not applying**: Check `config-files/waybar/kool-waybar.conf` syntax

## 🤝 Contributing

Feel free to fork and adapt for your own use. Key principles:

1. Keep it modular
2. Support multiple platforms
3. Use the shared library for consistency
4. Add error handling with `set -euo pipefail`
5. Test with `--dry-run` first

## 📄 License

MIT License - See LICENSE file for details

## 🙏 Credits

- [Catppuccin](https://github.com/catppuccin) - Color scheme
- [Nord](https://www.nordtheme.com/) - Arctic color palette for Hyprland/Ghostty
- [Oh My Zsh](https://ohmyz.sh/) - Zsh framework
- [Homebrew](https://brew.sh/) - Package manager (macOS/Linux)
- [mise](https://mise.jdx.dev/) - Development environment manager
- [JaKooLit](https://github.com/JaKooLit) - Hyprland dotfiles inspiration
- [Ghostty](https://ghostty.org/) - Terminal emulator

---

**Note**: This is a personal dotfiles repository. Adapt configurations to suit your needs before running on your system.
