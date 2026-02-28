#!/usr/bin/env bash
#
# Node.js installation and npm packages
# Supports: All platforms (Linux, macOS)
#

set -euo pipefail

# Source shared library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

# Check if mise is available
if ! check_command mise; then
	log_error "mise is not installed. Please run installers first."
	exit 1
fi

# Initialize mise environment
init_mise_env || {
	log_error "Failed to initialize mise environment"
	exit 1
}

# Install Node.js
log_info "Installing Node.js via mise..."
if mise use -g node@latest; then
	log_success "Node.js installed successfully"
	log_info "Node version: $(node --version)"
else
	log_error "Failed to install Node.js"
	exit 1
fi

# Update npm
log_info "Updating npm..."
if npm install -g npm; then
	log_success "npm updated to version: $(npm --version)"
else
	log_warn "Failed to update npm"
fi

# Update package managers via corepack (preferred) or npm
update_package_manager() {
	local name="$1"
	local prepare_cmd="$2"

	if check_command corepack; then
		log_info "Updating $name via corepack..."
		if $prepare_cmd; then
			log_success "$name updated via corepack"
			return 0
		fi
	fi

	log_info "Updating $name via npm..."
	if npm install -g "$name"; then
		log_success "$name updated via npm"
		return 0
	fi

	log_error "Failed to update $name"
	return 1
}

# Update Yarn
update_package_manager "yarn" "corepack prepare yarn@stable --activate"

# Update pnpm
update_package_manager "pnpm" "corepack prepare pnpm@latest --activate"

# Global npm packages to install
NPM_PACKAGES=(
	"@anthropic-ai/claude-code"
	"@openai/codex"
	"skytrace"
	"artillery"
	"eas-cli"
)

log_info "Installing global npm packages..."

for pkg in "${NPM_PACKAGES[@]}"; do
	pkg_name=$(echo "$pkg" | awk -F'@' '{print $1}' | sed 's/^@//')

	if npm list -g --depth=0 "$pkg_name" &>/dev/null || npm list -g --depth=0 "$pkg" &>/dev/null; then
		log_warn "$pkg is already installed"
	else
		log_info "Installing $pkg..."
		if npm install -g "$pkg"; then
			log_success "Installed $pkg"
		else
			log_error "Failed to install $pkg"
		fi
	fi
done

log_info "Node.js environment setup complete!"

# vi: ft=bash
