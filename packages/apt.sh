#!/bin/bash

PACKAGES=(
  git
  htop
  rsync
  wget
  curl
  unzip
  zip
)

sudo apt update
sudo apt upgrade -y

for pkg in "${PACKAGES[@]}"; do
  if dpkg -s "$pkg" &> /dev/null; then
    echo "$pkg já está instalado."
  else
    echo "Instalando $pkg..."
    sudo apt install -y "$pkg"
  fi
done

