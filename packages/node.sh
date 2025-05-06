#!/bin/bash

eval "$(mise activate zsh)"

mise use node@latest
mise use -g node@latest

corepack enable yarn
corepack enable pnpm

npm i -g @anthropic-ai/claude-code
npm i -g @openai/codex
npm i -g skytrace
npm i -g artillery
npm i -g eas-cli
