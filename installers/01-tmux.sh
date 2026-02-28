#!/usr/bin/env bash
#
# Tmux configuration and plugin setup
# Supports: All platforms (Linux, macOS)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../packages/lib.sh"

# Check if tmux is installed
if ! check_command tmux; then
	log_error "tmux is not installed. Please install it first via packages."
	exit 1
fi

# Copy tmux configuration
TMUX_CONF_SOURCE="$SCRIPT_DIR/../../user-files/tmux.conf"
TMUX_CONF_DEST="$HOME/.tmux.conf"

if [[ -f "$TMUX_CONF_SOURCE" ]]; then
	if [[ -f "$TMUX_CONF_DEST" ]] && [[ ! -L "$TMUX_CONF_DEST" ]]; then
		backup_if_exists "$TMUX_CONF_DEST"
	fi
	cp "$TMUX_CONF_SOURCE" "$TMUX_CONF_DEST"
	log_success "Tmux configuration copied to ~/.tmux.conf"
else
	log_warn "tmux.conf not found at $TMUX_CONF_SOURCE"
fi

# Install TPM (Tmux Plugin Manager)
TARGET_DIR="$HOME/.tmux/plugins/tpm"

if [[ -d "$TARGET_DIR" ]]; then
	log_warn "TPM (Tmux Plugin Manager) is already installed"
else
	log_info "Installing TPM..."
	if git clone https://github.com/tmux-plugins/tpm "$TARGET_DIR"; then
		log_success "TPM installed successfully"
	else
		log_error "Failed to install TPM"
		exit 1
	fi
fi

# Reload tmux configuration if tmux is running
if pgrep tmux >/dev/null 2>&1; then
	log_info "Reloading tmux configuration..."
	tmux source-file "$TMUX_CONF_DEST" 2>/dev/null || log_warn "Failed to reload tmux config"
fi

# Install plugins
if [[ -f "$TARGET_DIR/bin/install_plugins" ]]; then
	log_info "Installing tmux plugins..."
	if "$TARGET_DIR/bin/install_plugins" >/dev/null 2>&1; then
		log_success "Tmux plugins installed"
	else
		log_warn "Some tmux plugins may not have installed correctly."
		log_info "You can install them manually with prefix + I in tmux."
	fi
else
	log_warn "TPM install script not found. Install plugins manually with prefix + I"
fi

log_success "Tmux setup complete!"

# vi: ft=bash
