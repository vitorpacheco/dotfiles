#!/usr/bin/env bash
#
# Docker installation
# Supports: Ubuntu/Debian (apt), Arch (pacman/yay), macOS (brew)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../packages/lib.sh"

OS=$(detect_os)
log_info "Detected OS: $OS"

# Function to install Docker on Ubuntu/Debian
install_docker_debian() {
	log_info "Installing Docker on Ubuntu/Debian..."

	# Add Docker's official GPG key
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo wget -qO /etc/apt/keyrings/docker.asc https://download.docker.com/linux/ubuntu/gpg
	sudo chmod a+r /etc/apt/keyrings/docker.asc

	# Add the repository to Apt sources
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

	# Update and install
	sudo apt update
	sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras

	# Configure Docker
	configure_docker_linux
}

# Function to install Docker on Arch
install_docker_arch() {
	log_info "Installing Docker on Arch Linux..."

	local pkg_mgr
	pkg_mgr=$(get_package_manager)

	if [[ "$pkg_mgr" == "yay" ]]; then
		yay -S --noconfirm docker docker-compose docker-buildx
	else
		sudo pacman -S --noconfirm docker docker-compose docker-buildx
	fi

	# Configure Docker
	configure_docker_linux
}

# Function to configure Docker on Linux (user permissions, logging)
configure_docker_linux() {
	# Add user to docker group
	if ! groups "$USER" | grep -q docker; then
		log_info "Adding $USER to docker group..."
		sudo usermod -aG docker "$USER"
		log_warn "Please log out and log back in for docker group changes to take effect"
	fi

	# Configure log limits
	if [[ ! -f /etc/docker/daemon.json ]]; then
		log_info "Configuring Docker logging limits..."
		echo '{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"5"}}' | sudo tee /etc/docker/daemon.json
	fi

	# Enable and start Docker service
	log_info "Enabling Docker service..."
	sudo systemctl enable --now docker
}

# Function to install Docker on macOS
install_docker_macos() {
	log_info "Installing Docker on macOS..."

	check_macos_prerequisites || exit 1
	init_brew_env

	# On macOS, Docker Desktop is typically installed via cask
	if brew list --cask docker &>/dev/null; then
		log_warn "Docker Desktop is already installed"
	else
		log_info "Installing Docker Desktop..."
		if brew install --cask docker; then
			log_success "Docker Desktop installed"
			log_info "Please open Docker Desktop from Applications to complete setup"
		else
			log_error "Failed to install Docker Desktop"
			return 1
		fi
	fi

	# Also install docker CLI tools via formula
	if ! brew list docker &>/dev/null; then
		log_info "Installing Docker CLI..."
		brew install docker docker-compose
	fi
}

# Main installation logic
main() {
	# Check if Docker is already installed
	if check_command docker; then
		log_warn "Docker is already installed: $(docker --version)"

		# Still configure if on Linux and user not in group
		if is_linux && ! groups "$USER" | grep -q docker; then
			configure_docker_linux
		fi

		exit 0
	fi

	case "$OS" in
	ubuntu | debian)
		install_docker_debian
		;;
	arch)
		install_docker_arch
		;;
	macos)
		install_docker_macos
		;;
	*)
		log_error "Unsupported OS: $OS"
		exit 1
		;;
	esac

	# Verify installation
	if check_command docker; then
		log_success "Docker installed successfully: $(docker --version)"
	else
		log_error "Docker installation may have failed. Please check manually."
	fi
}

main "$@"

# vi: ft=bash
