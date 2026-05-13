#!/usr/bin/env bash
#
# Configure iwd to prefer 5GHz WiFi over 2.4GHz (Omarchy only)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../packages/lib.sh"

if [[ ! -d "$HOME/.local/share/omarchy" ]] && [[ ! -f "/etc/omarchy-release" ]]; then
	log_info "Omarchy not detected, skipping WiFi 5GHz configuration"
	exit 0
fi

if ! command -v iwctl &>/dev/null; then
	log_info "iwd not found, skipping WiFi 5GHz configuration"
	exit 0
fi

IWD_CONF_DIR="/etc/iwd"
IWD_CONF="$IWD_CONF_DIR/main.conf"
SOURCE_CONF="$SCRIPT_DIR/../config-files/iwd/main.conf"

configure_wifi_5ghz() {
	log_info "Configuring iwd to prefer 5GHz WiFi..."

	if [[ ! -f "$SOURCE_CONF" ]]; then
		log_error "Source config not found: $SOURCE_CONF"
		exit 1
	fi

	sudo mkdir -p "$IWD_CONF_DIR"

	if [[ -f "$IWD_CONF" ]]; then
		# Merge: update or add BandModifier keys, preserve existing settings
		if grep -q "BandModifier2_4GHz\|BandModifier5GHz" "$IWD_CONF"; then
			log_info "Updating existing BandModifier settings in $IWD_CONF..."
			sudo sed -i \
				-e 's/^BandModifier2_4GHz=.*/BandModifier2_4GHz=0.4/' \
				-e 's/^BandModifier5GHz=.*/BandModifier5GHz=1.0/' \
				"$IWD_CONF"
		else
			log_info "Appending [Rank] section to existing $IWD_CONF..."
			sudo bash -c "cat >> '$IWD_CONF'" < "$SOURCE_CONF"
		fi
	else
		log_info "Installing iwd config to $IWD_CONF..."
		sudo cp "$SOURCE_CONF" "$IWD_CONF"
	fi

	log_info "Restarting iwd service..."
	sudo systemctl restart iwd
	log_success "WiFi 5GHz preference configured and iwd restarted"
}

configure_wifi_5ghz

# vi: ft=bash
