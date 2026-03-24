# Oh My Posh 字体安装指南

## 为什么需要安装 Nerd Font？

Oh My Posh 使用特殊的图标字符来显示美化的提示符，这些图标包含在 **Nerd Fonts** 中。如果不安装 Nerd Font，你会看到：
- ❌ 乱码或方框 (□)
- ❌ 问号 (?)
- ❌ 缺失的图标

安装 Nerd Font 后，你会看到：
- ✅ Git 分支图标
- ✅ 文件夹图标 📁
- ✅ 各种语言和工具的图标 (Node.js, Python, etc.)

## 自动安装（推荐）

### 方法 1: 运行 pre_install.ps1
```powershell
# 以管理员身份运行 PowerShell
cd C:\Users\hdzha\vim_config\dotfiles\posh
.\pre_install.ps1
```

`pre_install.ps1` 会自动：
1. 检查字体是否已安装
2. 如果未安装，自动安装 Meslo Nerd Font
3. 提示你配置终端使用该字体

### 方法 2: 单独安装字体
```powershell
# 无需管理员权限
cd C:\Users\hdzha\vim_config\dotfiles\posh
.\install_font.ps1
```

## 手动安装

如果自动安装失败，可以手动安装：

```powershell
oh-my-posh font install meslo
```

或者从官网下载：
- 访问: https://www.nerdfonts.com/font-downloads
- 下载 **Meslo** 字体
- 解压并安装 .ttf 文件

## 配置终端使用 Nerd Font

### Windows Terminal

1. 打开 Windows Terminal
2. 按 `Ctrl+,` 打开设置
3. 选择你的 PowerShell 配置文件
4. 点击 **"外观"** (Appearance) 标签
5. 在 **"字体"** (Font face) 下拉菜单中选择: **MesloLGM NF**
6. 保存并重启终端

### VS Code 集成终端

1. 打开 VS Code 设置 (`Ctrl+,`)
2. 搜索: `terminal.integrated.fontFamily`
3. 设置值为: `MesloLGM NF`
4. 重启 VS Code

### 其他终端

- **PowerShell 控制台**: 右键标题栏 → 属性 → 字体 → 选择 MesloLGM NF
- **ConEmu**: Settings → General → Fonts → 选择 MesloLGM NF

## 验证安装

安装并配置字体后，重新打开终端，你应该能看到：

```
 ~/vim_config  master
❯
```

而不是乱码或方框。

## 推荐的 Nerd Font

- **Meslo LGM NF** (推荐，已在脚本中配置)
- Fira Code Nerd Font
- JetBrains Mono Nerd Font
- Cascadia Code Nerd Font

## 常见问题

### Q: 安装后仍然显示乱码？
A: 请确保你已经在终端设置中选择了 Nerd Font，并重启了终端。

### Q: 字体看起来很奇怪？
A: 某些终端可能需要调整字体大小。建议使用 10-12pt。

### Q: 我想使用其他 Nerd Font？
A: 运行 `oh-my-posh font install` 查看所有可用字体并选择。

## 更多信息

- Oh My Posh 官方文档: https://ohmyposh.dev/docs/installation/fonts
- Nerd Fonts 官网: https://www.nerdfonts.com/
