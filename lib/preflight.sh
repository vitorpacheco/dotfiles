#!/usr/bin/env bash
#
# Pre-flight checks module for install script
# Provides: OS detection, command checks, directory validation
#

# Source core module (provides variables and logging)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/core.sh"

# --- Shell Check ---
check_shell_is_zsh() {
	local current_shell
	current_shell="$(ps -p $$ -o comm= | tr -d '[:space:]')"
	local default_shell
	default_shell="${SHELL##*/}"

	if [[ "$current_shell" == "zsh" ]] || [[ "$default_shell" == "zsh" ]]; then
		log_success "Shell check passed (current: ${current_shell:-unknown}, default: ${default_shell:-unknown})"
		return 0
	fi

	log_warn "zsh is recommended for this setup (current: ${current_shell:-unknown}, default: ${default_shell:-unknown})"
	log_info "Continue as-is, or switch with: exec zsh"
	return 0
}

# --- Arch base-devel Check ---
ensure_base_devel_installed() {
	log_info "Checking base-devel package on Arch Linux..."

	local pkg_mgr
	pkg_mgr=$(get_package_manager)

	if [[ "$pkg_mgr" != "yay" && "$pkg_mgr" != "pacman" ]]; then
		log_error "No package manager found for Arch (yay or pacman required)"
		return 1
	fi

	# Check if base-devel is installed
	if pacman -Q base-devel &>/dev/null; then
		log_success "base-devel is already installed"
		return 0
	fi

	# Auto-install base-devel
	log_info "base-devel not found. Auto-installing..."

	if [[ "$DRY_RUN" == true ]]; then
		log_info "[DRY-RUN] Would install base-devel package group"
		return 0
	fi

	if [[ "$pkg_mgr" == "yay" ]]; then
		yay -S --noconfirm base-devel || {
			log_error "Failed to install base-devel via yay"
			return 1
		}
	else
		sudo pacman -S --noconfirm base-devel || {
			log_error "Failed to install base-devel via pacman"
			return 1
		}
	fi

	log_success "base-devel installed successfully"
	return 0
}

# --- Pre-flight Checks ---
run_preflight_checks() {
	log_info "Running pre-flight checks..."

	local errors=0
	local warnings=0

	# Check if running in zsh shell
	check_shell_is_zsh || errors=$((errors + 1))

	# Check OS
	local os
	if ! os=$(detect_os 2>/dev/null); then
		log_warn "Unknown or unsupported OS detected"
		log_info "Continuing anyway..."
		os="unknown"
		warnings=$((warnings + 1))
	fi

	log_info "Detected OS: $os"

	case "$os" in
	ubuntu | debian | arch | macos)
		log_success "OS is supported: $os"
		;;
	unknown)
		log_warn "OS detection failed - some features may not work"
		;;
	*)
		log_warn "OS may not be fully supported: $os"
		warnings=$((warnings + 1))
		;;
	esac

	# Ensure base-devel is installed on Arch Linux
	if [[ "$os" == "arch" ]]; then
		ensure_base_devel_installed || errors=$((errors + 1))
	fi

	# Check essential commands
	local required_commands=("git" "bash" "ln")
	for cmd in "${required_commands[@]}"; do
		if ! check_command "$cmd"; then
			log_error "Required command not found: $cmd"
			errors=$((errors + 1))
		else
			log_debug "Found required command: $cmd"
		fi
	done

	# Check if in git repo
	if [[ ! -d "$DOTFILES_DIR/.git" ]]; then
		log_warn "Not a git repository. Some features may not work."
		warnings=$((warnings + 1))
	fi

	# Check dotfiles directory structure
	for dir in "config-files" "user-files" "scripts"; do
		if [[ ! -d "$DOTFILES_DIR/$dir" ]]; then
			log_error "Required directory not found: $dir"
			errors=$((errors + 1))
		fi
	done

	if [[ $errors -gt 0 ]]; then
		log_error "Pre-flight checks failed with $errors error(s). Please fix the issues above."
		exit 1
	fi

	if [[ $warnings -gt 0 ]]; then
		log_warn "Pre-flight checks completed with $warnings warning(s)"
	else
		log_success "Pre-flight checks passed"
	fi
}

# vi: ft=bash
