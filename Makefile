.PHONY: help install install-all update-nvim update-submodules

# Default target
help:
	@echo "Dotfiles Management Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  make install         - Run the main install script (shows help)"
	@echo "  make install-all     - Install everything (config, user-config, packages, installers, apps, scripts)"
	@echo "  make install-config  - Install config files to ~/.config/"
	@echo "  make install-user    - Install user config files to ~/"
	@echo "  make update-nvim     - Update nvim submodule to latest commit"
	@echo "  make update-submodules - Update all git submodules"
	@echo "  make help            - Show this help message"

# Main install script
install:
	./install --help

# Install everything
install-all:
	./install --config --user-config --packages --installers --apps --local-scripts

# Install only config files (includes nvim submodule update)
install-config:
	./install --config

# Install only user config files
install-user:
	./install --user-config

# Update nvim submodule to latest commit and commit the reference
update-nvim:
	@echo "Updating nvim submodule..."
	git submodule update --remote config-files/nvim
	git add config-files/nvim
	git diff --cached --quiet || git commit -m "Update nvim submodule to latest commit"
	@echo "Nvim submodule updated and committed"

# Update all submodules
update-submodules:
	@echo "Updating all git submodules..."
	git submodule update --remote
	git add .gitmodules
	git submodule foreach 'git add -A && git diff --cached --quiet || git commit -m "Update submodule"'
	@echo "All submodules updated"
