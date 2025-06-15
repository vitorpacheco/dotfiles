#!/bin/bash

BAT_THEME_DIR="$(command bat --config-dir)/themes/tokyonight.nvim"
if [ -d "$BAT_THEME_DIR" ]; then
  yellow "[BAT] o tema já está configurado"
else
  TMP_FOLDER="/tmp/bat-into-tokyonight"
  git clone https://github.com/0xTadash1/bat-into-tokyonight "$TMP_FOLDER"
  cd "$TMP_FOLDER" || exit
  source ./bat-into-tokyonight >/dev/null 2>&1 &
  rm -rf "$TMP_FOLDER"
  cd - || exit
  green "[BAT] tema configurado"
fi

