#!/bin/bash

eval "$(mise activate --shims)"
eval "$(mise activate bash)"

if ! command -v mise &>/dev/null; then
  red "instale o mise antes de rodar este script"
  exit 1
fi

green "[NODE] instalando o node"
mise use -g node@latest

# Atualiza o yarn
if command -v corepack &>/dev/null; then
  green "[NODE] atualizando o yarn via corepack"
  corepack prepare yarn@stable --activate
else
  yellow "[NODE] corepack não encontrado, atualizando yarn via npm"
  npm install -g yarn
fi

# Atualiza o pnpm
if command -v corepack &>/dev/null; then
  green "[NODE] atualizando o pnpm via corepack"
  corepack prepare pnpm@latest --activate
else
  yellow "[NODE] corepack não encontrado, atualizando pnpm via npm"
  npm install -g pnpm
fi

NPM_PACKAGES=(
  @anthropic-ai/claude-code
  @openai/codex
  skytrace
  artillery
  eas-cli
)

green "[NODE] atualizando o npm"
npm install -g npm

for pkg in "${NPM_PACKAGES[@]}"; do
  if npm list -g --depth=0 "$pkg" &>/dev/null; then
    yellow "[NODE] $pkg já está instalado"
  else
    green "[NODE] instalando $pkg"
    npm i -g "$pkg"
  fi
done

