#!/bin/bash

TARGET_DIR="$HOME/.tmux/plugins/tpm"

if [ -d "$TARGET_DIR" ]; then
  yellow "[TMUX] O plugin tpm já está configurado"
else
  green "[TMUX] Instalando o plugin tpm"
  git clone https://github.com/tmux-plugins/tpm "$TARGET_DIR"
fi

