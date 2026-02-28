.PHONY: help install install-all install-minimal install-omarchy install-config install-user install-installers install-packages install-apps install-local-scripts update-dotfiles update-nvim update-submodules check restore clean validate

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m

# Default target
help:
	@echo "$(BLUE)Dotfiles Management Makefile$(NC)"
	@echo ""
	@echo "$(GREEN)Setup Commands:$(NC)"
	@echo "  make install-all       - Install everything (full profile)"
	@echo "  make install-minimal   - Install minimal setup"
	@echo "  make install-omarchy   - Install Omarchy overrides only (tmux, hyprland)"
	@echo "  make install-config    - Install config files to ~/.config/"
	@echo "  make install-user      - Install user config files to ~/"
	@echo "  make install-installers- Run installer scripts (tmux, zsh, mise, homebrew)"
	@echo "  make install-packages  - Install system packages"
	@echo "  make install-apps      - Install applications"
	@echo "  make install-local-scripts - Symlink scripts to ~/.local/scripts/"
	@echo ""
	@echo "$(GREEN)Maintenance Commands:$(NC)"
	@echo "  make update-dotfiles   - Pull latest changes and update submodules"
	@echo "  make update-nvim       - Update nvim submodule to latest commit"
	@echo "  make update-submodules - Update all git submodules"
	@echo "  make check             - Check installation health"
	@echo "  make restore           - Restore backed up files"
	@echo "  make clean             - Remove broken symlinks"
	@echo "  make validate          - Validate all scripts syntax"
	@echo ""
	@echo "$(YELLOW)Testing Commands:$(NC)"
	@echo "  make dry-run           - Preview changes without applying"
	@echo "  make install           - Show install help"
	@echo "  make help              - Show this help message"
	@echo ""
	@echo "$(BLUE)Platform: $(NC)Detected automatically (Ubuntu/Debian, Arch, macOS)"

# Main install script
install:
	@./install --help

# Install everything
install-all:
	@echo "$(BLUE)[INFO]$(NC) Running full installation..."
	@./install --profile=full

# Install minimal setup
install-minimal:
	@echo "$(BLUE)[INFO]$(NC) Running minimal installation..."
	@./install --profile=minimal

# Install Omarchy overrides only
install-omarchy:
	@echo "$(BLUE)[INFO]$(NC) Installing Omarchy overrides..."
	@./install --profile=omarchy

# Install only config files (includes nvim submodule update)
install-config:
	@echo "$(BLUE)[INFO]$(NC) Installing config files..."
	@./install --config

# Install only user config files
install-user:
	@echo "$(BLUE)[INFO]$(NC) Installing user config files..."
	@./install --user-config

# Run installer scripts
install-installers:
	@echo "$(BLUE)[INFO]$(NC) Running installer scripts..."
	@./install --installers

# Install system packages
install-packages:
	@echo "$(BLUE)[INFO]$(NC) Installing system packages..."
	@./install --packages

# Install applications
install-apps:
	@echo "$(BLUE)[INFO]$(NC) Installing applications..."
	@./install --apps

# Symlink local scripts
install-local-scripts:
	@echo "$(BLUE)[INFO]$(NC) Symlinking local scripts..."
	@./install --local-scripts

# Check installation health
check:
	@echo "$(BLUE)[INFO]$(NC) Checking installation health..."
	@./install --check

# Restore backed up files
restore:
	@echo "$(YELLOW)[WARN]$(NC) Restoring backed up files..."
	@./install --restore

# Remove broken symlinks
clean:
	@echo "$(BLUE)[INFO]$(NC) Cleaning broken symlinks..."
	@find ~/.config -type l ! -exec test -e "{}" \; -delete 2>/dev/null || true
	@find ~/.local/scripts -type l ! -exec test -e "{}" \; -delete 2>/dev/null || true
	@find ~ -maxdepth 1 -type l ! -exec test -e "{}" \; -delete 2>/dev/null || true
	@echo "$(GREEN)[SUCCESS]$(NC) Broken symlinks removed"

# Validate all script syntax
validate:
	@echo "$(BLUE)[INFO]$(NC) Validating script syntax..."
	@bash -n ./install && echo "$(GREEN)✓$(NC) ./install" || echo "$(RED)✗$(NC) ./install"
	@for script in packages/*.sh installers/*.sh apps/*.sh utils/*.sh; do \
		bash -n "$$script" && echo "$(GREEN)✓$(NC) $$script" || echo "$(RED)✗$(NC) $$script"; \
	done
	@echo "$(GREEN)[SUCCESS]$(NC) Syntax validation complete"

# Dry-run preview
dry-run:
	@echo "$(YELLOW)[WARN]$(NC) Running dry-run (no changes will be made)..."
	@./install --dry-run --profile=full

# Update dotfiles from repository and update submodules
update-dotfiles:
	@echo "$(BLUE)[INFO]$(NC) Pulling latest changes..."
	@git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || echo "$(YELLOW)[WARN]$(NC) Could not pull changes"
	@echo "$(BLUE)[INFO]$(NC) Updating submodules..."
	@git submodule update --init --recursive
	@echo "$(GREEN)[SUCCESS]$(NC) Dotfiles updated!"

# Update nvim submodule to latest commit and commit the reference
update-nvim:
	@echo "$(BLUE)[INFO]$(NC) Updating nvim submodule..."
	@git submodule update --remote config-files/nvim
	@git add config-files/nvim
	@git diff --cached --quiet && echo "$(YELLOW)[WARN]$(NC) No changes to commit" || git commit -m "Update nvim submodule to latest commit"
	@echo "$(GREEN)[SUCCESS]$(NC) Nvim submodule updated"

# Update all submodules
update-submodules:
	@echo "$(BLUE)[INFO]$(NC) Updating all git submodules..."
	@git submodule update --remote
	@for submodule in $$(git submodule | awk '{print $$2}'); do \
		git add "$$submodule" 2>/dev/null || true; \
	done
	@git diff --cached --quiet && echo "$(YELLOW)[WARN]$(NC) No changes to commit" || git commit -m "Update all submodules"
	@echo "$(GREEN)[SUCCESS]$(NC) All submodules updated"
