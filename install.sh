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

cd "$(dirname "$0")"

# Funções para colorir a saída
red()    { echo -e "\033[31m$*\033[0m"; }
green()  { echo -e "\033[32m$*\033[0m"; }
yellow() { echo -e "\033[33m$*\033[0m"; }


#####################
### BASE PACKAGES ###
#####################

#source ./packages/apt.sh


#####################
### CUSTOMIZATION ###
#####################

source ./installers/bat-themes.sh


##################
### INSTALLERS ###
##################

#source ./installers/homebrew.sh
#source ./installers/mise.sh

################
### PACKAGES ###
################

if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then
  source ./packages/brew.sh
fi


#################
### LANGUAGES ###
#################

#source ./packages/node.sh
source ./packages/sdk.sh


############
### APPS ###
############

#source ./installers/tmux.sh
source ./apps/ollama.sh


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

