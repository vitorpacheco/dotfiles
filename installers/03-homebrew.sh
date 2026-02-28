#!/usr/bin/env bash
#
# Homebrew installation
# Supports: Linux and macOS
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../packages/lib.sh"

# Get the correct brew prefix for the platform
BREW_PREFIX=$(get_brew_prefix)

# Check if Homebrew is already installed
if [[ -d "$BREW_PREFIX" ]] || check_command brew; then
	log_warn "Homebrew is already installed"

	if check_command brew; then
		log_info "Homebrew version: $(brew --version | head -n1)"
	fi

	exit 0
fi

log_info "Installing Homebrew..."
log_info "Platform: $(is_macos && echo "macOS" || echo "Linux")"
log_info "Install location: $BREW_PREFIX"

# Run the official installer
if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
	log_success "Homebrew installed successfully"

	# Initialize brew environment
	init_brew_env || {
		log_error "Failed to initialize Homebrew environment"
		log_info "Please restart your terminal and run: eval \"\$($(get_brew_prefix)/bin/brew shellenv)\""
		exit 1
	}

	# Verify installation
	if check_command brew; then
		log_info "Homebrew version: $(brew --version | head -n1)"
		log_success "Homebrew is ready to use!"
	fi
else
	log_error "Failed to install Homebrew"
	log_info "Please check https://brew.sh for manual installation instructions"
	exit 1
fi

# vi: ft=bash
