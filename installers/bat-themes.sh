#!/bin/bash

BAT_THEME_DIR="$(command bat --config-dir)/themes/tokyonight.nvim"
if [ -d "$BAT_THEME_DIR" ]; then
  yellow "[BAT] o tema já está configurado"
else
  git clone https://github.com/0xTadash1/bat-into-tokyonight /tmp/bat-into-tokyonight
  cd /tmp/bat-into-tokyonight || exit
  ./bat-into-tokyonight >/dev/null 2>&1 &
  rm -rf /tmp/bat-into-tokyonight
  gree "[BAT] tema configurado"
fi

