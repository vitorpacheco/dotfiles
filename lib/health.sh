#!/usr/bin/env bash
#
# Health and restore module for install script
# Provides: installation health checks, backup restoration
#

# Source core module
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/core.sh"

# --- Check Installation Health ---
check_installation_health() {
	log_info "Checking installation health..."

	local issues=0

	# Check all symlinks in ~/.config
	if [[ -d "$CONFIG_DIR" ]]; then
		for item in "$CONFIG_DIR"/*; do
			if [[ -L "$item" ]]; then
				local target
				target=$(readlink "$item")
				if [[ ! -e "$target" ]]; then
					log_error "Broken symlink: $item -> $target"
					issues=$((issues + 1))
				else
					log_debug "Valid symlink: $item -> $target"
				fi
			fi
		done
	fi

	# Check symlinks in home directory
	for item in "$HOME"/.[^.]*; do
		if [[ -L "$item" ]]; then
			local target
			target=$(readlink "$item")
			if [[ "$target" == "$DOTFILES_DIR"* ]] && [[ ! -e "$target" ]]; then
				log_error "Broken dotfile symlink: $item -> $target"
				issues=$((issues + 1))
			fi
		fi
	done

	# Check local scripts
	if [[ -d "$LOCAL_SCRIPTS_DIR" ]]; then
		for item in "$LOCAL_SCRIPTS_DIR"/*; do
			if [[ -L "$item" ]]; then
				local target
				target=$(readlink "$item")
				if [[ ! -e "$target" ]]; then
					log_error "Broken script symlink: $item -> $target"
					issues=$((issues + 1))
				fi
			fi
		done
	fi

	# Check for manual modifications (if checksum file exists)
	if [[ -f "$CHECKSUM_FILE" ]]; then
		log_info "Checking for manual modifications..."
		while IFS= read -r line; do
			local file_path stored_checksum
			file_path=$(echo "$line" | cut -d' ' -f2)
			stored_checksum=$(echo "$line" | cut -d' ' -f1)

			if [[ -f "$file_path" ]] && [[ ! -L "$file_path" ]]; then
				local current_checksum
				if command -v md5sum >/dev/null 2>&1; then
					current_checksum=$(md5sum "$file_path" | cut -d' ' -f1)
				elif command -v md5 >/dev/null 2>&1; then
					current_checksum=$(md5 -q "$file_path")
				fi

				if [[ "$current_checksum" != "$stored_checksum" ]]; then
					log_warn "Manual modification detected: $file_path"
				fi
			fi
		done <"$CHECKSUM_FILE"
	fi

	if [[ $issues -eq 0 ]]; then
		log_success "Installation health check passed - no issues found"
	else
		log_error "Installation health check found $issues issue(s)"
	fi

	return $issues
}

# --- Restore Backups ---
restore_backups() {
	log_info "Restoring backed up files..."

	local restored=0

	# Restore config backups
	if [[ -d "$CONFIG_DIR" ]]; then
		for backup in "$CONFIG_DIR"/_*.backup*; do
			if [[ -e "$backup" ]]; then
				local original_name dest
				original_name=$(basename "$backup" | sed 's/^_//' | sed 's/\.backup.*$//')
				dest="$CONFIG_DIR/$original_name"

				if [[ "$DRY_RUN" == true ]]; then
					log_info "[DRY-RUN] Would restore: $backup -> $dest"
				else
					[[ -L "$dest" ]] && rm "$dest"
					mv "$backup" "$dest"
					log_success "Restored: $original_name"
					restored=$((restored + 1))
				fi
			fi
		done
	fi

	# Restore home directory backups
	for backup in "$HOME"/._*.backup*; do
		if [[ -e "$backup" ]]; then
			local original_name dest
			original_name=$(basename "$backup" | sed 's/^\.//' | sed 's/_//' | sed 's/\.backup.*$//')
			dest="$HOME/.$original_name"

			if [[ "$DRY_RUN" == true ]]; then
				log_info "[DRY-RUN] Would restore: $backup -> $dest"
			else
				[[ -L "$dest" ]] && rm "$dest"
				mv "$backup" "$dest"
				log_success "Restored: .$original_name"
				restored=$((restored + 1))
			fi
		fi
	done

	# Restore script backups
	if [[ -d "$LOCAL_SCRIPTS_DIR" ]]; then
		for backup in "$LOCAL_SCRIPTS_DIR"/_*.backup*; do
			if [[ -e "$backup" ]]; then
				local original_name dest
				original_name=$(basename "$backup" | sed 's/^_//' | sed 's/\.backup.*$//')
				dest="$LOCAL_SCRIPTS_DIR/$original_name"

				if [[ "$DRY_RUN" == true ]]; then
					log_info "[DRY-RUN] Would restore: $backup -> $dest"
				else
					[[ -L "$dest" ]] && rm "$dest"
					mv "$backup" "$dest"
					log_success "Restored script: $original_name"
					restored=$((restored + 1))
				fi
			fi
		done
	fi

	if [[ $restored -eq 0 ]]; then
		log_info "No backups found to restore"
	else
		log_success "Restored $restored file(s)"
	fi
}

# vi: ft=bash
