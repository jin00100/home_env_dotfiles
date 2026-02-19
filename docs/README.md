# 🚀 Dotfiles (Nix Home Manager)

yongminari's declarative development environment configuration managed by Nix Home Manager.
This setup supports both Native Linux and WSL, ensuring a consistent and high-performance workflow.

## ✨ Features

- **⚡ Shell:** Zsh optimized with Starship (Jetpack Theme).
- **🛠️ Modern Core Utils:** Replaces legacy tools with modern Rust alternatives.
  - `ls` -> `eza` (Icons & Git status)
  - `cd` -> `zoxide` (Smarter navigation)
  - `cat` -> `bat` (Syntax highlighting)
  - `find` -> `fd` / `grep` -> `ripgrep`
- **💻 Terminal Multiplexer:** Tmux pre-configured.
  - Auto-start on launch (except VS Code).
  - Prefix: `Ctrl + g`.
  - Seamless navigation with Neovim (`Ctrl + h,j,k,l`).
- **📝 Editor:** Neovim (IDE-like setup).
  - Lazy loading, Telescope, Neo-tree, Treesitter, LSP (C++, Go, Node).
- **🤖 AI:** Auto-installation of `@google/gemini-cli`.
- **📦 Modular:** Clean file structure separated by function (`modules/*.nix`).

## 📂 Directory Structure

```text
~/dotfiles
├── flake.nix             # Entry point (Native vs WSL profiles)
└── nix
    ├── home.nix          # Main loader
    └── modules
        ├── shell.nix     # Zsh, Starship, Aliases, Tmux autostart
        ├── starship.toml # Jetpack theme config
        ├── neovim.nix    # Editor config
        ├── tmux.nix      # Multiplexer config
        ├── packages.nix  # System packages & Installation scripts
        └── git.nix       # Git user config
```

## 🚀 Installation

### 1. Install Nix & Enable Flakes

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
# Restart terminal, then:
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

> **⚠️ Troubleshooting: Experimental Features Error**
> If you see an error like `error: experimental Nix feature 'nix-command' is disabled`, it means Flakes are not yet enabled in your configuration. Ensure `~/.config/nix/nix.conf` (or `/etc/nix/nix.conf` for multi-user) contains:
> `experimental-features = nix-command flakes`

### 2. Clone & Setup
...
(기존 내용)
...
### 4. Set Zsh as Default Shell (chsh)

Nix로 설치된 Zsh는 경로가 다르기 때문에 시스템이 기본 셸로 바로 인식하지 못할 수 있습니다. 다음 단계를 따라 전환하세요.

```bash
# 1. Nix Zsh 경로 확인
which zsh
# 보통 ~/.nix-profile/bin/zsh 또는 /run/current-system/sw/bin/zsh (NixOS)

# 2. 유효한 셸 목록에 추가 (Root 권한 필요)
sudo sh -c "echo $(which zsh) >> /etc/shells"

# 3. 기본 셸 변경
chsh -s $(which zsh)
```


```bash
# Clone this repo to ~/dotfiles
git clone <YOUR_REPO_URL> ~/dotfiles
cd ~/dotfiles

# Generate Starship theme (if missing)
mkdir -p nix/modules
starship preset jetpack > nix/modules/starship.toml
```

### 3. Apply Configuration

**For Native Linux:**
```bash
nix run home-manager/master -- switch --flake .#yongminari -b backup
```

**For WSL:**
```bash
nix run home-manager/master -- switch --flake .#yongminari-wsl -b backup
```

## ⌨️ Cheat Sheet

| Command | Action | Alias |
| :--- | :--- | :--- |
| `hms` / `hms-wsl` | Apply Nix configuration changes | `home-manager switch ...` |
| `ll` / `lt` | List files (Grid / Tree view) | `eza ...` |
| `cd <dir>` | Smart jump to directory | `z <dir>` |
| `vi` / `vim` | Open Neovim | `nvim` |
| `Space + f` | Find files (Telescope) | - |
| `Space + g` | Live Grep (Telescope) | - |
| `Ctrl + n` | Toggle File Explorer | Neotree |
| `Ctrl + g` | Tmux Prefix Key | - |
| `Ctrl + h/j/k/l` | Navigate between Vim & Tmux | - |

> **Note:** Ghostty terminal is installed only on Native Linux environments.
