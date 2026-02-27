#!/usr/bin/env bash
set -e

# Detect current user and home directory
CURRENT_USER=$(whoami)
CURRENT_HOME=$HOME

echo "🚀 Configuring dotfiles for user: $CURRENT_USER at $CURRENT_HOME"

# 1. Update flake.nix
sed -i -E "s|\"[a-zA-Z0-9_-]+\" = home-manager.lib.homeManagerConfiguration|\"$CURRENT_USER\" = home-manager.lib.homeManagerConfiguration|g" flake.nix

# 2. Update nix/home.nix
sed -i -E "s|home.username = \"[^\"]*\";|home.username = \"$CURRENT_USER\";|g" nix/home.nix
sed -i -E "s|home.homeDirectory = \"[^\"]*\";|home.homeDirectory = \"$CURRENT_HOME\";|g" nix/home.nix

# 3. Update nix/modules/shell.nix
sed -i -E "s|/home_env_dotfiles/#[a-zA-Z0-9_-]*|/home_env_dotfiles/#$CURRENT_USER|g" nix/modules/shell.nix

echo "✅ Configuration updated seamlessly!"
echo "✨ Applying Nix configuration..."
nix run home-manager/master -- switch --flake .#$CURRENT_USER -b backup

echo ""
echo "🎉 Installation complete!"
echo "👉 Please restart your terminal for changes to take full effect."
echo "👉 If you need to set Zsh as your default shell or configure Node.js, follow the steps in README.md."
