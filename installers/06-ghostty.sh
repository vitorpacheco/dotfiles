#!/usr/bin/env bash
#
# Ghostty terminal installation
# Supports: Ubuntu (PPA), Arch Linux (AUR), macOS (Homebrew)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../packages/lib.sh"

OS=$(detect_os) || {
	log_error "Unsupported operating system"
	exit 1
}

log_info "Detected OS: $OS"

install_ghostty() {
	case "$OS" in
	ubuntu | debian)
		# Check if Ghostty is already installed
		if command -v ghostty &>/dev/null; then
			log_warn "Ghostty is already installed"
			return 0
		fi

		log_info "Installing Ghostty via snap..."

		# Install Ghostty using snap
		if ! command -v snap &>/dev/null; then
			log_error "snap is not installed. Please install snapd first:"
			log_info "sudo apt install snapd"
			exit 1
		fi

		# Install Ghostty via snap
		sudo snap install ghostty --classic

		log_success "Ghostty installed via snap"
		log_info "You may need to log out and back in for Ghostty to appear in your PATH"
		;;

	arch)
		# Check if Ghostty is already installed
		if command -v ghostty &>/dev/null; then
			log_warn "Ghostty is already installed"
			return 0
		fi

		log_info "Installing Ghostty via AUR..."

		# Check if yay is installed
		if ! command -v yay &>/dev/null; then
			log_error "yay is required to install Ghostty from AUR"
			exit 1
		fi

		# Install Ghostty from AUR
		yay -S --noconfirm ghostty

		log_success "Ghostty installed from AUR"
		;;

	macos)
		# Check if Ghostty is already installed
		if command -v ghostty &>/dev/null; then
			log_warn "Ghostty is already installed"
			return 0
		fi

		log_info "Installing Ghostty via Homebrew..."

		# Initialize brew environment
		if [[ -f /opt/homebrew/bin/brew ]]; then
			eval "$(/opt/homebrew/bin/brew shellenv)"
		elif [[ -f /usr/local/bin/brew ]]; then
			eval "$(/usr/local/bin/brew shellenv)"
		fi

		# Check if brew is available
		if ! command -v brew &>/dev/null; then
			log_error "Homebrew is not installed"
			exit 1
		fi

		# Install Ghostty via Homebrew
		brew install --cask ghostty

		log_success "Ghostty installed via Homebrew"
		;;

	*)
		log_error "Unsupported OS: $OS"
		exit 1
		;;
	esac
}

# Main execution
main() {
	log_info "Installing Ghostty terminal..."
	install_ghostty
	log_success "Ghostty installation complete!"
}

main "$@"

# vi: ft=bash
