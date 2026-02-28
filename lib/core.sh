#!/usr/bin/env bash
#
# Core module for install script
# Provides: variables, utility functions, help
#

# Source shared library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/packages/lib.sh"

# --- Variables ---
DOTFILES_DIR="$SCRIPT_DIR"
CONFIG_DIR="$HOME/.config"
LOCAL_SCRIPTS_DIR="$HOME/.local/scripts"
LOG_FILE="$HOME/.dotfiles-install.log"
CHECKSUM_FILE="$CONFIG_DIR/.dotfiles-checksums"

# --- Flags ---
DRY_RUN=false
VERBOSE=false
PROFILE=""

# --- Help Function ---
show_help() {
	echo ""
	log_info "Dotfiles Installation Script"
	echo ""
	log_info "Usage: $(basename "$0") [OPTIONS]"
	echo ""
	log_info "Installs dotfiles and config files to your system."
	echo ""
	log_info "Options:"
	echo "  --help                       Show this help message and exit."
	echo "  --dry-run                    Preview changes without applying them."
	echo "  --verbose                    Enable verbose output."
	echo "  --profile=<minimal|full>     Use installation profile (minimal or full)."
	echo "  --check                      Verify installation health and report issues."
	echo "  --restore                    Restore all backed up files."
	echo ""
	log_info "Individual Installation Steps (use one or more):"
	echo "  --config             Install files from config-files/ to ~/.config/"
	echo "  --user-config        Install files/dirs from user-files/ to ~/"
	echo "  --installers         Execute scripts in installers/ (e.g., tmux, zsh, mise)"
	echo "  --packages           Execute scripts in packages/ (e.g., system packages)"
	echo "  --apps               Execute scripts in apps/ (e.g., Docker, Chrome)"
	echo "  --local-scripts      Symlink scripts from scripts/ to ~/.local/scripts/"
	echo "  --gnome              Execute scripts in gnome/ (GNOME desktop settings - Linux only)"
	echo "  --icons              Execute icons/install.sh (Linux only)"
	echo "  --omarchy-overrides  Install Omarchy-specific overrides only (tmux, hyprland)"
	echo ""
	log_info "Utility Scripts (from utils/):"
	echo "  --utils=\"script1.sh,script2.sh\" Execute specific utility scripts"
	echo ""
	log_info "Profiles:"
	echo "  --profile=minimal    Install only essential configs (zsh, git, tmux)"
	echo "  --profile=full       Install everything"
	echo "  --profile=omarchy    Install Omarchy overrides only (tmux, hyprland)"
	echo ""
	log_info "Platform Support:"
	echo "  - Linux (Ubuntu/Debian, Arch): Full support"
	echo "  - macOS: Most features supported (installers, packages, apps)"
	echo ""
	log_info "Examples:"
	echo "  ./install --dry-run --config        # Preview config installation"
	echo "  ./install --profile=minimal       # Minimal installation"
	echo "  ./install --profile=full          # Full installation"
	echo "  ./install --check                 # Check installation health"
	echo "  ./install --restore               # Restore backed up files"
	echo ""
}

# --- Utility Functions ---

backup_if_exists() {
	local path="$1"
	if [[ -e "$path" ]] && [[ ! -L "$path" ]]; then
		local backup_path="$(dirname "$path")/_$(basename "$path").backup"
		local counter=1
		while [[ -e "$backup_path" ]]; do
			backup_path="$(dirname "$path")/_$(basename "$path").backup.$counter"
			counter=$((counter + 1))
		done

		if [[ "$DRY_RUN" == true ]]; then
			log_info "[DRY-RUN] Would backup: $(basename "$path") -> $(basename "$backup_path")"
		else
			mv "$path" "$backup_path"
			log_info "Backed up: $(basename "$path") -> $(basename "$backup_path")"
		fi
	fi
}

create_symlink() {
	local source="$1"
	local dest="$2"

	if [[ "$DRY_RUN" == true ]]; then
		if [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "$source" ]]; then
			log_info "[DRY-RUN] Symlink already exists: $(basename "$dest")"
		else
			log_info "[DRY-RUN] Would create symlink: $(basename "$dest") -> $source"
		fi
	else
		if [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "$source" ]]; then
			log_success "Symlink already exists: $(basename "$dest")"
		else
			backup_if_exists "$dest"
			ln -s "$source" "$dest"
			log_success "Created symlink: $(basename "$dest")"
		fi
	fi
}

# --- Checksum Functions ---
update_checksums() {
	log_debug "Updating checksums..."
	mkdir -p "$CONFIG_DIR"
	>"$CHECKSUM_FILE"

	# Calculate checksums for all config files
	for file in "$DOTFILES_DIR/config-files"/*; do
		if [[ -f "$file" ]]; then
			local checksum
			if command -v md5sum >/dev/null 2>&1; then
				checksum=$(md5sum "$file" | cut -d' ' -f1)
			elif command -v md5 >/dev/null 2>&1; then
				checksum=$(md5 -q "$file")
			fi
			echo "$checksum $CONFIG_DIR/$(basename "$file")" >>"$CHECKSUM_FILE"
		fi
	done

	log_debug "Checksums saved to $CHECKSUM_FILE"
}

# --- Platform Detection ---
is_omarchy() {
	[[ -d "$HOME/.local/share/omarchy" ]] || [[ -f "/etc/omarchy-release" ]]
}

is_gnome() {
	[[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]] || [[ "$XDG_SESSION_DESKTOP" == *"gnome"* ]]
}

# Initialize log file
init_logging() {
	echo "=== Dotfiles Install Log - $(date) ===" >"$LOG_FILE"
}

# vi: ft=bash
