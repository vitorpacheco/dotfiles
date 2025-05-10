#!/bin/bash

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

brew update
brew upgrade
brew bundle --file=./Brewfile


