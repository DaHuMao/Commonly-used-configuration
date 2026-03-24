# Centralized font configuration for Oh My Posh
# Modify this file to change the font used across all scripts

# Font configuration
$script:FontConfig = @{
    # The font name as it appears in oh-my-posh font list
    InstallName = "meslo"

    # The font name as it appears in terminal settings
    DisplayName = "MesloLGM Nerd Font"

    # Font file name pattern for detection
    FilePattern = "MesloLGMNerdFont-Regular.ttf"

    # Default font size
    Size = 11
}

# Export configuration
function Get-FontConfig {
    return $script:FontConfig
}

# Helper function to get install command
function Get-FontInstallCommand {
    return "oh-my-posh font install $($script:FontConfig.InstallName)"
}
