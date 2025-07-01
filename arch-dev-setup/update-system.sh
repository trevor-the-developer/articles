#!/bin/bash
echo "Updating system packages..."
sudo pacman -Syu
echo "Updating AUR packages..."
yay -Syu
echo "Updating asdf plugins..."
asdf plugin update --all 2>/dev/null || echo "asdf not available in this session"
echo "Cleaning package cache..."
sudo pacman -Sc
echo "Update complete!"
