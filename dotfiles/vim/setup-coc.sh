#!/bin/bash
source ../scrip_tool/script/tool_function.sh
function  install_pip() {
  version=$1
  check_cmd pip$version || (curl -O https://bootstrap.pypa.io/get-pip.py && \
    sudo python$version get-pip.py || exit 1)
  check_cmd pip3 && pip3 install python-language-server || exit 1
}

log_info "========================== check install nvm node"
check_cmd nvm ||  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash || exit 1
check_cmd node || nvm install node || exit 1

log_info "========================== CocInstall"
nvim +"CocInstall coc-json coc-rls coc-yaml coc-css coc-html coc-snippets coc-ccls coc-sh coc-pyright coc-vimlsp"

log_info "========================== install bash-language-server"
npm i -g bash-language-server

log_info "========================== pip2 pip3"
install_pip 3
install_pip 2

install_cmd=brew
check_cmd apt-get && install_cmd="sudo apt-get"
$install_cmd install ccls

