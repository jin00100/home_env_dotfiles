#!/usr/bin/env bash
set -e

# 터미널 색상 설정
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting dotfiles installation and setup...${NC}"

# 1. 자동 사용자 이름 및 홈 디렉토리 감지
CURRENT_USER=$(whoami)
CURRENT_HOME=$HOME

echo -e "${GREEN}Detected user:${NC} $CURRENT_USER at $CURRENT_HOME"

# 2. 시스템에 Nix가 설치되어 있지만 환경변수에 등록되지 않은 경우를 대비하여 먼저 로드 시도
if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
    source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
elif [ -e "$CURRENT_HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    source "$CURRENT_HOME/.nix-profile/etc/profile.d/nix.sh"
fi
export PATH="/nix/var/nix/profiles/default/bin:$CURRENT_HOME/.nix-profile/bin:$PATH"

# 3. Nix 패키지 매니저 설치 확인
if ! command -v nix &> /dev/null; then
    echo -e "${YELLOW}🧹 Cleaning up previous failed Nix installation residues (if any)...${NC}"
    sudo find /etc ~/ -name "*.backup-before-nix" -type f -delete 2>/dev/null || true

    echo -e "${YELLOW}📦 Nix is not installed. Installing Nix...${NC}"
    sh <(curl -L https://nixos.org/nix/install) --daemon --yes
    
    echo -e "${YELLOW}⚙️ Configuring Nix experimental features (flakes)...${NC}"
    mkdir -p ~/.config/nix
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
    
    echo -e "${RED}⚠️ Nix installation requires a shell restart to take effect.${NC}"
    echo -e "${BLUE}👉 Please restart your terminal completely, then run ./install.sh again.${NC}"
    exit 0
else
    echo -e "${GREEN}✅ Nix is already installed.${NC}"
    # Flake 활성화 보장
    if ! grep -q "flakes" ~/.config/nix/nix.conf 2>/dev/null; then
        echo -e "${YELLOW}⚙️ Enabling Nix flakes...${NC}"
        mkdir -p ~/.config/nix
        echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
    fi
fi

# 3. Flake 및 설정 파일 내 유저명 동적 업데이트
echo -e "${BLUE}🔄 Updating configurations for current user...${NC}"
# 변수 치환 정규식 처리
sed -i -E "s|\"[a-zA-Z0-9_-]+\" = home-manager.lib.homeManagerConfiguration|\"$CURRENT_USER\" = home-manager.lib.homeManagerConfiguration|g" flake.nix
sed -i -E "s|home.username = \"[^\"]*\";|home.username = \"$CURRENT_USER\";|g" nix/home.nix
sed -i -E "s|home.homeDirectory = \"[^\"]*\";|home.homeDirectory = \"$CURRENT_HOME\";|g" nix/home.nix
sed -i -E "s|/home_env_dotfiles/#[a-zA-Z0-9_-]*|/home_env_dotfiles/#$CURRENT_USER|g" nix/modules/shell.nix
echo -e "${GREEN}✅ Configurations updated successfully!${NC}"

# 4. Home Manager 설정 적용
echo -e "${YELLOW}✨ Applying Nix configuration. This may take a few minutes...${NC}"
nix run home-manager/master -- switch --flake .#$CURRENT_USER -b backup

# 새로 업데이트된 환경 변수를 스크립트 내에서 활성화
if [ -e "$CURRENT_HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    source "$CURRENT_HOME/.nix-profile/etc/profile.d/nix.sh"
elif [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
    source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
fi
# PATH 강제 주입
export PATH="$CURRENT_HOME/.nix-profile/bin:$PATH"

# 5. Node.js 자동 설치 (fnm)
if command -v fnm &> /dev/null; then
    echo -e "${YELLOW}📦 Setting up Node.js (via fnm)...${NC}"
    fnm install --lts
    fnm default lts-latest
    echo -e "${GREEN}✅ Node.js LTS configured.${NC}"
else
    echo -e "${RED}⚠️ fnm not found. Skipping Node.js installation. (Are the Nix packages correctly applied?)${NC}"
fi

# 6. 기본 셸을 Zsh로 변경
echo -e "${YELLOW}⚙️ Setting Zsh as the default shell...${NC}"
NIX_ZSH="$CURRENT_HOME/.nix-profile/bin/zsh"
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
