#!/usr/bin/env bash
#
# git-delta installation (syntax-highlighting pager for git)
# Supports: Arch Linux (yay/pacman), Ubuntu/Debian (apt), macOS (brew)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../packages/lib.sh"

OS=$(detect_os) || {
	log_error "Unsupported operating system"
	exit 1
}

main() {
	log_info "Installing git-delta (OS: $OS)..."

	case "$OS" in
	arch)
		install_package git-delta
		;;
	ubuntu | debian)
		install_package git-delta
		;;
	macos)
		install_package git-delta
		;;
	*)
		log_error "Unsupported OS: $OS"
		exit 1
		;;
	esac

	log_success "git-delta installed"
}

main "$@"

# vi: ft=bash
