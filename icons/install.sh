#!/usr/bin/env zsh

cp assets/usr-vial.png $HOME/.local/share/icons/usr-vial.png
cp assets/usr-balenaetcher.png $HOME/.local/share/icons/usr-balenaetcher.png
cp assets/usr-btop.png $HOME/.local/share/icons/usr-btop.png

cp vial.desktop $HOME/.local/share/applications/vial.desktop
cp balenaetcher.desktop $HOME/.local/share/applications/balenaEtcher.desktop
cp btop.desktop $HOME/.local/share/applications/btop.desktop

update-desktop-database $HOME/.local/share/applications/
gtk-update-icon-cache $HOME/.local/share/icons/
