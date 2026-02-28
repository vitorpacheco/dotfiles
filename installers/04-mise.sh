#!/usr/bin/env bash
#
# Mise installation and setup
# Supports: Ubuntu/Debian, Arch, macOS
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../packages/lib.sh"

OS=$(detect_os)
log_info "Detected OS: $OS"

# Check if mise is already installed
if check_command mise; then
	log_warn "mise is already installed: $(mise --version)"
	exit 0
fi

# Function to install on Ubuntu/Debian
install_mise_debian() {
	log_info "Installing mise on Ubuntu/Debian..."

	# Add mise repository
	if [[ ! -f /etc/apt/sources.list.d/mise.list ]]; then
		log_info "Adding mise repository..."
		sudo install -dm 755 /etc/apt/keyrings
		wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1>/dev/null
		echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=$(dpkg --print-architecture)] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
		sudo apt update
	fi

	# Install mise
	if sudo apt install -y mise; then
		log_success "mise installed successfully"
	else
		log_error "Failed to install mise"
		return 1
	fi
}

# Function to install on Arch
install_mise_arch() {
	log_info "Installing mise on Arch Linux..."

	local pkg_mgr
	pkg_mgr=$(get_package_manager)

	if [[ "$pkg_mgr" == "yay" ]]; then
		if yay -S mise --noconfirm; then
			log_success "mise installed successfully"
		else
			log_error "Failed to install mise with yay"
			return 1
		fi
	else
		log_error "yay is required to install mise on Arch"
		log_info "Alternative: Install from AUR manually: https://aur.archlinux.org/packages/mise/"
		return 1
	fi
}

# Function to install on macOS
install_mise_macos() {
	log_info "Installing mise on macOS..."

	# Check if Homebrew is installed
	if ! check_command brew; then
		log_error "Homebrew is not installed. Please install it first with: ./install --installers"
		exit 1
	fi

	init_brew_env

	if brew install mise; then
		log_success "mise installed successfully"
	else
		log_error "Failed to install mise via Homebrew"
		return 1
	fi
}

# Main installation logic
case "$OS" in
ubuntu | debian)
	install_mise_debian
	;;
arch)
	install_mise_arch
	;;
macos)
	install_mise_macos
	;;
*)
	log_error "Unsupported OS: $OS"
	log_info "Please install mise manually: https://mise.jdx.dev/getting-started.html"
	exit 1
	;;
esac

# Verify installation
if check_command mise; then
	log_success "mise is ready to use: $(mise --version)"
	log_info "To activate mise, restart your terminal or run:"
	log_info "  eval \"\$(mise activate bash)\""
else
	log_error "mise installation may have failed. Please check manually."
	exit 1
fi

# vi: ft=bash
