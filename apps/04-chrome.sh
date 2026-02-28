#!/usr/bin/env bash
#
# Google Chrome installation
# Supports: Ubuntu/Debian (.deb), Arch (AUR), macOS (brew)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../packages/lib.sh"

OS=$(detect_os)
log_info "Detected OS: $OS"

# Check if Chrome is already installed
check_existing() {
	if is_macos; then
		if [[ -d "/Applications/Google Chrome.app" ]] || brew list --cask google-chrome &>/dev/null; then
			log_warn "Google Chrome is already installed"
			return 0
		fi
	else
		if check_command google-chrome || check_command google-chrome-stable || check_command chrome; then
			log_warn "Google Chrome is already installed"
			return 0
		fi
	fi

	return 1
}

# Install on Ubuntu/Debian
install_chrome_debian() {
	log_info "Installing Google Chrome on Ubuntu/Debian..."

	cd /tmp

	# Download latest stable version
	log_info "Downloading Google Chrome..."
	if ! wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb; then
		log_error "Failed to download Google Chrome"
		return 1
	fi

	# Install the .deb package
	log_info "Installing package..."
	if sudo apt install -y ./google-chrome-stable_current_amd64.deb; then
		log_success "Google Chrome installed"
	else
		log_error "Failed to install Google Chrome"
		rm -f google-chrome-stable_current_amd64.deb
		return 1
	fi

	# Clean up
	rm -f google-chrome-stable_current_amd64.deb
	cd - >/dev/null
}

# Install on Arch Linux
install_chrome_arch() {
	log_info "Installing Google Chrome on Arch Linux..."

	local pkg_mgr
	pkg_mgr=$(get_package_manager)

	if [[ "$pkg_mgr" == "yay" ]]; then
		yay -S --noconfirm google-chrome
	else
		log_error "yay is required to install Google Chrome on Arch"
		log_info "Alternative: Use Flatpak: flatpak install flathub com.google.Chrome"
		exit 1
	fi
}

# Install on macOS
install_chrome_macos() {
	log_info "Installing Google Chrome on macOS..."

	check_macos_prerequisites || exit 1
	init_brew_env

	log_info "Installing Google Chrome via Homebrew..."
	if brew install --cask google-chrome; then
		log_success "Google Chrome installed"
	else
		log_error "Failed to install Google Chrome"
		return 1
	fi
}

# Main installation logic
main() {
	if check_existing; then
		exit 0
	fi

	case "$OS" in
	ubuntu | debian)
		install_chrome_debian
		;;
	arch)
		install_chrome_arch
		;;
	macos)
		install_chrome_macos
		;;
	*)
		log_error "Unsupported OS: $OS"
		exit 1
		;;
	esac

	log_success "Google Chrome installation complete!"
}

main "$@"

# vi: ft=bash
