#!/usr/bin/env bash
#
# Zsh installation and default shell setup
# Supports: All platforms (Linux, macOS)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../packages/lib.sh"

# Install zsh if not present
if ! check_command zsh; then
	log_info "Installing zsh..."
	install_package zsh
	log_success "zsh installed"
else
	log_info "zsh is already installed"
fi

# Set zsh as default shell if not already
ZSH_PATH="$(which zsh)"
if [[ "$SHELL" == "$ZSH_PATH" ]]; then
	log_info "zsh is already the default shell"
	exit 0
fi

log_info "Setting zsh as default shell..."

# Ensure zsh is listed in /etc/shells (required for chsh)
if ! grep -qF "$ZSH_PATH" /etc/shells; then
	log_info "Adding $ZSH_PATH to /etc/shells..."
	echo "$ZSH_PATH" | sudo tee -a /etc/shells
fi

chsh -s "$ZSH_PATH"
log_success "Default shell set to zsh ($ZSH_PATH). Takes effect on next login."

# vi: ft=bash
