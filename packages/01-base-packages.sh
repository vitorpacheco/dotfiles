#!/usr/bin/env bash
#
# Base system packages installation
# Supports: Ubuntu/Debian (apt), Arch Linux (yay), macOS (brew)
#

set -euo pipefail

# Source shared library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

# Detect OS
OS=$(detect_os) || {
	log_error "Unsupported operating system"
	exit 1
}

log_info "Detected OS: $OS"

# Define packages for each platform
declare -A UBUNTU_PACKAGES=(
	["build-essential"]="build tools"
	["gpg"]="GPG tools"
	["procps"]="process utilities"
	["file"]="file command"
	["zsh"]="Zsh shell"
	["git"]="Git"
	["git-delta"]="Git delta"
	["htop"]="process viewer"
	["rsync"]="file sync"
	["wget"]="download tool"
	["curl"]="URL tool"
	["unzip"]="archive utility"
	["zip"]="archive utility"
	["flameshot"]="screenshot tool"
	["gnome-tweaks"]="GNOME tweaks"
	["vlc"]="media player"
	["gnome-shell-extension-manager"]="GNOME extensions"
	["pipx"]="Python app installer"
	["fastfetch"]="system info"
	["rofi"]="launcher"
	["plocate"]="file locator"
	["nfs-common"]="NFS client"
)

declare -A ARCH_PACKAGES=(
	["base-devel"]="build tools"
	["procps-ng"]="process utilities"
	["file"]="file command"
	["zsh"]="Zsh shell"
	["git"]="Git"
	["git-delta"]="Git delta"
	["htop"]="process viewer"
	["rsync"]="file sync"
	["wget"]="download tool"
	["curl"]="URL tool"
	["unzip"]="archive utility"
	["zip"]="archive utility"
	["vlc"]="media player"
	["python-pipx"]="Python app installer"
	["fastfetch"]="system info"
	["rofi"]="launcher"
	["plocate"]="file locator"
	["nfs-utils"]="NFS client"
	["bat"]="cat alternative"
	["bitwarden-cli"]="password manager"
	["eza"]="ls alternative"
	["fd"]="find alternative"
	["fzf"]="fuzzy finder"
	["jq"]="JSON processor"
	["lazygit"]="Git TUI"
	["oh-my-posh"]="prompt"
	["spaceship-prompt"]="prompt"
	["tmux"]="terminal multiplexer"
	["neovim"]="editor"
	["lazydocker"]="Docker TUI"
	["btop"]="process viewer"
	["aws-cli-git"]="AWS CLI"
	["python"]="Python"
	["python-awscli-local"]="AWS CLI local"
	["jdtls"]="Java LSP"
	["luarocks"]="Lua package manager"
)

declare -A MACOS_PACKAGES=(
	["git"]="Git"
	["git-delta"]="Git delta"
	["zsh"]="Zsh shell"
	["htop"]="process viewer"
	["rsync"]="file sync"
	["wget"]="download tool"
	["curl"]="URL tool"
	["unzip"]="archive utility"
	["bat"]="cat alternative"
	["eza"]="ls alternative"
	["fd"]="find alternative"
	["fzf"]="fuzzy finder"
	["jq"]="JSON processor"
	["lazygit"]="Git TUI"
	["tmux"]="terminal multiplexer"
	["neovim"]="editor"
	["btop"]="process viewer"
	["awscli"]="AWS CLI"
	["python"]="Python"
	["pipx"]="Python app installer"
	["fastfetch"]="system info"
	["luarocks"]="Lua package manager"
	["bitwarden-cli"]="password manager"
)

# Function to add PPA on Ubuntu
add_ppa_if_needed() {
	local ppa="$1"
	local ppa_name="${ppa#*/}"

	if grep -r "$ppa" /etc/apt/sources.list /etc/apt/sources.list.d/ >/dev/null 2>&1; then
		log_warn "PPA '$ppa' is already configured"
	else
		log_info "Adding PPA: $ppa"
		sudo add-apt-repository -y "ppa:$ppa"
	fi
}

# Install packages based on OS
install_base_packages() {
	local -n packages
	local pkg_mgr

	pkg_mgr=$(get_package_manager)

	case "$OS" in
	ubuntu | debian)
		packages=UBUNTU_PACKAGES

		# Add fastfetch PPA if on Ubuntu
		if [[ "$OS" == "ubuntu" ]]; then
			add_ppa_if_needed "zhangsongcui3371/fastfetch"
		fi

		log_info "Updating package lists..."
		sudo apt update

		# Upgrade existing packages
		log_info "Upgrading existing packages..."
		sudo apt upgrade -y

		# Install each package
		for pkg in "${!packages[@]}"; do
			install_package "$pkg" || track_install "$pkg" "failed"
		done
		;;

	arch)
		packages=ARCH_PACKAGES

		if [[ "$pkg_mgr" != "yay" ]]; then
			log_error "yay is required but not installed"
			exit 1
		fi

		log_info "Updating system packages..."
		yay -Syu --noconfirm

		# Install each package
		for pkg in "${!packages[@]}"; do
			install_package "$pkg" || track_install "$pkg" "failed"
		done
		;;

	macos)
		packages=MACOS_PACKAGES

		# Check prerequisites
		check_macos_prerequisites || exit 1

		# Initialize brew environment
		init_brew_env

		log_info "Updating Homebrew..."
		brew update

		log_info "Upgrading existing packages..."
		brew upgrade || true

		# Install each package
		for pkg in "${!packages[@]}"; do
			if brew list "$pkg" &>/dev/null; then
				log_warn "$pkg is already installed"
			else
				log_info "Installing $pkg (${packages[$pkg]})..."
				if brew install "$pkg"; then
					log_success "Installed $pkg"
					track_install "$pkg" "success"
				else
					log_error "Failed to install $pkg"
					track_install "$pkg" "failed"
				fi
			fi
		done
		;;

	*)
		log_error "Unsupported OS: $OS"
		exit 1
		;;
	esac
}

# Main execution
main() {
	install_base_packages

	# Platform-specific notes
	if [[ "$OS" == "macos" ]]; then
		log_info "Note: GUI applications (flameshot, gnome-tweaks, etc.) are not available via Homebrew"
		log_info "Install them manually from App Store or vendor websites"
	fi

	print_summary
}

main "$@"

# vi: ft=bash
