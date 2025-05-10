#!/bin/bash

DISTRO=""
if [ -f /etc/os-release ]; then
  source /etc/os-release
  DISTRO=$ID
else
  red "[PKG] não foi possível identificar a distribuição linux"
  exit 1
fi

UBUNTU_PACKAGES=(
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

# Pacotes para Arch (nomes podem ser diferentes)
ARCH_PACKAGES=(
  base-devel
  procps-ng
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
  vlc
  python-pipx
  fastfetch
  rofi
  plocate
  nfs-utils
  bat
)

if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then
  PPA_FASTFETCH="zhangsongcui3371/fastfetch"

  if grep -h "zhangsongcui3371" /etc/apt/sources.list /etc/apt/sources.list.d/* > /dev/null 2>&1; then
    yellow "[APT] o repositório ppa '$PPA_FASTFETCH' já está configurado"
  else
    green "[APT] adicionando o repositório ppa $PPA_FASTFETCH"
    sudo add-apt-repository -y ppa:$PPA_FASTFETCH
  fi

  green "[APT] atualizando pacotes"
  sudo apt update
  sudo apt upgrade -y

  for pkg in "${UBUNTU_PACKAGES[@]}"; do
    if dpkg -s "$pkg" &>/dev/null; then
      yellow "[APT] $pkg já está instalado"
    else
      green "[APT] instalando pacote $pkg"
      sudo apt install -y "$pkg"
    fi
  done
elif [[ "$DISTRO"  == "arch" ]]; then
  if ! command -v yay &>/dev/null; then
    red "[YAY] yay não está instalado"
    exit 1
  fi

  green "[YAY] atualizando pacotes"
  yay -Syu --noconfirm

  for pkg in "${ARCH_PACKAGES[@]}"; do
    if yay -Q "$pkg" &>/dev/null; then
      yellow "[YAY] $pkg já está instalado."
    else
      green "[YAY] Instalando pacote $pkg..."
      yay -S --noconfirm "$pkg"
    fi
  done
else
  red "[PKG] distribuição não suportada"
  exit 1
fi

