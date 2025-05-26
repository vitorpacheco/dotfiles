#!/bin/bash

#################
### BOOTSTRAP ###
#################

set -e # Encerra o script se algum comando falhar

DISTRO=""
if [ -f /etc/os-release ]; then
  source /etc/os-release
  DISTRO=$ID
else
  red "[PKG] não foi possível identificar a distribuição linux"
  exit 1
fi

CURRENT_DIR="$(dirname "$0")"
APPS_DIR="${CURRENT_DIR}/apps"
PACKAGES_DIR="${CURRENT_DIR}/packages"

INSTALLERS_DIR="${CURRENT_DIR}/installers"
LANGUAGES_DIR="${CURRENT_DIR}/languages"
CUSTOMIZATION_DIR="${CURRENT_DIR}/customization"
CONFIG_FILES_DIR="${CURRENT_DIR}/config-files"

cd "$CURRENT_DIR"

# Funções para colorir a saída
red()    { echo -e "\033[31m$*\033[0m"; }
green()  { echo -e "\033[32m$*\033[0m"; }
yellow() { echo -e "\033[33m$*\033[0m"; }


#####################
### BASE PACKAGES ###
#####################

source "${PACKAGES_DIR}/base-packages.sh"


#####################
### CUSTOMIZATION ###
#####################

source "${INSTALLERS_DIR}/bat-themes.sh"


##################
### INSTALLERS ###
##################

source "${INSTALLERS_DIR}/homebrew.sh"
source "${INSTALLERS_DIR}/mise.sh"

################
### PACKAGES ###
################

if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then
  source "${PACKAGES_DIR}/brew.sh"
fi


#################
### LANGUAGES ###
#################

source "${PACKAGES_DIR}/node.sh"
source "${PACKAGES_DIR}/sdk.sh"


############
### APPS ###
############

source "${INSTALLERS_DIR}/tmux.sh"
source "${APPS_DIR}/ollama.sh"


############################
### CONFIGURATIONS FILES ###
############################

if [ -f gitconfig ]; then
  if [ -f "$HOME/.gitconfig" ]; then
    yellow "[CONFIG-FILES] .gitconfig já existe"
  else
    cp ./gitconfig "$HOME/.gitconfig"
    green "[CONFIG-FILES] .gitconfig copiado"
  fi
else
  red "[CONFIG-FILES] gitconfig não encontrado"
fi

