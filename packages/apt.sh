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
)

SYNOLOGY_DRIVE_VERSION="3.5.2-16111"
SYNOLOGY_FILE="synology-drive-client-16111.x86_64.deb"

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

wget -O "$SYNOLOGY_FILE" "https://global.synologydownload.com/download/Utility/SynologyDriveClient/$SYNOLOGY_DRIVE_VERSION/Ubuntu/Installer/$SYNOLOGY_FILE"

sudo dpkg -i "$SYNOLOGY_FILE"

sudo apt install -f -y
