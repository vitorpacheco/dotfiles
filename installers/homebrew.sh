#!/bin/bash

if [ -d /home/linuxbrew/.linuxbrew ]; then
  yellow "[HOMEBREW] homebrew já configurado"
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
