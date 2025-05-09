#!/bin/bash

PACKAGES=(
  build-essential
  gpg
  procps
  file
  zsh
  git
  git-delta
  htop
  rsync
  wget
  curl
  unzip
  zip
  flameshot
  gnome-tweaks
  vlc
  gnome-shell-extension-manager
  pipx
  fastfetch
  rofi
  plocate
  nfs-common
)

PPA_FASTFETCH="zhangsongcui3371/fastfetch"

if grep -h "zhangsongcui3371" /etc/apt/sources.list /etc/apt/sources.list.d/* > /dev/null 2>&1; then
  yellow "[APT] O repositório PPA '$PPA_FASTFETCH' já está configurado"
else
  green "[APT] Adicionando o repositório PPA $PPA_FASTFETCH..."
  sudo add-apt-repository -y ppa:$PPA_FASTFETCH
fi

green "[APT] Atualizando pacotes..."
sudo apt update
sudo apt upgrade -y

for pkg in "${PACKAGES[@]}"; do
  if dpkg -s "$pkg" &>/dev/null; then
    yellow "[APT] $pkg já está instalado."
  else
    green "[APT] Instalando pacote $pkg..."
    sudo apt install -y "$pkg"
  fi
done

