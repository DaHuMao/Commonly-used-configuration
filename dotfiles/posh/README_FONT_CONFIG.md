# 字体配置说明

## 统一字体配置

所有字体相关的配置现在集中在 **`font_config.ps1`** 文件中。

### 配置文件位置

```
dotfiles/posh/font_config.ps1
```

### 配置项说明

```powershell
$script:FontConfig = @{
    # oh-my-posh 安装命令中使用的字体名称
    InstallName = "meslo"

    # Windows Terminal 和应用程序中显示的字体名称
    DisplayName = "MesloLGM Nerd Font"

    # 用于检测字体是否已安装的文件名模式
    FilePattern = "MesloLGMNerdFont-Regular.ttf"

    # 默认字体大小
    Size = 11
}
```

## 如何更换字体

只需修改 `font_config.ps1` 文件中的配置项即可：

### 示例 1: 更换为 FiraCode Nerd Font

```powershell
$script:FontConfig = @{
    InstallName = "FiraCode"
    DisplayName = "FiraCode Nerd Font"
    FilePattern = "FiraCodeNerdFont-Regular.ttf"
    Size = 11
}
```

### 示例 2: 更换为 JetBrainsMono Nerd Font

```powershell
$script:FontConfig = @{
    InstallName = "JetBrainsMono"
    DisplayName = "JetBrainsMono Nerd Font"
    FilePattern = "JetBrainsMonoNerdFont-Regular.ttf"
    Size = 12
}
```

### 示例 3: 更换为 CascadiaCode Nerd Font

```powershell
$script:FontConfig = @{
    InstallName = "CascadiaCode"
    DisplayName = "CaskaydiaCove Nerd Font"
    FilePattern = "CaskaydiaCoveNerdFont-Regular.ttf"
    Size = 11
}
```

## 如何查找可用字体

### 方法 1: 使用 oh-my-posh 命令

```powershell
oh-my-posh font install
```

会显示所有可用的 Nerd Font 列表。

### 方法 2: 访问 Nerd Fonts 官网

https://www.nerdfonts.com/font-downloads

## 配置项详解

### InstallName

- **用途**: `oh-my-posh font install` 命令中使用
- **查找方法**: 运行 `oh-my-posh font install`，列表中显示的名称即为 InstallName
- **示例**: `meslo`, `FiraCode`, `JetBrainsMono`

### DisplayName

- **用途**: Windows Terminal 和 VS Code 等应用中显示的字体名称
- **查找方法**:
  1. 安装字体后，打开 Windows Terminal 设置
  2. 在字体下拉列表中查看完整的字体名称
- **注意**: 必须与系统中安装的字体名称完全一致

### FilePattern

- **用途**: 检测字体文件是否已安装
- **位置**:
  - 系统字体: `C:\Windows\Fonts\`
  - 用户字体: `%LOCALAPPDATA%\Microsoft\Windows\Fonts\`
- **查找方法**: 安装字体后，在上述目录中查看实际的文件名
- **注意**: 通常是 `*NerdFont-Regular.ttf` 格式

### Size

- **用途**: 终端中使用的默认字体大小
- **推荐值**: 10-14
- **说明**: 可根据屏幕分辨率和个人喜好调整

## 使用的脚本

修改 `font_config.ps1` 后，以下脚本会自动使用新配置：

1. **`install_font.ps1`** - 安装字体文件
2. **`configure_terminal_font.ps1`** - 配置 Windows Terminal
3. **`pre_install.ps1`** - 自动化安装流程

无需修改任何其他文件！

## 重新配置

修改 `font_config.ps1` 后，运行以下命令应用新配置：

```powershell
# 1. 安装新字体
.\install_font.ps1

# 2. 配置 Windows Terminal 使用新字体
.\configure_terminal_font.ps1

# 3. 重启 Windows Terminal
```

## 常见字体推荐

| 字体名称 | 特点 | 适合场景 |
|---------|------|----------|
| Meslo LG | 清晰易读 | 通用，默认推荐 |
| FiraCode | 支持连字 | 编程，喜欢连字符号 |
| JetBrains Mono | 等宽优化 | 编程，IDE 集成 |
| Cascadia Code | 微软出品 | Windows 原生，现代感 |
| Hack | 极简设计 | 喜欢简洁风格 |

## 故障排除

### 问题：字体安装后仍显示方框

**原因**: DisplayName 配置不正确

**解决**:
1. 打开 Windows Terminal 设置
2. 查看字体列表中的实际名称
3. 更新 `font_config.ps1` 中的 DisplayName

### 问题：Test-NerdFont 检测不到字体

**原因**: FilePattern 配置不正确

**解决**:
1. 打开字体目录查看实际文件名
2. 更新 `font_config.ps1` 中的 FilePattern
