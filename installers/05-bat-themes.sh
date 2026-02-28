#!/usr/bin/env bash
#
# Bat themes installation (Tokyo Night theme)
# Supports: All platforms with bat installed
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../packages/lib.sh"

# Check if bat is installed
if ! check_command bat; then
	log_error "bat is not installed. Please install it first via packages."
	exit 1
fi

# Get bat config directory
BAT_CONFIG_DIR="$(bat --config-dir)"
THEME_DIR="$BAT_CONFIG_DIR/themes"
TMP_FOLDER="/tmp/bat-into-tokyonight"

# Check if theme is already installed
if [[ -d "$THEME_DIR/tokyonight.nvim" ]] || [[ -f "$THEME_DIR/tokyonight.nvim.tmTheme" ]]; then
	log_warn "Tokyo Night theme for bat is already installed"
	exit 0
fi

log_info "Installing Tokyo Night theme for bat..."

# Create themes directory
mkdir -p "$THEME_DIR"

# Clone and install the theme
if [[ -d "$TMP_FOLDER" ]]; then
	rm -rf "$TMP_FOLDER"
fi

if ! git clone --depth 1 https://github.com/0xTadash1/bat-into-tokyonight "$TMP_FOLDER" 2>/dev/null; then
	log_error "Failed to clone Tokyo Night theme repository"
	exit 1
fi

# Run the install script
cd "$TMP_FOLDER" || exit 1

# The bat-into-tokyonight script typically sets up themes
# Check if there's a theme file to copy
if [[ -f "bat-into-tokyonight.tmTheme" ]] || [[ -f "tokyonight.tmTheme" ]]; then
	# Copy theme files
	cp *.tmTheme "$THEME_DIR/" 2>/dev/null || true
	log_success "Tokyo Night theme files copied"
else
	log_info "Running bat-into-tokyonight setup script..."
	if bash ./bat-into-tokyonight >/dev/null 2>&1; then
		log_success "Tokyo Night theme installed via setup script"
	else
		log_warn "Setup script may have failed, attempting manual installation..."

		# Try to find and copy theme files
		find . -name "*.tmTheme" -exec cp {} "$THEME_DIR/" \; 2>/dev/null || true
	fi
fi

# Cleanup
cd - >/dev/null 2>&1 || true
rm -rf "$TMP_FOLDER"

# Rebuild bat cache to recognize new themes
log_info "Rebuilding bat cache..."
if bat cache --build 2>/dev/null; then
	log_success "Bat cache rebuilt"
else
	log_warn "Failed to rebuild bat cache automatically"
	log_info "You may need to run: bat cache --build"
fi

log_success "Tokyo Night theme for bat installed!"
log_info "To use it, add to your shell config: export BAT_THEME=\"tokyonight.nvim\""

# vi: ft=bash
