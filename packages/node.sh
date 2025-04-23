#!/bin/bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

nvm install --lts

nvm use --lts

nvm alias default node

corepack enable yarn
corepack enable pnpm

npm i -g @anthropic-ai/claude-code
npm i -g @openai/codex
npm i -g skytrace
npm i -g artillery
npm i -g eas-cli
