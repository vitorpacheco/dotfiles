#!/usr/bin/env bash
#
# Oh-My-Zsh, plugins, and oh-my-posh installation
# Supports: All platforms (Linux, macOS)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../packages/lib.sh"

# Check if zsh is installed
if ! check_command zsh; then
	log_error "zsh is not installed. Please install it first via packages."
	exit 1
fi

# --- Oh-My-Zsh ---

if [[ -d "$HOME/.oh-my-zsh" ]]; then
	log_info "Oh-My-Zsh is already installed"
else
	log_info "Installing Oh-My-Zsh..."
	if RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; then
		log_success "Oh-My-Zsh installed"
	else
		log_error "Failed to install Oh-My-Zsh"
		exit 1
	fi
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# --- zsh-autosuggestions ---

if [[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
	log_info "zsh-autosuggestions already installed"
else
	log_info "Installing zsh-autosuggestions..."
	if git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
		"$ZSH_CUSTOM/plugins/zsh-autosuggestions"; then
		log_success "zsh-autosuggestions installed"
	else
		log_error "Failed to install zsh-autosuggestions"
	fi
fi

# --- zsh-syntax-highlighting ---

if [[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
	log_info "zsh-syntax-highlighting already installed"
else
	log_info "Installing zsh-syntax-highlighting..."
	if git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
		"$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"; then
		log_success "zsh-syntax-highlighting installed"
	else
		log_error "Failed to install zsh-syntax-highlighting"
	fi
fi

# --- oh-my-posh ---

if oh-my-posh --version &>/dev/null; then
	log_info "oh-my-posh already installed"
elif check_command brew; then
	log_info "Installing oh-my-posh via Homebrew..."
	if brew install jandedobbeleer/oh-my-posh/oh-my-posh; then
		log_success "oh-my-posh installed via Homebrew"
	else
		log_error "Failed to install oh-my-posh via Homebrew"
	fi
else
	log_info "Installing oh-my-posh via install script..."
	local_bin="$HOME/.local/bin"
	mkdir -p "$local_bin"
	if curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$local_bin"; then
		log_success "oh-my-posh installed to $local_bin"
	else
		log_error "Failed to install oh-my-posh"
	fi
fi

log_success "Oh-My-Zsh setup complete."

# vi: ft=bash
