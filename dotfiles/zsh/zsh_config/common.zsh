export TERM=screen-256color
export HOMEBREW_NO_AUTO_UPDATE=true

function handle_nvim_windows_exit() {
  if [[ ! -z "$SOCKET_CLIENT_FILE_PATH" ]]; then
    zsh_complete_termina_exit $CURRENT_PID
    rm -f "$SOCKET_CLIENT_FILE_PATH"
  fi
}
