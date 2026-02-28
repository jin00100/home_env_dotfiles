# 🚀 Dotfiles (Nix Home Manager)

**jin**'s declarative development environment configuration managed by **Nix Home Manager**.
This setup supports both **Native Linux** and **WSL** with a single, unified configuration, ensuring a consistent and high-performance workflow.

## ✨ Features

- **⚡ Shell:** Zsh optimized with **Starship (Jetpack Theme)**.
- **🛠️ Modern Core Utils:** Replaces legacy tools with modern Rust alternatives.
  - `ls` -> `eza` (Icons & Git status)
  - `cd` -> `zoxide` (Smarter navigation)
  - `cat` -> `bat` (Syntax highlighting)
  - `find` -> `fd` / `grep` -> `ripgrep`
  - `direnv` -> **`direnv` (Nix-direnv integrated)**
- **💻 Terminal Multiplexer:** **Zellij** (Modern Rust-based) pre-configured.
  - Auto-start on launch (except VS Code).
  - Prefix: `Ctrl + g` (Locked/Normal toggle).
  - Modern UI with Gruvbox theme and helpful status bars.
  - Seamless navigation and integration with Neovim.
- **📝 Editor:** **Neovim** (IDE-like setup).
  - Lazy loading, Telescope, Neo-tree, Treesitter, LSP (C++, Go, Node).
- **🤖 AI:** Auto-installation of `@google/gemini-cli`.
- **📦 Modular:** Clean file structure separated by function (`modules/*.nix`).

## 📂 Directory Structure

```text
~/home_env_dotfiles
├── flake.nix             # Entry point (Unified profile)
└── nix
    ├── home.nix          # Main loader
    └── modules
        ├── shell.nix     # Zsh, Starship, Aliases, Zellij autostart, Direnv
        ├── starship.toml # Jetpack theme config
        ├── neovim.nix    # Editor config
        ├── zellij.nix    # Modern Multiplexer config
        ├── packages.nix  # System packages & Installation scripts
        └── git.nix       # Git user config
```

## 🚀 Installation

This project includes an all-in-one setup script (`install.sh`) that will automatically:
1. Install Nix Package Manager and enable Flakes.
2. Configure variables based on your username (`jin`, etc.).
3. Download and apply the `zsh`, `zellij`, and `neovim` configurations.
4. Auto-install Node.js via `fnm`.
5. Set `zsh` as your default shell.

### Option 1: Quick Install (via curl)
If you haven't cloned this repository yet, you can run this single command to clone and install everything:

```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/home_env_dotfiles.git ~/home_env_dotfiles
cd ~/home_env_dotfiles
chmod +x install.sh
./install.sh
```

### Option 2: Local Install
If you have already cloned the repository manually:

```bash
cd ~/home_env_dotfiles
chmod +x install.sh
./install.sh
```

## ⌨️ Cheat Sheet

| Command | Action | Alias |
| :--- | :--- | :--- |
| `hms` | Apply Nix configuration changes | `home-manager switch ...` |
| `ll` / `lt` | List files (Grid / Tree view) | `eza ...` |
| `zj` | Start Zellij session | - |
| `zj_shortcuts` | Show Zellij keybindings summary | - |
| `vi` / `vim` | Open Neovim | `nvim` |
| `Space + f` | Find files (Telescope) | - |
| `Space + g` | Live Grep (Telescope) | - |
| `Ctrl + n` | Toggle File Explorer | `Neotree` |
| `Ctrl + g` | Zellij Prefix (Lock/Unlock) | - |
| `Alt + h/j/k/l` | Navigate between Zellij panes | - |

## 🔄 Maintenance

### Update Packages & Configuration

Nix 및 Home Manager에 등록된 모든 패키지를 최신 버전으로 업데이트하려면 다음 명령어를 순서대로 실행하세요.

```bash
# 1. 패키지 레시피(flake.lock)를 최신 상태로 갱신
nix flake update

# 2. 업데이트된 내용 적용
hms
```

---

**Note:** Ghostty configuration is managed, but the binary should be installed manually on Native Linux.
