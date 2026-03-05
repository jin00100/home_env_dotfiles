# 🚀 Jin's 现代化开发环境使用教程

欢迎使用基于 Nix Home Manager 构建的现代化开发环境！本环境将 Zsh、Zellij、Neovim 以及各种现代 Rust CLI 工具深度整合，为你提供极速、美观且统一的终端体验。

## 1. ⚙️ 配置生效与更新 (Nix 核心操作)

当你修改了 `~/home_env_dotfiles` 目录下的任何 `.nix` 配置文件后，**必须**运行以下命令让配置生效：

*   **`hms`** : 这是一个超级别名，等同于 `home-manager switch ...`。每次修改配置文件（如添加快捷键、安装新软件）后，只需在终端输入 `hms`，Nix 就会自动编译并应用你的最新配置。
*   **`./update.sh`** : 当你想把所有已安装的软件（如 Neovim、Zellij、LSP 等）更新到最新版本时，在 `home_env_dotfiles` 目录下运行此脚本。

## 2. 🪟 终端复用器：Zellij (核心工作流)

Zellij 是替代 Tmux 的现代终端复用器。在本环境中，当你打开非 VS Code 的终端时，它会**自动启动**。

**⚠️ 最重要的快捷键：模式切换**
为了防止和 Neovim 的快捷键冲突，默认的快捷键前缀（Prefix）被改为了 **`Ctrl + g`**。
*   按下 **`Ctrl + g`**：进入 **Locked (锁定) 模式**。此时 Zellij 会忽略大部分快捷键，把所有按键原封不动传给内部程序（**使用 Neovim 时必须处于此模式**）。
*   再次按 **`Ctrl + g`**：回到 **Normal (正常) 模式**，底部状态栏会变成蓝色。

**常用快捷键 (Normal 模式下或使用 Alt 键)：**
*   `Alt + n` : 在右侧新建一个面板 (Pane)。
*   `Alt + h/j/k/l` : 在不同面板之间向 左/下/上/右 移动焦点。
*   `Alt + =` / `Alt + -` : 放大 / 缩小当前面板。
*   `Alt + i` / `Alt + o` : 切换到 上一个 / 下一个 标签页 (Tab)。
*   `Ctrl + x` : 关闭当前标签页。
*   `zj_shortcuts` : 在终端输入此命令，可以随时查看你自定义的快捷键速查表。

## 3. 🛠️ 现代化 CLI 工具替换

传统 Linux 命令已被替换为速度更快、带语法高亮的 Rust 现代工具：

*   **目录切换 (`zoxide`)**:
    *   无需再敲长串路径。曾经去过一次 `~/home_env_dotfiles/nix/modules`，下次只需输入 `z modules` 即可瞬间跳转。
*   **文件列表 (`eza`)**:
    *   `ls` : 标准列表（带漂亮的图标）。
    *   `ll` : 详细列表，显示隐藏文件、权限、修改时间及 Git 状态。
    *   `lt` : 以树状图结构（Tree）显示当前目录（深度为 2 层）。
*   **文件查看 (`bat`)**:
    *   `cat <文件>` : 替代传统 cat，自动带有行号、Git 修改提示和精美的语法高亮。
*   **其他快捷命令**:
    *   `tocb` : 将输出复制到系统剪贴板（用法: `cat file.txt | tocb`）。
    *   `fd` : 替代 `find` 的极速文件查找工具。
    *   `ripgrep` (终端敲 `rg`): 替代 `grep` 的极速文本搜索工具。

## 4. 📝 沉浸式编辑器：Neovim

在终端输入 `vi` 或 `vim` 即可打开深度定制的 Neovim（TokyoNight 主题）。

**常用快捷操作 (Space 是你的 Leader 键)：**
*   **文件导航**:
    *   `Ctrl + n` : 侧边栏文件树 (Neo-tree) 开关。
    *   `-` (减号) : 打开 Oil.nvim（像编辑文本一样直接修改、重命名、删除文件目录）。
    *   `Space + f` : 全局搜索文件 (Telescope)。
    *   `Space + g` : 全局搜索文本内容 (Live Grep)。
*   **内置终端**:
    *   `Ctrl + /` (或 `Ctrl + _`) : 弹出一个悬浮终端，适合在不退出代码的情况下快速运行编译或 Git 命令。
*   **代码分析 & LSP**:
    *   `Space + d` : 跳转到函数/变量的定义。
    *   `Space + r` : 查找所有引用。
    *   `Space + xx` : 底部弹出面板，显示当前项目的所有语法错误和警告 (Trouble.nvim)。
    *   `Space + gg` : 全屏打开 LazyGit 界面进行直观的 Git 提交和分支管理。

## 5. 🧑‍🏫 如何添加新软件或自定义配置？

Nix 的核心理念是“声明式”。**不要使用 `apt install` 或 `npm install -g`** 来安装全局工具，否则重启或换电脑后就丢失了。

**Q: 我想安装一个新软件（例如 `jq` 和 `wget`），该怎么做？**
1. 打开 `~/home_env_dotfiles/nix/modules/packages.nix`。
2. 找到 `home.packages = with pkgs; [ ... ]` 列表。
3. 把 `jq` 和 `wget` 加进列表里。
4. 终端运行 `hms`。完成！

**Q: 我想加一个新的 Alias（快捷命令），该怎么做？**
1. 打开 `~/home_env_dotfiles/nix/modules/shell.nix`。
2. 找到 `shellAliases = { ... }` 块。
3. 添加你的命令，例如：`g = "git";`。
4. 终端运行 `hms`。新命令立即生效！

---
**💡 提示**：如果你处于 Zellij 中且发现 Neovim 快捷键突然没反应了，请检查底部状态栏，多半是你忘记按 `Ctrl + g` 切回 Locked 模式了！