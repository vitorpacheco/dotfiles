#!/usr/bin/env bash
#
# Shared library for package installation scripts
# Provides: logging, OS detection, package management helpers
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
	echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
	echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
	echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_warn() {
	echo -e "${YELLOW}[WARN]${NC} $1"
}

log_debug() {
	if [[ "${DEBUG:-false}" == "true" ]]; then
		echo -e "${BLUE}[DEBUG]${NC} $1"
	fi
}

# Legacy color functions (for backward compatibility with existing scripts calling green/yellow/red)
green() { log_success "$1"; }
yellow() { log_warn "$1"; }
red() { log_error "$1"; }

# OS Detection
detect_os() {
	if [[ "$OSTYPE" == "darwin"* ]]; then
		echo "macos"
		return 0
	fi

	if [[ -f /etc/os-release ]]; then
		source /etc/os-release
		case "$ID" in
		ubuntu | debian)
			echo "$ID"
			return 0
			;;
		arch)
			echo "arch"
			return 0
			;;
		*)
			echo "unknown"
			return 1
			;;
		esac
	fi

	echo "unknown"
	return 1
}

# Get package manager for current OS
get_package_manager() {
	local os
	os=$(detect_os)

	case "$os" in
	ubuntu | debian)
		if command -v apt >/dev/null 2>&1; then
			echo "apt"
			return 0
		fi
		;;
	arch)
		if command -v yay >/dev/null 2>&1; then
			echo "yay"
			return 0
		elif command -v pacman >/dev/null 2>&1; then
			echo "pacman"
			return 0
		fi
		;;
	macos)
		if command -v brew >/dev/null 2>&1; then
			echo "brew"
			return 0
		fi
		;;
	esac

	echo "none"
	return 1
}

# Get Homebrew prefix based on platform
get_brew_prefix() {
	if [[ "$OSTYPE" == "darwin"* ]]; then
		# macOS: Apple Silicon uses /opt/homebrew, Intel uses /usr/local
		if [[ "$(uname -m)" == "arm64" ]]; then
			echo "/opt/homebrew"
		else
			echo "/usr/local"
		fi
	else
		# Linux
		echo "/home/linuxbrew/.linuxbrew"
	fi
}

# Initialize Homebrew environment
init_brew_env() {
	local brew_prefix
	brew_prefix=$(get_brew_prefix)

	if [[ -f "$brew_prefix/bin/brew" ]]; then
		eval "$($brew_prefix/bin/brew shellenv)"
		return 0
	fi

	if command -v brew >/dev/null 2>&1; then
		eval "$(brew shellenv)"
		return 0
	fi

	return 1
}

# Platform checks
is_macos() {
	[[ "$OSTYPE" == "darwin"* ]]
}

is_linux() {
	[[ "$OSTYPE" == "linux"* ]]
}

# Check if command exists
check_command() {
	command -v "$1" >/dev/null 2>&1
}

# Check if package is installed (OS-specific)
is_package_installed() {
	local pkg="$1"
	local os pkg_mgr
	os=$(detect_os)
	pkg_mgr=$(get_package_manager)

	case "$pkg_mgr" in
	apt)
		dpkg -s "$pkg" >/dev/null 2>&1
		;;
	yay)
		yay -Q "$pkg" >/dev/null 2>&1
		;;
	pacman)
		pacman -Q "$pkg" >/dev/null 2>&1
		;;
	brew)
		brew list "$pkg" >/dev/null 2>&1
		;;
	*)
		return 1
		;;
	esac
}

# Install a single package (idempotent)
install_package() {
	local pkg="$1"
	local pkg_mgr
	pkg_mgr=$(get_package_manager)

	if is_package_installed "$pkg"; then
		log_warn "$pkg is already installed"
		return 0
	fi

	log_info "Installing $pkg..."

	case "$pkg_mgr" in
	apt)
		sudo apt update -qq && sudo apt install -y "$pkg"
		;;
	yay)
		yay -S --noconfirm "$pkg"
		;;
	pacman)
		sudo pacman -S --noconfirm "$pkg"
		;;
	brew)
		brew install "$pkg"
		;;
	*)
		log_error "No package manager available"
		return 1
		;;
	esac

	log_success "Installed $pkg"
}

# Install multiple packages
install_packages() {
	local packages=("$@")
	local failed=()

	for pkg in "${packages[@]}"; do
		if ! install_package "$pkg"; then
			failed+=("$pkg")
		fi
	done

	if [[ ${#failed[@]} -gt 0 ]]; then
		log_error "Failed to install: ${failed[*]}"
		return 1
	fi
}

# Update package lists
update_packages() {
	local pkg_mgr
	pkg_mgr=$(get_package_manager)

	log_info "Updating package lists..."

	case "$pkg_mgr" in
	apt)
		sudo apt update -qq
		;;
	yay)
		yay -Sy --noconfirm
		;;
	pacman)
		sudo pacman -Sy
		;;
	brew)
		brew update
		;;
	*)
		log_error "No package manager available"
		return 1
		;;
	esac
}

# Check macOS prerequisites
check_macos_prerequisites() {
	if ! is_macos; then
		return 0
	fi

	# Check for Xcode Command Line Tools
	if ! xcode-select -p >/dev/null 2>&1; then
		log_warn "Xcode Command Line Tools not found"
		log_info "Installing Xcode Command Line Tools..."
		xcode-select --install
		log_info "Please complete the installation and re-run this script"
		return 1
	fi

	# Check for Homebrew
	if ! command -v brew >/dev/null 2>&1; then
		log_warn "Homebrew not found"
		log_info "Please install Homebrew first: https://brew.sh"
		return 1
	fi

	return 0
}

# Initialize mise environment
init_mise_env() {
	if check_command mise; then
		eval "$(mise activate bash)"
		eval "$(mise activate --shims)"
		return 0
	fi
	return 1
}

# Installation tracking for summary
declare -a INSTALLED_PACKAGES=()
declare -a FAILED_PACKAGES=()
declare -a SKIPPED_PACKAGES=()

track_install() {
	local pkg="$1"
	local status="$2" # success|failed|skipped

	case "$status" in
	success)
		INSTALLED_PACKAGES+=("$pkg")
		;;
	failed)
		FAILED_PACKAGES+=("$pkg")
		;;
	skipped)
		SKIPPED_PACKAGES+=("$pkg")
		;;
	esac
}

# Print installation summary
print_summary() {
	echo ""
	log_info "=== Installation Summary ==="

	if [[ ${#INSTALLED_PACKAGES[@]} -gt 0 ]]; then
		log_success "Installed (${#INSTALLED_PACKAGES[@]}): ${INSTALLED_PACKAGES[*]}"
	fi

	if [[ ${#SKIPPED_PACKAGES[@]} -gt 0 ]]; then
		log_warn "Skipped (${#SKIPPED_PACKAGES[@]}): ${SKIPPED_PACKAGES[*]}"
	fi

	if [[ ${#FAILED_PACKAGES[@]} -gt 0 ]]; then
		log_error "Failed (${#FAILED_PACKAGES[@]}): ${FAILED_PACKAGES[*]}"
		return 1
	fi

	if [[ ${#INSTALLED_PACKAGES[@]} -eq 0 && ${#SKIPPED_PACKAGES[@]} -eq 0 ]]; then
		log_info "No packages were processed"
	fi

	return 0
}

# Get script directory (works even when sourced)
get_script_dir() {
	local source="${BASH_SOURCE[0]}"
	while [[ -L "$source" ]]; do
		local dir
		dir="$(cd "$(dirname "$source")" && pwd)"
		source="$(readlink "$source")"
		[[ $source != /* ]] && source="$dir/$source"
	done
	echo "$(cd "$(dirname "$source")" && pwd)"
}

# Ensure script is run from correct directory
cd_to_script_dir() {
	cd "$(get_script_dir)" || exit 1
}

# vi: ft=bash
