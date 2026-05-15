#!/usr/bin/env bash
#
# Speech Dispatcher installation
# Supports: Arch Linux (yay/pacman), Ubuntu/Debian (apt)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../packages/lib.sh"

OS=$(detect_os) || {
	log_error "Unsupported operating system"
	exit 1
}

main() {
	log_info "Installing speech-dispatcher (OS: $OS)..."

	case "$OS" in
	arch)
		install_package speech-dispatcher
		;;
	ubuntu | debian)
		install_package speech-dispatcher
		;;
	macos)
		log_info "speech-dispatcher is not available on macOS, skipping"
		return 0
		;;
	*)
		log_error "Unsupported OS: $OS"
		exit 1
		;;
	esac

	log_success "speech-dispatcher installed"
}

main "$@"

# vi: ft=bash
