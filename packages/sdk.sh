#!/bin/zsh

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

sdk install java 23.0.2-zulu
sdk install java 21.0.7-zulu
sdk install quarkus
sdk install maven
