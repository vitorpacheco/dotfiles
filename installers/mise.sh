#!/bin/bash

DISTRO=""
if [ -f /etc/os-release ]; then
  source /etc/os-release
  DISTRO=$ID
else
  red "[PKG] não foi possível identificar a distribuição linux"
  exit 1
fi

if [ -f /etc/apt/sources.list.d/mise.list ]; then
  if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then
    yellow "[MISE] repositório ppa já configurado"
  else
    sudo install -dm 755 /etc/apt/keyrings
    wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1>/dev/null
    echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=$(dpkg --print-architecture)] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
    sudo apt update

    green "[MISE] repositório ppa configurado"
  fi

  sudo apt install -y mise
  green "[MISE] mise instalado"
elif [[ "$DISTRO"  == "arch" ]]; then
  if yay -Q mise &>/dev/null; then
    yellow "[YAY] mise já está instalado."
  else
    yay -S mise --noconfirm
    green "[MISE] mise instalado"
  fi
else
  red "[PKG] distribuição não suportada"
  exit 1
fi
