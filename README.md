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
- **macOS** (Apple Silicon & Intel)
  - Homebrew for package management

## 🛠️ Installation Options

### Profiles

```bash
# Minimal: Essential configs only (zsh, git, tmux)
./install --profile=minimal

# Full: Everything (packages, apps, configs, installers)
./install --profile=full
```

### Individual Components

```bash
# Install configuration files only
./install --config

# Install user configs to home directory
./install --user-config

# Run installer scripts (tmux, zsh, mise, etc.)
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
│   └── 05-bat-themes.sh
├── apps/
│   ├── 01-flatpak.sh     # Linux only
│   ├── 02-docker.sh
│   ├── 03-ollama.sh
│   └── 04-chrome.sh
├── config-files/         # Configuration files
│   ├── nvim/            # Neovim config (submodule)
│   ├── zsh/
│   ├── tmux/
│   └── ...
├── user-files/          # Dotfiles for home directory
│   ├── zshrc
│   ├── gitconfig
│   └── ...
├── scripts/             # Utility scripts
├── gnome/               # GNOME desktop settings (Linux)
├── icons/               # Icon themes (Linux)
└── utils/               # Additional utilities
```

## 🔧 What's Installed

### Base Packages

Essential command-line tools:

- **Shell & Tools**: zsh, tmux, git, git-delta, fzf, bat, eza, fd
- **System**: htop/btop, fastfetch, rofi, plocate
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
- **Tmux**: TPM plugins, keybindings, status bar
- **Git**: Delta integration, aliases
- **Rofi**: Application launcher
- **Waybar**: Status bar (Hyprland)

## 🎨 Themes

The dotfiles use **Catppuccin Mocha** theme consistently across:

- Terminal (Alacritty)
- Editor (Neovim, VS Code)
- Launcher (Rofi)
- Status bar (Waybar)
- Git (delta)

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
```

## 📝 Features

- **Cross-Platform**: Works on Ubuntu/Debian, Arch Linux, and macOS
- **Dry Run Mode**: Preview all changes before applying
- **Backup System**: Automatically backs up existing files before overwriting
- **Health Check**: Verify installation integrity and detect broken symlinks
- **Modular**: Install only what you need
- **Idempotent**: Safe to run multiple times
- **Logging**: All actions logged to `~/.dotfiles-install.log`

## 🐛 Troubleshooting

### macOS Specific

1. **Homebrew not found**: Install manually from https://brew.sh
2. **Xcode Command Line Tools**: Run `xcode-select --install`
3. **Apple Silicon PATH issues**: Ensure `/opt/homebrew/bin` is in PATH

### Linux Specific

1. **yay not found (Arch)**: Install yay first: https://github.com/Jguer/yay
2. **Permission errors**: Some scripts require sudo (will prompt)
3. **GNOME settings not applying**: Ensure you're running a GNOME session

### General

1. **Check log**: `cat ~/.dotfiles-install.log`
2. **Verify health**: `./install --check`
3. **Restore backups**: `./install --restore`

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
- [Oh My Zsh](https://ohmyz.sh/) - Zsh framework
- [Homebrew](https://brew.sh/) - Package manager (macOS/Linux)
- [mise](https://mise.jdx.dev/) - Development environment manager

---

**Note**: This is a personal dotfiles repository. Adapt configurations to suit your needs before running on your system.
