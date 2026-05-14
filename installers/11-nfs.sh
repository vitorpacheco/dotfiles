#!/usr/bin/env bash
#
# NFS client and server tools installation
# Supports: Ubuntu/Debian (apt), Arch Linux (yay/pacman), macOS (built-in)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../packages/lib.sh"

OS=$(detect_os) || {
	log_error "Unsupported operating system"
	exit 1
}

install_nfs() {
	case "$OS" in
	ubuntu | debian)
		# nfs-common: client tools (mount.nfs, showmount, etc.)
		# nfs-kernel-server: server daemon (rpc.nfsd, exportfs, etc.)
		install_package nfs-common
		install_package nfs-kernel-server
		;;
	arch)
		# nfs-utils covers both client and server on Arch
		install_package nfs-utils
		;;
	macos)
		# NFS is built-in on macOS (nfsd, showmount, /etc/exports)
		log_info "macOS has built-in NFS support — no packages needed"
		log_info "Enable server with: sudo nfsd enable && sudo nfsd start"
		log_info "Configure exports in: /etc/exports"
		return 0
		;;
	*)
		log_error "Unsupported OS: $OS"
		exit 1
		;;
	esac

	log_success "NFS client and server tools installed"
}

main() {
	log_info "Installing NFS client and server tools (OS: $OS)..."
	install_nfs
}

main "$@"

# vi: ft=bash
