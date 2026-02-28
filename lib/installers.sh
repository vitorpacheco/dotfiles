#!/usr/bin/env bash
#
# Installers module for install script
# Provides: all installation functions for configs, apps, scripts
#

# Source core module
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/core.sh"

# --- Config Installation ---

install_nvim_config() {
	log_info "Updating nvim submodule..."

	if [[ "$DRY_RUN" == false ]]; then
		git submodule update --init --recursive config-files/nvim 2>/dev/null || log_warn "Failed to update nvim submodule"
	fi

	local nvim_source="$DOTFILES_DIR/config-files/nvim"
	local nvim_dest="$CONFIG_DIR/nvim"

	if [[ -e "$nvim_source" ]]; then
		create_symlink "$nvim_source" "$nvim_dest"
	else
		log_warn "Nvim config submodule not found at $nvim_source"
	fi
}

install_config_files() {
	log_info "Installing config files to $CONFIG_DIR..."
	mkdir -p "$CONFIG_DIR"

	for file in "$DOTFILES_DIR/config-files"/*; do
		if [[ -e "$file" ]]; then
			local dest="$CONFIG_DIR/$(basename "$file")"
			create_symlink "$file" "$dest"
		fi
	done
}

install_user_config_files() {
	log_info "Installing user config files to $HOME..."

	for file in "$DOTFILES_DIR/user-files"/*; do
		local basename_file
		basename_file=$(basename "$file")

		if [[ "$basename_file" == "." ]] || [[ "$basename_file" == ".." ]]; then
			continue
		fi

		if [[ "$basename_file" == ".git" ]] || [[ "$basename_file" == ".tmux" ]]; then
			continue
		fi

		if [[ -e "$file" ]]; then
			local dest="$HOME/.$basename_file"
			create_symlink "$file" "$dest"
		fi
	done
}

# --- Script Execution ---

execute_installers() {
	log_info "Executing installer scripts..."
	for script in "$DOTFILES_DIR/installers"/*.sh; do
		if [[ -f "$script" ]]; then
			if [[ "$DRY_RUN" == true ]]; then
				log_info "[DRY-RUN] Would execute: $(basename "$script")"
			else
				log_info "Executing $(basename "$script")..."
				bash "$script" || log_error "Failed to execute $(basename "$script")"
			fi
		fi
	done
}

install_packages() {
	log_info "Executing package installation scripts..."
	for script in "$DOTFILES_DIR/packages"/*.sh; do
		if [[ -f "$script" ]]; then
			if [[ "$DRY_RUN" == true ]]; then
				log_info "[DRY-RUN] Would execute: $(basename "$script")"
			else
				log_info "Executing $(basename "$script")..."
				bash "$script" || log_error "Failed to execute $(basename "$script")"
			fi
		fi
	done
}

install_apps() {
	log_info "Executing app installation scripts..."
	for script in "$DOTFILES_DIR/apps"/*.sh; do
		if [[ -f "$script" ]]; then
			if [[ "$DRY_RUN" == true ]]; then
				log_info "[DRY-RUN] Would execute: $(basename "$script")"
			else
				log_info "Executing $(basename "$script")..."
				bash "$script" || log_error "Failed to execute $(basename "$script")"
			fi
		fi
	done
}

install_gnome_scripts() {
	if is_macos; then
		log_info "GNOME scripts are Linux-only, skipping on macOS"
		return 0
	fi

	if is_gnome; then
		log_info "GNOME environment detected. Executing GNOME-specific scripts..."
		for script in "$DOTFILES_DIR/gnome"/*.sh; do
			if [[ -f "$script" ]]; then
				if [[ "$DRY_RUN" == true ]]; then
					log_info "[DRY-RUN] Would execute: $(basename "$script")"
				else
					log_info "Executing $(basename "$script")..."
					bash "$script" || log_error "Failed to execute $(basename "$script")"
				fi
			fi
		done
	else
		log_info "GNOME environment not detected. Skipping GNOME-specific scripts."
	fi
}

install_icons() {
	if is_macos; then
		log_info "Icon installation is Linux-only, skipping on macOS"
		return 0
	fi

	log_info "Executing icons installation script..."
	if [[ -f "$DOTFILES_DIR/icons/install.sh" ]]; then
		if [[ "$DRY_RUN" == true ]]; then
			log_info "[DRY-RUN] Would execute: icons/install.sh"
		else
			bash "$DOTFILES_DIR/icons/install.sh" || log_error "Failed to execute icons/install.sh"
		fi
	else
		log_warn "Icon installation script not found"
	fi
}

copy_local_scripts() {
	log_info "Symlinking local scripts to $LOCAL_SCRIPTS_DIR..."
	mkdir -p "$LOCAL_SCRIPTS_DIR"
	for script in "$DOTFILES_DIR/scripts"/*; do
		if [[ -e "$script" ]]; then
			local dest="$LOCAL_SCRIPTS_DIR/$(basename "$script")"
			create_symlink "$script" "$dest"
			if [[ "$DRY_RUN" == false ]]; then
				chmod +x "$dest" 2>/dev/null || true
			fi
		fi
	done
}

# --- Special Installations ---

install_omarchy_overrides() {
	if ! is_omarchy; then
		log_warn "Omarchy system not detected. Skipping Omarchy overrides."
		return 0
	fi

	log_info "Installing Omarchy overrides..."

	# Install tmux overrides
	local tmux_override_source="$DOTFILES_DIR/config-files/tmux/omarchy-overrides.conf"
	local tmux_override_dest="$CONFIG_DIR/tmux/omarchy-overrides.conf"
	local tmux_system_conf="$CONFIG_DIR/tmux/tmux.conf"

	if [[ -f "$tmux_override_source" ]]; then
		if [[ "$DRY_RUN" == true ]]; then
			log_info "[DRY-RUN] Would create symlink: omarchy-overrides.conf"
		else
			create_symlink "$tmux_override_source" "$tmux_override_dest"
		fi

		# Add source line to system tmux.conf
		if [[ -f "$tmux_system_conf" ]]; then
			local tmux_source_line='# Source Omarchy overrides
if-shell "[ -f ~/.config/tmux/omarchy-overrides.conf ]" "source-file ~/.config/tmux/omarchy-overrides.conf"'

			if ! grep -q "omarchy-overrides.conf" "$tmux_system_conf" 2>/dev/null; then
				if [[ "$DRY_RUN" == true ]]; then
					log_info "[DRY-RUN] Would add source line to $tmux_system_conf"
				else
					echo "" >>"$tmux_system_conf"
					echo "$tmux_source_line" >>"$tmux_system_conf"
					log_success "Added source line to tmux.conf"
				fi
			else
				log_info "Source line already present in tmux.conf"
			fi
		fi
	else
		log_warn "tmux overrides file not found"
	fi

	# Install hyprland overrides
	local hypr_override_source="$DOTFILES_DIR/config-files/hypr/omarchy-overrides.conf"
	local hypr_override_dest="$CONFIG_DIR/hypr/omarchy-overrides.conf"
	local hypr_system_conf="$CONFIG_DIR/hypr/hyprland.conf"

	if [[ -f "$hypr_override_source" ]]; then
		if [[ "$DRY_RUN" == true ]]; then
			log_info "[DRY-RUN] Would create symlink: omarchy-overrides.conf"
		else
			create_symlink "$hypr_override_source" "$hypr_override_dest"
		fi

		# Add source line to system hyprland.conf
		if [[ -f "$hypr_system_conf" ]]; then
			local hypr_source_line='# Source Omarchy overrides
source = ./omarchy-overrides.conf'

			if ! grep -q "omarchy-overrides.conf" "$hypr_system_conf" 2>/dev/null; then
				if [[ "$DRY_RUN" == true ]]; then
					log_info "[DRY-RUN] Would add source line to $hypr_system_conf"
				else
					echo "" >>"$hypr_system_conf"
					echo "$hypr_source_line" >>"$hypr_system_conf"
					log_success "Added source line to hyprland.conf"
				fi
			else
				log_info "Source line already present in hyprland.conf"
			fi
		fi
	else
		log_warn "hyprland overrides file not found"
	fi

	log_success "Omarchy overrides installation complete"
}

execute_utils() {
	local scripts_to_execute="$1"
	if [[ -z "$scripts_to_execute" ]]; then
		log_info "No specific utility scripts requested."
		return
	fi

	log_info "Executing selected utility scripts: $scripts_to_execute"
	IFS=',' read -ra ADDR <<<"$scripts_to_execute"
	for i in "${ADDR[@]}"; do
		local script_path="$DOTFILES_DIR/utils/$i"
		if [[ -f "$script_path" ]]; then
			if [[ "$DRY_RUN" == true ]]; then
				log_info "[DRY-RUN] Would execute: $i"
			else
				log_info "Executing $i..."
				bash "$script_path" || log_error "Failed to execute $i"
			fi
		else
			log_error "Utility script not found: $i"
		fi
	done
}

# vi: ft=bash
