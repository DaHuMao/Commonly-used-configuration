source ./scrip_tool/script/tool_function.sh

log_info "check install brew"
 check_cmd brew || /bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)" \
   || log_abort "failed install brew"

check_cmd rg || brew install rg ||  log_abort "failed install rg"

log_info "check_cmd install nvim -----------------------------"
check_cmd nvim || brew install nvim || log_abort "failed install nvim"

log_info "install nvm ---------------------------------"
brew install nvm || log_abort "failed install nvm"
nvm install 13.2.0 || log_abort "nvm install failed"
nvm use 13.2.0
nvm alias default 13.2.0
log_info "successed install -----------------------------"
