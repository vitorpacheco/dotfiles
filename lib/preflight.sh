#!/usr/bin/env bash
#
# Pre-flight checks module for install script
# Provides: OS detection, command checks, directory validation
#

# Source core module (provides variables and logging)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/core.sh"

# --- Pre-flight Checks ---
run_preflight_checks() {
	log_info "Running pre-flight checks..."

	local errors=0
	local warnings=0

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
