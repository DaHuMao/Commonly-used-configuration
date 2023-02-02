require'lspconfig'.bashls.setup(
  {
    cmd = { "bash-language-server", "start" },
    cmd_env = { GLOB_PATTERN = "*@(.sh||.zsh|.inc|.bash|.command)" },
    filetypes = {"sh", "zsh", "bash"},
    single_file_support = true
  }
)
