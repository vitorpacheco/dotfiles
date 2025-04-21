#!/bin/bash

SYNOLOGY_DRIVE_VERSION="3.5.2-16111"
SYNOLOGY_FILE="synology-drive-client-16111.x86_64.deb"

wget -O "$SYNOLOGY_FILE" "https://global.synologydownload.com/download/Utility/SynologyDriveClient/$SYNOLOGY_DRIVE_VERSION/Ubuntu/Installer/$SYNOLOGY_FILE"

sudo dpkg -i "$SYNOLOGY_FILE"

sudo apt install -f -y

