#!/usr/bin/env bash
#
# XDG home directory setup — renames capitalized dirs to lowercase
# and creates any missing directories defined in user-dirs.dirs.
# Supports: Linux (Arch, Ubuntu/Debian)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../packages/lib.sh"

DRY_RUN=false
for arg in "$@"; do
	case "$arg" in
	--dry-run) DRY_RUN=true ;;
	esac
done

[[ "$DRY_RUN" == true ]] && log_info "Dry-run mode — no changes will be made"

# Directories to rename: OLD_NAME NEW_NAME
# Only the ones that exist on a typical fresh system with capital letters
declare -A RENAMES=(
	["Documents"]="documents"
	["Downloads"]="downloads"
	["Music"]="music"
	["Pictures"]="pictures"
	["Videos"]="videos"
	["Projects"]="projects"
	["Work"]="work"
)

# Directories to create if missing (no uppercase equivalent)
CREATE_IF_MISSING=("desktop" "templates" "public")

# --- Rename existing uppercase directories ---

for old in "${!RENAMES[@]}"; do
	new="${RENAMES[$old]}"
	old_path="$HOME/$old"
	new_path="$HOME/$new"

	if [[ -d "$new_path" ]]; then
		log_info "Already lowercase: ~/$new"
		continue
	fi

	if [[ ! -d "$old_path" ]]; then
		log_info "Not found, skipping: ~/$old"
		continue
	fi

	# Both uppercase and lowercase shouldn't exist simultaneously
	if [[ -d "$old_path" ]] && [[ -d "$new_path" ]]; then
		log_warn "Both ~/$old and ~/$new exist — skipping to avoid data loss. Merge manually."
		continue
	fi

	if [[ "$DRY_RUN" == true ]]; then
		log_info "[DRY-RUN] Would rename: ~/$old -> ~/$new"
	else
		mv "$old_path" "$new_path"
		log_success "Renamed: ~/$old -> ~/$new"
	fi
done

# --- Create missing directories ---

for dir in "${CREATE_IF_MISSING[@]}"; do
	dir_path="$HOME/$dir"
	if [[ -d "$dir_path" ]]; then
		log_info "Already exists: ~/$dir"
	elif [[ "$DRY_RUN" == true ]]; then
		log_info "[DRY-RUN] Would create: ~/$dir"
	else
		mkdir -p "$dir_path"
		log_success "Created: ~/$dir"
	fi
done

# --- Apply updated user-dirs config ---

if command -v xdg-user-dirs-update >/dev/null 2>&1; then
	if [[ "$DRY_RUN" == true ]]; then
		log_info "[DRY-RUN] Would run: xdg-user-dirs-update --force"
	else
		xdg-user-dirs-update --force
		log_success "Applied xdg-user-dirs config"
	fi
else
	log_warn "xdg-user-dirs-update not found — install xdg-user-dirs to apply the config"
fi

log_success "Directory setup complete."

# vi: ft=bash
