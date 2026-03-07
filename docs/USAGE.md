# 🚀 Jin's 现代化开发环境使用教程

欢迎使用基于 Nix Home Manager 构建的现代化开发环境！本环境将 Zsh、Zellij、Neovim 以及各种现代 Rust CLI 工具深度整合，为您提供极速、美观且统一的终端体验，并特别针对 DevOps 工作流进行了强化。

## 1. ⚙️ 配置生效与更新 (Nix 核心操作)

由于环境由 Nix 声明式管理，当您修改了 `~/home_env_dotfiles` 目录下的任何 `.nix` 配置文件后，**必须**运行以下命令让配置生效：

*   **`hms`** : 这是一个超级别名，等同于 `home-manager switch ...`。每次修改配置文件（如添加快捷键、安装新软件）后，只需在终端输入 `hms`，Nix 就会自动编译并应用您的最新配置。
*   **`nix-clean`** : **[新增]** 当您觉得 Nix 占用太多磁盘空间时，在终端输入此命令。它会自动删除旧版本的环境备份并进行垃圾回收，释放磁盘空间。
*   **`./update.sh`** : 当您想把所有已安装的软件（如 Neovim、Zellij、LSP 等）更新到最新版本时，在 `home_env_dotfiles` 目录下运行此脚本。

## 2. 🪟 终端复用器：Zellij (核心工作流)

Zellij 是替代 Tmux 的现代终端复用器。在本环境中，当您打开非 VS Code 的终端时，它会**自动启动**。

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
*   `zj_shortcuts` : 在终端输入此命令，可以随时查看自定义的快捷键速查表。

## 3. 🛠️ 现代化 CLI 工具与 DevOps 神器

传统 Linux 命令已被替换为速度更快、带语法高亮的 Rust 现代工具，并加入了处理数据的必备神器：

*   **目录切换 (`zoxide`)**:
    *   无需再敲长串路径。曾经去过一次 `~/home_env_dotfiles/nix/modules`，下次只需输入 `z modules` 即可瞬间跳转。
*   **文件列表 (`eza`)**:
    *   `ls` : 标准列表（带漂亮的图标）。
    *   `ll` : 详细列表，显示隐藏文件、权限、修改时间及 Git 状态。
    *   `lt` : 以树状图结构（Tree）显示当前目录（深度为 2 层）。
*   **文件查看 (`bat`)**:
    *   `cat <文件>` : 替代传统 cat，自动带有行号、Git 修改提示和精美的语法高亮。
*   **系统监控 (`btop`)**: **[新增]**
    *   `btop` : 替代传统的 `top` 或 `htop`。提供一个高颜值、支持鼠标点击的现代化系统资源（CPU/内存/网络/磁盘）监控面板。
*   **数据处理 (`jq` & `yq`)**: **[新增]**
    *   `jq` : 解析、高亮和提取 JSON 数据的神器。用法示例：`cat api.json | jq '.'` 或 `cat pod.json | jq '.spec.containers'`。
    *   `yq` : YAML 版本的 jq。在 Kubernetes 和 CI/CD 运维中非常实用。
*   **其他快捷命令**:
    *   `tocb` : 将输出复制到系统剪贴板（用法: `cat file.txt | tocb`）。
    *   `fd` : 替代 `find` 的极速文件查找工具。
    *   `ripgrep` (终端敲 `rg`): 替代 `grep` 的极速文本搜索工具。

## 4. 📝 沉浸式编辑器：Neovim (DevOps 增强版)

在终端输入 `vi` 或 `vim` 即可打开深度定制的 Neovim（TokyoNight 主题）。本次针对 DevOps 场景（YAML, Docker, Bash）进行了底层语言服务器和代码片段的增强。

**DevOps 专属特性：**
*   **智能 YAML 支持**: 现已内置 `yaml-language-server` 和最佳 DevOps 缩进（Tab=2）。打开 Kubernetes 配置或 Docker Compose 文件时，打错层级或拼错字段会立刻标红提示。
*   **Bash & Docker 补全**: 内置了 `bashls` 和 `dockerls`。编写 Shell 脚本和 Dockerfile 时拥有 IDE 级别的语法校验。
*   **全套代码片段 (Snippets)**: **[新增]** 集成了 `friendly-snippets`。输入 `if`、`RUN` 甚至各类 YAML 关键词时，可以直接补全大段标准代码块。

**常用快捷操作 (Space 是您的 Leader 键)：**
*   **文件导航**:
    *   `Ctrl + n` : 侧边栏文件树 (Neo-tree) 开关。
    *   `-` (减号) : 打开 Oil.nvim（像编辑文本一样直接修改、重命名、删除文件目录）。
    *   `Space + f` : 全局搜索文件 (Telescope)。
    *   `Space + g` : 全局搜索文本内容 (Live Grep)。
*   **内置终端**:
    *   `Ctrl + /` (或 `Ctrl + _`) : 弹出一个悬浮终端，适合在不退出代码的情况下快速运行编译或 Git 命令。
*   **代码分析 & LSP (语言服务器)**:
    *   `Space + d` : 跳转到函数/变量的定义。
    *   `Space + r` : 查找所有引用。
    *   `Space + xx` : 底部弹出面板，显示当前项目的所有语法错误和警告 (Trouble.nvim)。
*   **Git 管理**:
    *   `Space + gg` : 全屏打开 LazyGit 界面进行直观的 Git 提交和分支管理。

## 5. 🧑‍🏫 如何添加新软件或自定义配置？

Nix 的核心理念是“声明式”。**不要使用 `apt install` 或 `npm install -g`** 来安装全局工具，否则重启或换电脑后就丢失了。

**Q: 我想安装一个新软件（例如 `wget`），该怎么做？**
1. 打开 `~/home_env_dotfiles/nix/modules/packages.nix`。
2. 找到 `home.packages = with pkgs; [ ... ]` 列表。
3. 把 `wget` 加进列表里。
4. 终端运行 `hms`。完成！

**Q: 我想加一个新的 Alias（快捷命令），该怎么做？**
1. 打开 `~/home_env_dotfiles/nix/modules/zsh.nix`。
2. 找到 `shellAliases = { ... }` 块。
3. 添加您的命令，例如：`g = "git";`。
4. 终端运行 `hms`。新命令立即生效！

**Q: 我想添加环境变量，该怎么做？**
1. 打开 `~/home_env_dotfiles/nix/modules/zsh.nix`。
2. 找到 `programs.zsh` 中的 `initContent` 块。
3. 在 Shell 脚本内容区域（如 `export PATH=...` 的上下）添加您的逻辑。例如添加环境变量：
   ```bash
   export MY_CUSTOM_VAR="my_value"
   ```
4. 终端运行 `hms`。然后重启终端（或新开一个 Zellij 面板）即可生效！

---
**💡 提示**：如果您处于 Zellij 中且发现 Neovim 快捷键突然没反应了，请检查底部状态栏，多半是您忘记按 `Ctrl + g` 切回 Locked 模式了！