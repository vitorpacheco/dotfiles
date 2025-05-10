#!/bin/bash

if [ -f ./tmux.conf ]; then
  cp ./tmux.conf "$HOME/.tmux.conf"
  green "[CONFIG-FILES] .tmux.conf copiado"
else
  red "[CONFIG-FILES] tmux.conf não encontrado"
fi

TARGET_DIR="$HOME/.tmux/plugins/tpm"

if [ -d "$TARGET_DIR" ]; then
  yellow "[TMUX] o plugin tpm já está configurado"
else
  green "[TMUX] instalando o plugin tpm"
  git clone https://github.com/tmux-plugins/tpm "$TARGET_DIR"

  if pgrep tmux >/dev/null; then
    green "[TMUX] recarregando configurações do tmux"
    tmux source-file "$HOME/.tmux.conf"
  else
    yellow "[TMUX] nenhuma sessão tmux em execução para recarregar"
  fi

  # Instala os plugins do TPM
  if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    green "[TMUX] instalando plugins do tmux"
    "$TARGET_DIR/bin/install_plugins"
  else
    red "[TMUX] tpm não encontrado em ~/.tmux/plugins/tpm. pule a instalação dos plugins"
  fi
fi
