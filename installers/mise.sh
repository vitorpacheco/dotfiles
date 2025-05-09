#!/bin/bash


if [ -f /etc/apt/sources.list.d/mise.list ]; then
  yellow "[MISE] repositório ppa já configurado"
else
  sudo install -dm 755 /etc/apt/keyrings
  wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1>/dev/null
  echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=$(dpkg --print-architecture)] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list

  green "[MISE] repositório ppa configurado"
fi

sudo apt update
sudo apt install -y mise
