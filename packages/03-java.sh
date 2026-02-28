#!/usr/bin/env bash
#
# Java development environment installation via mise
# Supports: All platforms (Linux, macOS)
#

set -euo pipefail

# Source shared library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

# Check if mise is available
if ! check_command mise; then
	log_error "mise is not installed. Please run installers first."
	exit 1
fi

# Initialize mise environment
init_mise_env || {
	log_error "Failed to initialize mise environment"
	exit 1
}

# Install Java
log_info "Installing Java (Zulu 21) via mise..."
if check_command java; then
	log_warn "Java is already installed: $(java -version 2>&1 | head -n1)"
else
	if mise use -g java@zulu-21; then
		log_success "Java installed successfully"
	else
		log_error "Failed to install Java"
		exit 1
	fi
fi

# Install Maven
log_info "Installing Maven via mise..."
if check_command mvn; then
	log_warn "Maven is already installed: $(mvn -version | head -n1)"
else
	if mise use -g maven; then
		log_success "Maven installed successfully"
	else
		log_error "Failed to install Maven"
	fi
fi

# Install Gradle
log_info "Installing Gradle via mise..."
if check_command gradle; then
	log_warn "Gradle is already installed: $(gradle --version | head -n2 | tail -n1)"
else
	if mise use -g gradle; then
		log_success "Gradle installed successfully"
	else
		log_error "Failed to install Gradle"
	fi
fi

# Install Quarkus CLI
log_info "Installing Quarkus CLI via mise..."
if check_command quarkus; then
	log_warn "Quarkus is already installed: $(quarkus --version)"
else
	if mise use -g quarkus; then
		log_success "Quarkus installed successfully"
	else
		log_error "Failed to install Quarkus"
	fi
fi

# Install Spring Boot CLI
log_info "Installing Spring Boot CLI via mise..."
if check_command spring; then
	log_warn "Spring Boot is already installed: $(spring --version 2>&1 | head -n1)"
else
	if mise use -g spring-boot; then
		log_success "Spring Boot installed successfully"
	else
		log_error "Failed to install Spring Boot"
	fi
fi

log_info "Java development environment setup complete!"

# vi: ft=bash
