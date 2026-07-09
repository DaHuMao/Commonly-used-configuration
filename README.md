# Commonly-used Configuration

跨平台终端环境配置工具集，为 macOS、Windows（MSYS2/PowerShell）和 Linux 提供统一、高效的命令行工作环境。

## 目录

- [快速开始](#快速开始)
- [项目结构](#项目结构)
- [功能模块](#功能模块)
  - [ZSH 环境](#zsh-环境)
  - [Vim / Neovim](#vim--neovim)
  - [Tmux 终端复用器](#tmux-终端复用器)
  - [Plot Script 数据可视化](#plot-script-数据可视化)
  - [实用脚本工具](#实用脚本工具)
  - [Cheat Sheet 速查表](#cheat-sheet-速查表)
  - [C++ ZSH 补全模块](#c-zsh-补全模块)
  - [PowerShell 配置](#powershell-配置)
  - [Ghostty 终端配置](#ghostty-终端配置)
- [快捷键速查](#快捷键速查)
- [常见问题](#常见问题)

---

## 快速开始

### 1. 安装基础依赖

```bash
bash pre_install.sh
```

该脚本会自动检测当前操作系统，安装以下必要工具：

| 工具 | 用途 | macOS 安装方式 | Windows 安装方式 | Linux 安装方式 |
|------|------|---------------|-----------------|---------------|
| git | 版本控制 | Homebrew | Scoop/Pacman | apt |
| zsh | Shell | Homebrew | Pacman | apt |
| fzf | 模糊搜索 | Homebrew | Scoop/Pacman | apt |
| rg (ripgrep) | 文本搜索 | Homebrew | Scoop/Pacman | apt |
| fd-find | 文件查找 | Homebrew | Scoop/Pacman | apt |
| bat | 语法高亮 cat | Homebrew | Scoop/Pacman | apt |
| nvim | 编辑器 | Homebrew | Scoop/Pacman | apt |
| delta | Git diff 增强 | Homebrew | — | apt |
| tmux | 终端复用器 | Homebrew | — | apt |

### 2. 安装 ZSH 配置

```bash
cd dotfiles/zsh
bash setup.sh
```

此脚本会：
- 将 `~/.zshrc` 软链接到本项目的 `zshrc`
- 将配置目录拷贝到 `~/.myzsh/`
- 自动追加 Git 别名到 `~/.gitconfig`
- 在非 Windows 平台上自动切换默认 Shell 为 ZSH

### 3. 安装 Vim / Neovim 配置

```bash
cd dotfiles/vim
bash setup.sh
```

### 4. 安装 Tmux 配置

```bash
cd dotfiles/tmux
bash setup.sh
```

### 5. 编译 C++ ZSH 补全模块（可选，推荐）

macOS：
```bash
cd dotfiles/cpp
bash build_mac.sh
```

Windows：
```bash
cd dotfiles/cpp
bash build_win.sh
```

编译产物为 `libcustom_zsh_complete.so`，提供高性能历史命令前缀搜索和自动补全功能。

---

## 项目结构

```
.
├── pre_install.sh              # 一键安装基础依赖
├── README.md                   # 本文件
└── dotfiles/
    ├── config.ghostty          # Ghostty 终端配置
    ├── cheat/                  # 常用工具速查表
    │   ├── docker              # Docker 常用命令
    │   ├── kubectl             # Kubernetes 常用命令
    │   ├── redis               # Redis 常用命令
    │   └── selinux             # SELinux 常用命令
    ├── cpp/                    # C++ ZSH 补全模块源码
    │   ├── src/                # 核心逻辑 (base, zsh_complete, zsh_module_common)
    │   ├── build_mac.sh        # macOS 编译脚本
    │   └── build_win.sh        # Windows 编译脚本
    ├── posh/                   # Windows PowerShell 配置
    │   ├── init.ps1            # 初始化入口
    │   └── setup.ps1           # 环境安装脚本
    ├── scrip_tool/
    │   ├── plot_script/        # 数据可视化工具
    │   │   ├── plot_start.sh   # 绘图入口脚本
    │   │   ├── run_plot.py     # 绘图主程序
    │   │   └── plot/           # 绘图核心代码
    │   └── script/             # 实用脚本
    │       ├── dezip.sh        # 通用解压工具
    │       ├── format.sh       # C++ 代码格式化
    │       ├── git-add.sh      # Git 文件选择性添加
    │       ├── countp.sh       # 进程数统计
    │       └── brew_origion.sh # Homebrew 源管理
    ├── tmux/
    │   ├── tmux.conf           # Tmux 主配置
    │   ├── setup.sh            # Tmux 安装脚本
    │   └── tmuxinator/         # Tmuxinator 会话模板
    ├── vim/
    │   ├── init.vim            # Neovim 入口
    │   ├── lua/                # Lua 插件配置 (lazy.nvim, LSP, Treesitter)
    │   ├── configs/            # 模块化 Vimscript 配置
    │   └── setup.sh            # Vim 安装脚本
    └── zsh/
        ├── zshrc               # ZSH 入口文件
        ├── zsh_config/         # 模块化配置目录
        ├── bin/                # ZSH 专用脚本
        ├── custom_config.zsh   # 用户自定义配置模板
        ├── custom_prompt/      # 自定义命令模板
        └── setup.sh            # ZSH 安装脚本
```

---

## 功能模块

### ZSH 环境

核心配置文件加载顺序（`zshrc` → `~/.myzsh/zsh_config/`）：

| 文件 | 功能 |
|------|------|
| `env.sh` | 环境变量、平台检测 |
| `tool_function.sh` / `tool_function.zsh` | 通用工具函数 |
| `zsh_define.zsh` | 基础定义 |
| `common.zsh` | 通用配置 |
| `zsh_history_config.zsh` | 历史记录配置 |
| `cmd_function.zsh` | 自定义命令函数 |
| `zsh_zinit.zsh` | Zinit 插件管理器配置 |
| `lazy_load.zsh` | nvm / yarn 懒加载 |
| `zsh_aliases.zsh` | 命令别名 |
| `fzf.zsh` | FZF 基础配置 |
| `zsh_fzf_extra.zsh` | FZF 深度集成（见下文） |
| `vi_mode.zsh` | Vi 模式配置 |
| `zsh_theme.zsh` | 主题配置 |
| `zsh_complete.zsh` | C++ 加速补全 |

#### 别名速查

| 别名 | 实际命令 | 说明 |
|------|---------|------|
| `bat` | `bat --color=always --theme=TwoDark` | 语法高亮查看文件 |
| `cat` | `/bin/cat` | 原始 cat（避免与 bat 冲突） |
| `fdf` | `fd --type f --no-ignore-vcs ...` | 查找文件 |
| `fdd` | `fd --type d --no-ignore-vcs ...` | 查找目录 |
| `fdall` | `fd -I -a --hidden --follow ...` | 查找所有（含隐藏） |
| `rgg` | `rg --column --line-number --no-heading ...` | 格式化搜索 |
| `rgall` | `rg --no-ignore` | 搜索所有文件 |

#### C++ 加速补全（核心特性）

这是本项目区别于普通 dotfiles 的核心功能。传统 ZSH 补全使用 Shell 脚本，大量历史记录时响应缓慢。本项目通过 C++ 编写 ZSH 模块（`libcustom_zsh_complete.so`），实现：

- **前缀补全**：输入命令前缀时，自动以灰色显示匹配的历史命令建议
- **↑↓ 键历史搜索**：按上/下键时，在匹配当前输入前缀的历史命令中循环
- **后台服务架构**：通过 Unix Domain Socket 与服务进程 `zsh_complete_server` 通信，实现持久化历史索引

> 补全数据存储在 `$ZSH_COMPETE_DIR`（默认为 `~/.myzsh/zsh_complete/`）

#### FZF 深度集成（`Ctrl+F`）

`Ctrl+F` 是本环境的核心交互键。按下后会根据当前输入内容**智能切换**行为：

| 场景 | 触发的 FZF 数据源 |
|------|------------------|
| 空命令 | 显示 `custom_prompt/remind_cmd` 中的命令模板 |
| 输入匹配 `.prompt` 文件 | 显示对应的自定义命令列表 |
| `git` + 文件操作 | 显示 `git status` 结果，可预览文件 diff |
| `git lg / rebase / show / revert` | 显示 `git log`，可预览 commit 详情 |
| `git co` / `cob` | 显示分支列表 |
| `cd / mkdir / touch` | 显示目录列表 |
| 其他路径相关 | 显示文件/目录列表，支持深度预览 |
| `remove_branch` | 显示分支列表 |

**FZF 历史搜索**：`Ctrl+R` 对历史命令进行模糊搜索。

**特殊参数**：在命令末尾加 `--` 后跟参数可以影响 FZF 行为，例如 `git --only-modify` 只显示修改的文件。

#### 自定义命令模板

将常用命令写入 `~/.myzsh/custom_prompt/` 目录下的 `.prompt` 文件，然后：
1. 在空命令行按 `Ctrl+F` 可浏览所有模板
2. 输入文件名前缀（不含 `.prompt`）再按 `Ctrl+F` 可直接搜索该文件中的命令

#### 懒加载

`nvm` 和 `yarn` 采用懒加载策略，首次使用时才初始化，显著提升终端启动速度。

---

### Vim / Neovim

基于 `lazy.nvim` 的现代化 Neovim 配置，集成以下能力：

- **LSP 支持**：通过 Mason 管理 Language Server，提供代码补全、跳转、诊断
- **Treesitter**：精确的语法高亮和代码结构解析
- **Copilot**：GitHub Copilot AI 辅助编码
- **DAP 调试**：内置调试器支持
- **FZF 集成**：文件搜索、Buffer 切换、Rg 搜索等

Vim 配置同时兼容 Vim 和 Neovim（通过 `init.vim` + `~/.vimrc` 双软链接）。

---

### Tmux 终端复用器

#### 前缀键自动切换

| 场景 | 前缀键 | 说明 |
|------|--------|------|
| 本地终端 | `Ctrl+X` | 避免与终端快捷键冲突 |
| SSH 远程 | `Alt+Q` | 避免与本地 tmux 冲突 |

#### 面板操作

| 快捷键 | 功能 |
|--------|------|
| `前缀 + h/j/k/l` | 切换面板 |
| `前缀 + H/J/K/L` | 调整面板大小（每次 ±4） |
| `前缀 + _` | 水平分割（下方新建） |
| `前缀 + \|` | 垂直分割（右侧新建） |
| `前缀 + tab` / `前缀 + btab` | 循环切换面板 |
| `前缀 + f` | FZF 弹窗切换窗口 |
| `前缀 + s` | FZF 弹窗切换面板 |

#### 窗口操作

| 快捷键 | 功能 |
|--------|------|
| `前缀 + <` / `前缀 + >` | 交换窗口位置 |
| `前缀 + .` | 重命名会话 |
| `前缀 + m` | 切换工作目录到当前面板路径 |
| `前缀 + r` | 重新加载配置 |

#### 复制模式（Vi 风格）

| 快捷键 | 功能 |
|--------|------|
| `前缀 + [` | 进入复制模式 |
| `v` | 开始选择 |
| `Ctrl+V` | 矩形选择 |
| `y` | 复制并退出 |
| `Esc` | 取消 |

#### 状态栏

集成了 Dracula 主题，显示 CPU 使用率、GPU 使用率、内存、电池和时间信息。

#### Tmuxinator

`tmuxinator/` 目录下存放预定义的 tmux 会话模板，通过 tmuxinator 工具快速启动工作区。

---

### Plot Script 数据可视化

一个强大的命令行数据可视化工具，支持从日志文件或网络流中提取数据并绘图。

#### 快速使用

```bash
cd dotfiles/scrip_tool/plot_script
bash plot_start.sh /path/to/your/log.txt
```

#### 核心配置项

编辑 `plot_start.sh` 中的参数来控制绘图行为：

**工作模式**：

| 参数 | 值 | 说明 |
|------|-----|------|
| `work_mode` | `file_mode` | 从文件读取数据，绘制静态图 |
| `work_mode` | `stream_mode` | 从网络流实时读取，动态更新图表 |

**图表类型**：

| 参数 | 值 | 说明 |
|------|-----|------|
| `plot_type` | `line` | 折线图 |
| `plot_type` | `histogram` | 直方图 |

**数据提取**（三种方式，优先级从高到低）：

| 参数 | 说明 | 示例 |
|------|------|------|
| `select_y_key_multi_line` | 跨行提取关键词的值 | `soft_bitrate,soft_keyframe_size` |
| `select_y_key` | 同行提取关键词的值 | `audio_delay video_delay` |
| `select_y_raw` | 按列号提取 | `2 5`（空格分隔=多图，逗号分隔=同图多线） |

**数据过滤**：

| 参数 | 说明 |
|------|------|
| `filter_include_keywords` | 只解析包含指定关键词的行 |
| `filter_exclude_keywords` | 跳过包含指定关键词的行 |
| `reg_pattern_include` | 正则匹配保留 |
| `reg_pattern_exclude` | 正则匹配排除 |
| `split_pattern_reg` | 字符串分割正则（默认按空格/冒号/逗号/引号） |

**图表外观**：

| 参数 | 说明 | 示例 |
|------|------|------|
| `title` | 图标题 | `"RTT audio_delay/video_delay"` |
| `legend_name` | 图例名称 | `"cpu mem"` |
| `xtitle` / `ytitle` | 轴标签 | `"time(ms)"` / `"百分比%"` |
| `y_show_range` | Y 轴显示范围 | `"0,700 null -100,200"` |
| `x_show_range` | X 轴显示范围 | `"3000,3000"` |
| `point_size` | 平滑采样粒度 | `3`（3个点取均值） |
| `show_xlabel` | X 轴标签显示控制 | `"all"` 或 `"1 0 1"` |
| `is_raw_arrange` | 多图排列方式 | `1`（行优先）/ `0`（列优先） |
| `plot_arrange_way` | 行列分割数 | `"2 1 2"` |

**直方图特有**：

| 参数 | 说明 | 示例 |
|------|------|------|
| `width` | 直方筒宽度比例 | `0.5` |
| `x_classification` | X 轴区间划分 | `"1-4,4-6,6-10"`（左闭右开） |

#### 流模式

设置 `work_mode='stream_mode'`，配置 `ip` 和 `port`，工具会启动 TCP 服务器接收实时数据并动态绘图。`data_storage_len` 控制缓冲区长度。

---

### 实用脚本工具

#### `dezip.sh` — 通用解压

自动识别压缩格式并解压：

```bash
bash dezip.sh <压缩文件> [解压目录]
```

支持的格式：`.tar.gz`、`.tgz`、`.tar`、`.gz`、`.tar.bz2`、`.bz2`、`.zip`、`.rar`

#### `format.sh` — C++ 代码格式化

基于 `clang-format` 的 C++ 代码格式化工具：

```bash
# 格式化 Git 暂存区中修改/新增的 C++ 文件
bash format.sh --git --C

# 格式化指定目录下所有 C++ 文件
bash format.sh --dir_all /path/to/src

# 仅预览格式化结果（不实际修改）
bash format.sh --git --M --pre_view

# 格式化 Git diff 中的 C++ 文件
bash format.sh --git-diff --M
```

| 选项 | 说明 |
|------|------|
| `--git` | 针对 Git 工作区文件 |
| `--git-diff` | 针对 Git diff 文件 |
| `--dir_all <路径>` | 针对指定目录 |
| `--A` | 新增文件（`??`） |
| `--M` | 已修改文件（` M`） |
| `--C` | 已修改 + 新增 |
| `--pre_view` | 仅预览不修改 |

#### `git-add.sh` — Git 选择性添加

灵活选择 Git 文件执行操作：

```bash
# 添加所有修改和新增的 C++ 文件
bash git-add.sh --git --add --C

# 仅打印匹配的文件列表（不执行操作）
bash git-add.sh --git --print --M

# 将匹配的文件路径写入文件
bash git-add.sh --git --write_file filelist.txt --M --A

# 从文件读取文件列表并 git add
bash git-add.sh --read_file filelist.txt
```

| 选项 | 说明 |
|------|------|
| `--git` | 从 Git 工作区遍历 |
| `--add` | 执行 `git add` |
| `--print` | 仅打印文件名 |
| `--write_file <文件>` | 写入文件列表 |
| `--read_file <文件>` | 从文件读取 |
| `--Q` | 未跟踪文件 |
| `--A` | 已暂存新增 |
| `--M` | 已修改 |
| `--MM` | 暂存区修改 |
| `--D` | 已删除 |
| `--C` | 修改 + 新增 + 暂存修改 |
| `--e <关键词>` | 文件名包含关键词 |
| `--E <正则>` | 文件名匹配正则 |
| `--V <关键词>` | 排除关键词 |

---

### Cheat Sheet 速查表

`dotfiles/cheat/` 目录下存放常用工具的简明命令备忘录：

| 文件 | 内容 |
|------|------|
| `docker` | Docker 容器管理命令 |
| `kubectl` | Kubernetes 集群操作命令 |
| `redis` | Redis 数据库命令 |
| `selinux` | SELinux 安全策略命令 |

---

### C++ ZSH 补全模块

源码位于 `dotfiles/cpp/src/`，包含：

- **`zsh_complete/`**：高性能建议引擎，包含前缀搜索、历史索引、Unix Socket 服务端
- **`zsh_module_common/`**：ZSH 模块通用基础设施
- **`base/`**：底层工具库

编译要求：
- CMake 3.x
- Clang 或 GCC
- ZSH 开发头文件

---

### PowerShell 配置

位于 `dotfiles/posh/`，为 Windows PowerShell 提供 Oh-My-Posh 美化配置：

```powershell
# 初始化
. .\init.ps1

# 完整安装
.\setup.ps1
```

---

### Ghostty 终端配置

`dotfiles/config.ghostty` 提供 Ghostty 终端模拟器的精简配置：

- macOS Option 键映射为 Alt（兼容 ZSH vi mode 中的 Meta 键绑定）
- 禁用 Alt+Left/Right 的默认行为（防止与自定义光标移动冲突）

---

## 快捷键速查

### ZSH 全局快捷键

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+F` | FZF 智能选择（文件 / Git / 命令模板） |
| `Ctrl+R` | FZF 历史命令搜索 |
| `Ctrl+E` | 接受建议或跳到行尾 |
| `Ctrl+J` | 清空当前行 |
| `Ctrl+N` | 光标移动到下一个非字母字符 |
| `Ctrl+B` | 光标移动到上一个非字母数字字符 |
| `→` | 接受灰色建议（逐字符） |
| `↑` / `↓` | 在匹配当前前缀的历史命令中搜索 |
| `Alt+←` / `Alt+→` | 按单词前后移动 |
| `Alt+↑` / `Alt+↓` | 快速半屏移动光标 |

### Tmux 前缀键

| 环境 | 前缀键 |
|------|--------|
| 本地 | `Ctrl+X` |
| SSH | `Alt+Q` |

---

## 常见问题

### ZSH 启动时报 "zsh_complete_build_checker.zsh failed"

需要先编译 C++ 补全模块：

```bash
cd dotfiles/cpp
bash build_mac.sh   # macOS
# 或
bash build_win.sh   # Windows
```

如果不需要此功能，也可以注释掉 `zshrc` 中 `SourceSh $ZSH_CONFIG_DIR/zsh_complete.zsh` 这一行。

### Tmux 前缀键不生效

检查是否在 SSH 会话中 — SSH 下前缀键会自动切换为 `Alt+Q`。

### `Ctrl+F` 没有反应

确认 `fzf` 和 `fd` 已正确安装：

```bash
which fzf fd
```

### 如何在多台机器间同步配置

将本项目目录放到任意位置，分别在每台机器上运行各模块的 `setup.sh` 即可。配置通过软链接关联，修改源文件即对所有机器生效。

### 如何添加自定义 ZSH 配置

编辑 `~/.myzsh/custom_config.zsh`，此文件在 zshrc 最后被加载，不会被 setup.sh 覆盖。
