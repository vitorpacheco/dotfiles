#!/usr/bin/env bash
#
# Flatpak application installation
# Note: Flatpak is Linux-only, this script will skip on macOS
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../packages/lib.sh"

# Flatpak is Linux-only
if is_macos; then
	log_warn "Flatpak is not available on macOS. GUI apps should be installed via Homebrew casks or manually."
	log_info "Equivalent macOS apps can be installed with: brew install --cask <app>"
	exit 0
fi

# Check if flatpak is installed
if ! check_command flatpak; then
	log_error "Flatpak is not installed. Please install it first."
	exit 1
fi

# Ensure flathub repository is added
if ! flatpak remote-list | grep -q flathub; then
	log_info "Adding Flathub repository..."
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# List of Flatpak apps to install
FLATPAK_APPS=(
	"md.obsidian.Obsidian"
	"app.zen_browser.zen"
	"org.telegram.desktop"
	"com.discordapp.Discord"
	"com.getpostman.Postman"
	"com.valvesoftware.Steam"
	"com.bitwarden.desktop"
)

log_info "Installing Flatpak applications..."

for app in "${FLATPAK_APPS[@]}"; do
	# Extract app name for display
	app_name=$(echo "$app" | cut -d'.' -f3-)

	if flatpak list | grep -q "^$app"; then
		log_warn "$app_name is already installed"
		track_install "$app" "skipped"
	else
		log_info "Installing $app_name..."
		if flatpak install -y flathub "$app"; then
			log_success "Installed $app_name"
			track_install "$app" "success"
		else
			log_error "Failed to install $app_name"
			track_install "$app" "failed"
		fi
	fi
done

print_summary

# vi: ft=bash
