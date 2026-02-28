#!/usr/bin/env bash
#
# Go installation via mise
# Supports: All platforms (Linux, macOS)
#

set -euo pipefail

# Source shared library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

# Check if mise is available
if ! check_command mise; then
	log_error "mise is not installed. Please run installers first."
	exit 1
fi

# Initialize mise environment
init_mise_env || {
	log_error "Failed to initialize mise environment"
	exit 1
}

log_info "Installing Go via mise..."

if mise use -g go@latest; then
	log_success "Go installed successfully"

	# Verify installation
	if check_command go; then
		log_info "Go version: $(go version)"
	fi
else
	log_error "Failed to install Go"
	exit 1
fi

# vi: ft=bash
