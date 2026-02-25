.PHONY: help install install-all install-config install-user update-nvim update-submodules check restore

# Default target
help:
	@echo "Dotfiles Management Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  make install         - Run the main install script (shows help)"
	@echo "  make install-all     - Install everything (config, user-config, packages, installers, apps, scripts)"
	@echo "  make install-config  - Install config files to ~/.config/"
	@echo "  make install-user    - Install user config files to ~/"
	@echo "  make install-minimal - Install minimal setup (config + user-config + scripts)"
	@echo "  make check           - Check installation health"
	@echo "  make restore         - Restore backed up files"
	@echo "  make update-nvim     - Update nvim submodule to latest commit"
	@echo "  make update-submodules - Update all git submodules"
	@echo "  make dry-run         - Preview changes without applying"
	@echo "  make help            - Show this help message"

# Main install script
install:
	./install --help

# Install everything
install-all:
	./install --profile=full

# Install minimal setup
install-minimal:
	./install --profile=minimal

# Install only config files (includes nvim submodule update)
install-config:
	./install --config

# Install only user config files
install-user:
	./install --user-config

# Check installation health
check:
	./install --check

# Restore backed up files
restore:
	./install --restore

# Dry-run preview
dry-run:
	./install --dry-run --profile=full

# Update nvim submodule to latest commit and commit the reference
update-nvim:
	@echo "Updating nvim submodule..."
	git submodule update --remote config-files/nvim
	git add config-files/nvim
	@git diff --cached --quiet && echo "No changes to commit" || git commit -m "Update nvim submodule to latest commit"
	@echo "Nvim submodule updated"

# Update all submodules
update-submodules:
	@echo "Updating all git submodules..."
	git submodule update --remote
	@for submodule in $$(git submodule | awk '{print $$2}'); do \
		git add "$$submodule" 2>/dev/null || true; \
	done
	@git diff --cached --quiet && echo "No changes to commit" || git commit -m "Update all submodules"
	@echo "All submodules updated"
