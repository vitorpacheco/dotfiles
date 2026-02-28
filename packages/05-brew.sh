#!/usr/bin/env bash
#
# Homebrew formula/cask installation
# Supports: Linux and macOS
#

set -euo pipefail

# Source shared library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

# Check prerequisites
if is_macos; then
	check_macos_prerequisites || exit 1
fi

# Initialize Homebrew environment
if ! init_brew_env; then
	log_error "Homebrew is not installed or not in PATH"
	log_info "Please install Homebrew first: https://brew.sh"
	exit 1
fi

log_info "Homebrew detected at: $(which brew)"

# Update Homebrew
log_info "Updating Homebrew..."
brew update

# Upgrade existing packages
log_info "Upgrading existing Homebrew packages..."
brew upgrade || true

# Additional Homebrew packages (formulas from homebrew/Brewfile)
# These are CLI tools installed via Homebrew
ADDITIONAL_FORMULAS=(
	"bat"           # cat clone with syntax highlighting
	"bitwarden-cli" # password manager CLI
	"eza"           # modern ls replacement
	"fd"            # simple, fast alternative to find
	"fzf"           # command-line fuzzy finder
	"jq"            # JSON processor
	"lazygit"       # terminal UI for git
	"oh-my-posh"    # prompt theme engine
	"spaceship"     # Zsh prompt
	"tmux"          # terminal multiplexer
	"git-delta"     # syntax-highlighting pager for git
	"neovim"        # Vim-fork focused on extensibility
	"lazydocker"    # terminal UI for docker
	"btop"          # resource monitor
	"awscli"        # AWS CLI
	"awscli-local"  # AWS CLI for LocalStack
	"jdtls"         # Java language server
	"luarocks"      # Lua package manager
)

# Casks (GUI applications for macOS) - only on macOS
MACOS_CASKS=(
	# Add macOS GUI apps here
	# Examples (commented out - uncomment as needed):
	# "wezterm"        # terminal emulator
	# "alacritty"      # terminal emulator
	# "kitty"          # terminal emulator
	# "brave-browser"  # web browser
	# "firefox"        # web browser
	# "cursor"         # AI editor
	# "docker"         # Docker Desktop
	# "sublime-text"   # text editor
	# "iterm2"         # terminal emulator
)

# Install additional formulas
if [[ ${#ADDITIONAL_FORMULAS[@]} -gt 0 ]]; then
	log_info "Installing additional Homebrew formulas..."

	for formula in "${ADDITIONAL_FORMULAS[@]}"; do
		if brew list "$formula" &>/dev/null; then
			log_warn "$formula is already installed"
		else
			log_info "Installing $formula..."
			if brew install "$formula"; then
				log_success "Installed $formula"
			else
				log_error "Failed to install $formula"
			fi
		fi
	done
fi

# Install macOS casks (GUI applications)
if is_macos && [[ ${#MACOS_CASKS[@]} -gt 0 ]]; then
	log_info "Installing macOS GUI applications (casks)..."

	for cask in "${MACOS_CASKS[@]}"; do
		if brew list --cask "$cask" &>/dev/null; then
			log_warn "$cask is already installed"
		else
			log_info "Installing $cask..."
			if brew install --cask "$cask"; then
				log_success "Installed $cask"
			else
				log_error "Failed to install $cask"
			fi
		fi
	done
fi

# Cleanup
log_info "Cleaning up Homebrew..."
brew cleanup -s || true

log_info "Homebrew packages updated successfully!"

# vi: ft=bash
