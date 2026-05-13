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

	# Configs to skip when running on Omarchy (to preserve Omarchy's system configs)
	local omarchy_excluded_configs=("btop" "kitty" "ghostty" "hypr" "tmux")

	for file in "$DOTFILES_DIR/config-files"/*; do
		if [[ -e "$file" ]]; then
			local basename_file
			basename_file=$(basename "$file")

			# Skip Omarchy system configs when on Omarchy
			if is_omarchy; then
				for excluded in "${omarchy_excluded_configs[@]}"; do
					if [[ "$basename_file" == "$excluded" ]]; then
						log_info "[OMARCHY] Skipping $basename_file (preserving Omarchy system config)"
						continue 2
					fi
				done
			fi

			local dest="$CONFIG_DIR/$basename_file"
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
	log_info "Symlinking scripts directory to $LOCAL_SCRIPTS_DIR..."

	# Create parent directory only
	mkdir -p "$(dirname "$LOCAL_SCRIPTS_DIR")"

	# Handle existing directory or symlink
	if [[ -d "$LOCAL_SCRIPTS_DIR" ]] && [[ ! -L "$LOCAL_SCRIPTS_DIR" ]]; then
		# It's a real directory - backup it
		backup_if_exists "$LOCAL_SCRIPTS_DIR"
	elif [[ -L "$LOCAL_SCRIPTS_DIR" ]]; then
		# It's a symlink - remove it (will be replaced)
		if [[ "$DRY_RUN" == false ]]; then
			rm "$LOCAL_SCRIPTS_DIR"
		fi
	fi

	# Create symlink to the entire scripts directory
	create_symlink "$DOTFILES_DIR/scripts" "$LOCAL_SCRIPTS_DIR"
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

		# Install machine-specific hyprland config based on hostname
		local hypr_machine_source="$DOTFILES_DIR/config-files/hypr/machines/$(hostname).conf"
		local hypr_machine_dest="$CONFIG_DIR/hypr/machine.conf"

		if [[ -f "$hypr_machine_source" ]]; then
			if [[ "$DRY_RUN" == true ]]; then
				log_info "[DRY-RUN] Would create symlink: machine.conf -> $(hostname).conf"
			else
				create_symlink "$hypr_machine_source" "$hypr_machine_dest"
				log_success "Linked machine config for $(hostname)"
			fi
		else
			log_warn "No machine-specific hyprland config found for $(hostname)"
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

	# Install xcompose overrides
	install_xcompose_overrides

	log_success "Omarchy overrides installation complete"
}

install_kool_overrides() {
	# First check if Kool dotfiles are detected, but don't fail if not
	# (allow force install via flag)
	if ! is_kool && [[ "${INSTALL_KOOL_OVERRIDES:-false}" != true ]]; then
		log_warn "Kool Hyprland dotfiles not detected (no ~/.config/hypr/UserConfigs/)."
		log_info "Install Kool dotfiles first, or use --kool-overrides to force installation."
		return 0
	fi

	log_info "Installing Kool Hyprland overrides..."

	# Install Ghostty first (needed for terminal override)
	local ghostty_script="$SCRIPT_DIR/../installers/06-ghostty.sh"
	if [[ -f "$ghostty_script" ]]; then
		log_info "Installing Ghostty terminal..."
		bash "$ghostty_script" || log_warn "Ghostty installation may have failed"
	else
		log_warn "Ghostty installer not found at $ghostty_script"
	fi

	# Install tmux overrides
	local tmux_override_source="$DOTFILES_DIR/config-files/tmux/kool-overrides.conf"
	local tmux_override_dest="$CONFIG_DIR/tmux/kool-overrides.conf"
	local tmux_system_conf="$CONFIG_DIR/tmux/tmux.conf"

	if [[ -f "$tmux_override_source" ]]; then
		if [[ "$DRY_RUN" == true ]]; then
			log_info "[DRY-RUN] Would create symlink: kool-overrides.conf"
		else
			create_symlink "$tmux_override_source" "$tmux_override_dest"
		fi

		# Add source line to system tmux.conf
		if [[ -f "$tmux_system_conf" ]]; then
			local tmux_source_line='# Source Kool overrides
if-shell "[ -f ~/.config/tmux/kool-overrides.conf ]" "source-file ~/.config/tmux/kool-overrides.conf"'

			if ! grep -q "kool-overrides.conf" "$tmux_system_conf" 2>/dev/null; then
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
	local hypr_override_source="$DOTFILES_DIR/config-files/hypr/kool-overrides.conf"
	local hypr_override_dest="$CONFIG_DIR/hypr/kool-overrides.conf"
	local hypr_system_conf="$CONFIG_DIR/hypr/hyprland.conf"

	if [[ -f "$hypr_override_source" ]]; then
		if [[ "$DRY_RUN" == true ]]; then
			log_info "[DRY-RUN] Would create symlink: kool-overrides.conf"
		else
			create_symlink "$hypr_override_source" "$hypr_override_dest"
		fi

		# Add source line to system hyprland.conf
		if [[ -f "$hypr_system_conf" ]]; then
			local hypr_source_line='# Source Kool overrides
source = ./kool-overrides.conf'

			if ! grep -q "kool-overrides.conf" "$hypr_system_conf" 2>/dev/null; then
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

	# Install Waybar configuration symlinks (Kool-specific)
	local waybar_conf_source="$DOTFILES_DIR/config-files/waybar/kool-waybar.conf"

	# Check if waybar override config exists
	if [[ ! -f "$waybar_conf_source" ]]; then
		log_info "Waybar override config not found, skipping waybar setup"
	else
		local waybar_configs_dir="$CONFIG_DIR/waybar/configs"
		local waybar_styles_dir="$CONFIG_DIR/waybar/style"
		local waybar_config_link="$CONFIG_DIR/waybar/config"
		local waybar_style_link="$CONFIG_DIR/waybar/style.css"

		# Read waybar preferences from kool-waybar.conf if it exists
		local waybar_config_name=""
		local waybar_style_name=""

		# Extract waybar config from the waybar config file
		waybar_config_name=$(grep -E '^WAYBAR_CONFIG=' "$waybar_conf_source" | head -1 | sed 's/^WAYBAR_CONFIG="\(.*\)"/\1/' | tr -d '"')
		waybar_style_name=$(grep -E '^WAYBAR_STYLE=' "$waybar_conf_source" | head -1 | sed 's/^WAYBAR_STYLE="\(.*\)"/\1/' | tr -d '"')

		# Default fallback values if not set in config
		if [[ -z "$waybar_config_name" ]]; then
			waybar_config_name="[TOP] Default"
		fi
		if [[ -z "$waybar_style_name" ]]; then
			waybar_style_name="[Dark] Wallust Obsidian Edge.css"
		fi

		# Create waybar config symlink if configs directory exists
		if [[ -d "$waybar_configs_dir" ]]; then
			local waybar_config_target="$waybar_configs_dir/$waybar_config_name"

			if [[ -f "$waybar_config_target" ]]; then
				if [[ "$DRY_RUN" == true ]]; then
					log_info "[DRY-RUN] Would create waybar config symlink: $waybar_config_name"
				else
					backup_if_exists "$waybar_config_link"
					ln -sf "$waybar_config_target" "$waybar_config_link"
					log_success "Set waybar config to: $waybar_config_name"
				fi
			else
				log_warn "Waybar config not found: $waybar_config_name"
				log_info "Available configs in: $waybar_configs_dir"
			fi
		else
			log_info "Waybar configs directory not found, skipping waybar config setup"
		fi

		# Create waybar style symlink if styles directory exists
		if [[ -d "$waybar_styles_dir" ]]; then
			local waybar_style_target="$waybar_styles_dir/$waybar_style_name"

			if [[ -f "$waybar_style_target" ]]; then
				if [[ "$DRY_RUN" == true ]]; then
					log_info "[DRY-RUN] Would create waybar style symlink: $waybar_style_name"
				else
					backup_if_exists "$waybar_style_link"
					ln -sf "$waybar_style_target" "$waybar_style_link"
					log_success "Set waybar style to: $waybar_style_name"
				fi
			else
				log_warn "Waybar style not found: $waybar_style_name"
				log_info "Available styles in: $waybar_styles_dir"
			fi
		else
			log_info "Waybar styles directory not found, skipping waybar style setup"
		fi
	fi

	log_success "Kool Hyprland overrides installation complete"
}

install_hyprland_plugins() {
	if ! is_hyprland; then
		log_info "Hyprland not detected, skipping Hyprland plugins installation"
		return 0
	fi

	if ! command -v hyprpm >/dev/null 2>&1; then
		log_warn "hyprpm not found, skipping Hyprland plugins installation"
		return 0
	fi

	log_info "Installing Hyprland plugins via hyprpm..."

	if [[ "$DRY_RUN" == true ]]; then
		log_info "[DRY-RUN] Would add hyprland-plugins repository"
		log_info "[DRY-RUN] Would enable csgo-vulkan-fix plugin"
		return 0
	fi

	# Install hyprpm build dependencies before updating headers
	log_info "Installing hyprpm build dependencies..."
	local pkg_mgr
	pkg_mgr=$(get_package_manager)
	local deps=("cmake" "cpio" "git" "gcc")
	if [[ "$pkg_mgr" == "yay" || "$pkg_mgr" == "pacman" ]]; then
		deps+=("pkgconf")
	else
		deps+=("pkg-config" "g++")
	fi
	for dep in "${deps[@]}"; do
		install_package "$dep" || log_warn "Failed to install dependency: $dep"
	done

	# Always update headers first to avoid "Headers outdated" errors
	log_info "Updating hyprpm headers..."
	local hyprpm_out
	hyprpm_out=$(hyprpm update 2>&1)
	echo "$hyprpm_out"
	if echo "$hyprpm_out" | grep -q "Could not update"; then
		log_error "Failed to update hyprpm headers — check dependencies above"
		return 1
	fi
	log_success "hyprpm headers updated"

	# Add the hyprland-plugins repository if not already added
	if ! hyprpm list | grep -q "hyprland-plugins"; then
		log_info "Adding hyprland-plugins repository..."
		hyprpm add https://github.com/hyprwm/hyprland-plugins || {
			log_error "Failed to add hyprland-plugins repository"
			return 1
		}
		log_success "Added hyprland-plugins repository"
	else
		log_info "hyprland-plugins repository already added"
	fi

	# Enable the csgo-vulkan-fix plugin if not already enabled
	if ! hyprpm list | grep -q "csgo-vulkan-fix"; then
		log_info "Enabling csgo-vulkan-fix plugin..."
		hyprpm enable csgo-vulkan-fix || {
			log_error "Failed to enable csgo-vulkan-fix plugin"
			return 1
		}
		log_success "Enabled csgo-vulkan-fix plugin"
	else
		log_info "csgo-vulkan-fix plugin already enabled"
	fi

	log_success "Hyprland plugins installation complete"
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

execute_omarchy_installers() {
	log_info "Executing Omarchy installer scripts..."
	local selected=("00-zsh.sh" "01-tmux.sh" "03-homebrew.sh" "02-oh-my-zsh.sh" "07-git.sh" "08-setup-dirs.sh" "09-voxtype.sh")
	for script_name in "${selected[@]}"; do
		local script="$DOTFILES_DIR/installers/$script_name"
		if [[ -f "$script" ]]; then
			if [[ "$DRY_RUN" == true ]]; then
				log_info "[DRY-RUN] Would execute: $script_name"
			else
				log_info "Executing $script_name..."
				bash "$script" || log_error "Failed to execute $script_name"
			fi
		else
			log_warn "Installer not found: $script_name"
		fi
	done
}

# --- XCompose Overrides ---

install_xcompose_overrides() {
	if ! is_omarchy; then
		log_warn "Omarchy system not detected. Skipping xcompose overrides."
		return 0
	fi

	log_info "Installing xcompose overrides..."

	local xcompose_override_source="$DOTFILES_DIR/config-files/xcompose/xcompose-overrides.conf"
	local xcompose_override_dest="$CONFIG_DIR/omarchy/xcompose-overrides.conf"
	local omarchy_xcompose="$HOME/.local/share/omarchy/default/xcompose"

	if [[ ! -f "$xcompose_override_source" ]]; then
		log_warn "Xcompose overrides file not found: $xcompose_override_source"
		return 0
	fi

	# Create directory if needed
	mkdir -p "$(dirname "$xcompose_override_dest")"

	# Create symlink
	if [[ "$DRY_RUN" == true ]]; then
		log_info "[DRY-RUN] Would create symlink: $xcompose_override_dest"
	else
		create_symlink "$xcompose_override_source" "$xcompose_override_dest"
	fi

	# Add include to ~/.XCompose file
	local xcompose_file="$HOME/.XCompose"
	local include_line='include "%H/.config/omarchy/xcompose-overrides.conf"'

	if [[ -f "$xcompose_file" ]]; then
		if ! grep -q "xcompose-overrides.conf" "$xcompose_file" 2>/dev/null; then
			if [[ "$DRY_RUN" == true ]]; then
				log_info "[DRY-RUN] Would add include line to $xcompose_file"
			else
				echo "" >>"$xcompose_file"
				echo "# Include custom overrides from dotfiles" >>"$xcompose_file"
				echo "$include_line" >>"$xcompose_file"
				log_success "Added include to $xcompose_file"
			fi
		else
			log_info "Include already present in $xcompose_file"
		fi
	else
		log_warn "~/.XCompose not found"
	fi

	# Restart xcompose if available
	if [[ "$DRY_RUN" == false ]] && command -v omarchy-restart-xcompose &>/dev/null; then
		log_info "Restarting xcompose..."
		omarchy-restart-xcompose
	fi

	log_success "Xcompose overrides installed"
}

# --- macOS Configs ---

install_macos_configs() {
	if ! is_macos; then
		log_info "macOS configs are macOS-only, skipping on Linux"
		return 0
	fi

	log_info "Installing macOS-specific configs (yabai, skhd)..."

	# Install yabai config
	local yabai_source="$DOTFILES_DIR/config-files/yabai/yabairc"
	local yabai_dest="$HOME/.yabairc"

	if [[ -f "$yabai_source" ]]; then
		create_symlink "$yabai_source" "$yabai_dest"
		log_success "Installed yabai config"
	else
		log_warn "yabai config not found at $yabai_source"
	fi

	# Install skhd config
	local skhd_source="$DOTFILES_DIR/config-files/skhd/skhdrc"
	local skhd_dest="$HOME/.skhdrc"

	if [[ -f "$skhd_source" ]]; then
		create_symlink "$skhd_source" "$skhd_dest"
		log_success "Installed skhd config"
	else
		log_warn "skhd config not found at $skhd_source"
	fi
}

# vi: ft=bash
