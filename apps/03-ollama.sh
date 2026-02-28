#!/usr/bin/env bash
#
# Ollama and model installation
# Supports: Linux and macOS
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../packages/lib.sh"

OLLAMA_BIN="/usr/local/bin/ollama"
OLLAMA_MODELS=(
	"llama3.2:3b"
	"codellama:7b"
)

# Check if Ollama is installed
is_ollama_installed() {
	if [[ -f "$OLLAMA_BIN" ]] || check_command ollama; then
		return 0
	fi
	return 1
}

# Install Ollama
install_ollama() {
	log_info "Installing Ollama..."

	if curl -fsSL https://ollama.com/install.sh | sh; then
		log_success "Ollama installed successfully"
		return 0
	else
		log_error "Failed to install Ollama"
		return 1
	fi
}

# Pull a model if not already present
pull_model() {
	local model="$1"

	# Ensure Ollama binary is available
	if [[ ! -f "$OLLAMA_BIN" ]] && check_command ollama; then
		OLLAMA_BIN=$(which ollama)
	fi

	if $OLLAMA_BIN list 2>/dev/null | awk '{print $1}' | grep -Fxq "$model"; then
		log_warn "Model '$model' is already installed"
		track_install "$model" "skipped"
	else
		log_info "Downloading model '$model'..."
		if $OLLAMA_BIN pull "$model"; then
			log_success "Model '$model' installed"
			track_install "$model" "success"
		else
			log_error "Failed to download model '$model'"
			track_install "$model" "failed"
		fi
	fi
}

# Main execution
main() {
	# Check/install Ollama
	if is_ollama_installed; then
		log_warn "Ollama is already installed"
		log_info "Version: $(ollama --version 2>&1 || echo 'version unknown')"
	else
		install_ollama || exit 1
	fi

	# Pull models
	log_info "Installing Ollama models..."
	for model in "${OLLAMA_MODELS[@]}"; do
		pull_model "$model"
	done

	# Summary
	print_summary

	log_info "Ollama setup complete!"
	log_info "Start Ollama server with: ollama serve"
	log_info "Or use: ollama run <model>"
}

main "$@"

# vi: ft=bash
