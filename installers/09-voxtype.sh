#!/usr/bin/env bash
#
# Voxtype voice-to-text installation (Omarchy only)
# Downloads the large-v3-turbo universal model for multilingual support
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../packages/lib.sh"

OMARCHY_DIR="$HOME/.local/share/omarchy"

if [[ ! -d "$OMARCHY_DIR" ]] && [[ ! -f "/etc/omarchy-release" ]]; then
	log_info "Omarchy not detected, skipping Voxtype installation"
	exit 0
fi

install_voxtype() {
	if ! command -v voxtype &>/dev/null; then
		log_info "Installing voxtype-bin and wtype..."
		install_package wtype
		install_package voxtype-bin
	else
		log_info "voxtype is already installed"
	fi

	# Download large-v3-turbo model if not already present
	local model_path="$HOME/.local/share/voxtype/models/ggml-large-v3-turbo.bin"
	if [[ ! -f "$model_path" ]]; then
		log_info "Downloading large-v3-turbo universal model (~809MB)..."
		voxtype setup --download --model large-v3-turbo --no-post-install --quiet
		log_success "Model downloaded"
	else
		log_info "large-v3-turbo model already present"
	fi

	# Set up systemd user service if not already active
	if ! systemctl --user is-enabled voxtype.service &>/dev/null; then
		log_info "Setting up voxtype systemd user service..."
		voxtype setup systemd --quiet
		log_success "Voxtype systemd service enabled"
	else
		log_info "Voxtype systemd service already enabled"
	fi

	# Enable GPU acceleration if Vulkan is available (requires sudo)
	if command -v omarchy-hw-vulkan &>/dev/null && omarchy-hw-vulkan; then
		local gpu_status
		gpu_status=$(voxtype setup gpu --status 2>/dev/null || true)
		if echo "$gpu_status" | grep -q "Active backend: GPU"; then
			log_info "GPU acceleration already active"
		else
			log_info "Vulkan GPU detected, enabling GPU acceleration (requires sudo)..."
			if sudo voxtype setup gpu --enable; then
				systemctl --user restart voxtype.service || true
				log_success "GPU acceleration enabled and service restarted"
			else
				log_warn "GPU acceleration setup failed, continuing with CPU"
			fi
		fi
	fi
}

main() {
	log_info "Setting up Voxtype dictation (universal multilingual model)..."
	install_voxtype
	log_success "Voxtype installation complete"
}

main "$@"

# vi: ft=bash
