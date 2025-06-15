#!/bin/bash

if [ -f /usr/local/bin/ollama ]; then
  yellow "[OLLAMA] ollama já instalado"
else
  green "[OLLAMA] instalando o ollama"
  curl -fsSL https://ollama.com/install.sh | sh
fi

if ollama list | awk '{print $1}' | grep -Fxq "llama3.2:3b"; then
  yellow "[OLLAMA] o modelo llama3.2:3b já está instalado"
else
  green "[OLLAMA] instalando o llama3.2:3b"
  /usr/local/bin/ollama pull llama3.2:3b
fi

if ollama list | awk '{print $1}' | grep -Fxq "codellama:7b"; then
  yellow "[OLLAMA] o modelo codellama:7b já está instalado"
else
  green "[OLLAMA] instalando o codellama:7b"
  /usr/local/bin/ollama pull codellama:7b
fi

