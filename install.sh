#!/usr/bin/env bash
set -e

# Terminal Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting dotfiles installation and setup...${NC}"

# 1. Try loading Nix environment early in case it's installed but not in PATH
if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
    source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
elif [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    source "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi
export PATH="/nix/var/nix/profiles/default/bin:$HOME/.nix-profile/bin:$PATH"

# 2. Check for Nix Package Manager
if ! command -v nix &> /dev/null; then
    echo -e "${YELLOW}🧹 Cleaning up previous failed Nix installation residues (if any)...${NC}"
    sudo find /etc ~/ -name "*.backup-before-nix" -type f -delete 2>/dev/null || true

    echo -e "${YELLOW}📦 Nix is not installed. Installing Nix...${NC}"
    sh <(curl -L https://nixos.org/nix/install) --daemon --yes
    
    echo -e "${YELLOW}⚙️ Configuring Nix experimental features (flakes)...${NC}"
    mkdir -p ~/.config/nix
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
    
    # Load Nix environment immediately after installation to bypass restart requirement
    if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
        source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    fi
    export PATH="/nix/var/nix/profiles/default/bin:$HOME/.nix-profile/bin:$PATH"
    
    echo -e "${GREEN}✅ Nix installation complete and automatically loaded into current session!${NC}"
else
    echo -e "${GREEN}✅ Nix is already installed.${NC}"
    # Ensure flakes are enabled
    if ! grep -q "flakes" ~/.config/nix/nix.conf 2>/dev/null; then
        echo -e "${YELLOW}⚙️ Enabling Nix flakes...${NC}"
        mkdir -p ~/.config/nix
        echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
    fi
fi

# 3. Apply Home Manager Configuration dynamically
# Using --impure allows dynamic fetching of user, directory, and architecture without editing files (No Git conflicts!)
echo -e "${YELLOW}✨ Applying Nix configuration dynamically for any user on any architecture...${NC}"
nix run home-manager/master -- switch --flake .#default --impure -b backup

# Source newly updated environment variables
if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    source "$HOME/.nix-profile/etc/profile.d/nix.sh"
elif [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
    source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
fi
export PATH="$HOME/.nix-profile/bin:$PATH"

# 4. Auto-install Node.js (via fnm)
if command -v fnm &> /dev/null; then
    echo -e "${YELLOW}📦 Setting up Node.js (via fnm)...${NC}"
    fnm install --lts
    fnm default lts-latest
    echo -e "${GREEN}✅ Node.js LTS configured.${NC}"
else
    echo -e "${RED}⚠️ fnm not found. Skipping Node.js installation.${NC}"
fi

# 5. Set default shell to Zsh
echo -e "${YELLOW}⚙️ Setting Zsh as the default shell...${NC}"
NIX_ZSH="$HOME/.nix-profile/bin/zsh"
if [ -x "$NIX_ZSH" ]; then
    if grep -q "$NIX_ZSH" /etc/shells; then
        echo -e "${GREEN}✅ Nix Zsh is already in /etc/shells.${NC}"
    else
        echo -e "${BLUE}Adding Nix Zsh to /etc/shells (requires sudo access)...${NC}"
        sudo sh -c "echo $NIX_ZSH >> /etc/shells"
    fi
    
    if [ "$SHELL" = "$NIX_ZSH" ]; then
        echo -e "${GREEN}✅ Zsh is already the default shell.${NC}"
    else
        echo -e "${BLUE}Changing default shell to Nix Zsh...${NC}"
        chsh -s "$NIX_ZSH"
        echo -e "${GREEN}✅ Default shell changed to Zsh.${NC}"
    fi
else
    echo -e "${RED}⚠️ Could not find Nix installed Zsh at $NIX_ZSH. Skipping default shell changing.${NC}"
fi

echo ""
echo -e "${GREEN}🎉 All done! Dotfiles installation is complete.${NC}"
echo -e "${BLUE}👉 Please fully close and restart your terminal to enter your new Zsh environment!${NC}"
