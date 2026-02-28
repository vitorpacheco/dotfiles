#!/usr/bin/env bash
#
# Oh-My-Zsh installation
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

# Check if Oh-My-Zsh is already installed
if [[ -d "$HOME/.oh-my-zsh" ]]; then
	log_warn "Oh-My-Zsh is already installed"
	log_info "You can update it with: omz update"
	exit 0
fi

log_info "Installing Oh-My-Zsh..."

# Install using official installer
# Use RUNZSH=no to prevent automatically switching to zsh
# Use CHSH=no to prevent changing default shell
if RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; then
	log_success "Oh-My-Zsh installed successfully"
	log_info "To use Oh-My-Zsh, restart your terminal or run: zsh"
else
	log_error "Failed to install Oh-My-Zsh"
	exit 1
fi

# vi: ft=bash
