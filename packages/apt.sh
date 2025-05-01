#!/bin/bash

PACKAGES=(
  git
  git-delta
  htop
  rsync
  wget
  curl
  unzip
  zip
  flameshot
  gnome-tweak-tool
  vlc
  gnome-shell-extension-manager
  pipx
  fastfetch
  rofi
  plocate
)

sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch

sudo apt update
sudo apt upgrade -y

for pkg in "${PACKAGES[@]}"; do
  if dpkg -s "$pkg" &>/dev/null; then
    echo "$pkg já está instalado."
  else
    echo "Instalando $pkg..."
    sudo apt install -y "$pkg"
  fi
done

