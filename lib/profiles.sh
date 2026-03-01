#!/usr/bin/env bash
#
# Profiles and orchestration module for install script
# Provides: argument parsing, profile handling, main execution logic
#

# Source all modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/core.sh"
source "$SCRIPT_DIR/lib/preflight.sh"
source "$SCRIPT_DIR/lib/health.sh"
source "$SCRIPT_DIR/lib/installers.sh"

# --- Installation Flags ---
INSTALL_CONFIG=false
INSTALL_USER_CONFIG=false
INSTALL_APPS=false
INSTALL_GNOME=false
INSTALL_ICONS=false
INSTALL_INSTALLERS=false
INSTALL_PACKAGES=false
INSTALL_LOCAL_SCRIPTS=false
INSTALL_OMARCHY_OVERRIDES=false
CHECK_HEALTH=false
RESTORE=false
UTILITY_SCRIPTS=""
SHOW_HELP=false

# --- Argument Parsing ---
parse_arguments() {
	for arg in "$@"; do
		case $arg in
		--help)
			SHOW_HELP=true
			;;
		--dry-run)
			DRY_RUN=true
			log_info "Dry-run mode enabled - no changes will be made"
			;;
		--verbose)
			VERBOSE=true
			export DEBUG=true
			;;
		--check)
			CHECK_HEALTH=true
			;;
		--restore)
			RESTORE=true
			;;
		--profile=*)
			PROFILE="${arg#*=}"
			;;
		--config)
			INSTALL_CONFIG=true
			;;
		--user-config)
			INSTALL_USER_CONFIG=true
			;;
		--apps)
			INSTALL_APPS=true
			;;
		--gnome)
			INSTALL_GNOME=true
			;;
		--icons)
			INSTALL_ICONS=true
			;;
		--installers)
			INSTALL_INSTALLERS=true
			;;
		--packages)
			INSTALL_PACKAGES=true
			;;
		--local-scripts)
			INSTALL_LOCAL_SCRIPTS=true
			;;
		--omarchy-overrides)
			INSTALL_OMARCHY_OVERRIDES=true
			;;
		--utils=*)
			UTILITY_SCRIPTS="${arg#*=}"
			;;
		*)
			log_error "Unknown argument: $arg"
			show_help
			exit 1
			;;
		esac
	done
}

# --- Profile Handling ---
apply_profile() {
	if [[ -z "$PROFILE" ]]; then
		return
	fi

	case $PROFILE in
	minimal)
		log_info "Using minimal profile"
		INSTALL_CONFIG=true
		INSTALL_USER_CONFIG=true
		INSTALL_LOCAL_SCRIPTS=true
		;;
	full)
		log_info "Using full profile"
		INSTALL_CONFIG=true
		INSTALL_USER_CONFIG=true
		INSTALL_INSTALLERS=true
		INSTALL_PACKAGES=true
		INSTALL_APPS=true
		INSTALL_LOCAL_SCRIPTS=true
		INSTALL_GNOME=true
		INSTALL_ICONS=true
		;;
	omarchy)
		log_info "Using omarchy profile - installing overrides only"
		INSTALL_OMARCHY_OVERRIDES=true
		INSTALL_LOCAL_SCRIPTS=true
		;;
	*)
		log_error "Unknown profile: $PROFILE. Use 'minimal' or 'full'"
		exit 1
		;;
	esac
}

# --- Main Execution ---
run_installation() {
	# Handle special commands
	if [[ "$SHOW_HELP" == true ]]; then
		show_help
		exit 0
	fi

	if [[ "$CHECK_HEALTH" == true ]]; then
		check_installation_health
		exit $?
	fi

	if [[ "$RESTORE" == true ]]; then
		restore_backups
		exit 0
	fi

	# Run pre-flight checks
	if [[ "$DRY_RUN" == false ]]; then
		run_preflight_checks
	fi

	# Apply profiles if specified
	apply_profile

	# Execute sections based on flags
	if [[ "$INSTALL_CONFIG" == true ]]; then
		install_nvim_config
		install_config_files
	fi

	if [[ "$INSTALL_USER_CONFIG" == true ]]; then
		install_user_config_files
	fi

	if [[ "$INSTALL_INSTALLERS" == true ]]; then
		execute_installers
	fi

	if [[ "$INSTALL_PACKAGES" == true ]]; then
		install_packages
	fi

	if [[ "$INSTALL_APPS" == true ]]; then
		install_apps
	fi

	if [[ "$INSTALL_GNOME" == true ]]; then
		install_gnome_scripts
	fi

	if [[ "$INSTALL_ICONS" == true ]]; then
		install_icons
	fi

	if [[ "$INSTALL_LOCAL_SCRIPTS" == true ]]; then
		copy_local_scripts
	fi

	if [[ "$INSTALL_OMARCHY_OVERRIDES" == true ]]; then
		install_omarchy_overrides
	fi

	execute_utils "$UTILITY_SCRIPTS"

	# Install Hyprland plugins if on Hyprland
	install_hyprland_plugins

	# Update checksums after installation
	if [[ "$DRY_RUN" == false ]] && [[ "$INSTALL_CONFIG" == true ]]; then
		update_checksums
	fi

	log_success "Dotfiles installation complete!"
	log_info "Log file saved to: $LOG_FILE"
}

# vi: ft=bash
