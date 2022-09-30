#!/bin/bash

function check_cmd() {
  cmd=$1
  #hash $cmd &>/dev/null && return 0
  type $cmd &>/dev/null && return 0
  echo $cmd is not install
  return 1
}

function  install_pip() {
  version=$1
  check_cmd pip$version || (curl -O https://bootstrap.pypa.io/get-pip.py && \
    sudo python$version get-pip.py || exit 1)
  check_cmd pip3 && pip3 install python-language-server || exit 1
}


echo "========================== install nvm node"
if [ ! -d ~/.vim ];then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
fi
check_cmd node || nvm install node

echo "========================== CocInstall"
nvim +"CocInstall coc-json coc-rls coc-yaml coc-css coc-html coc-snippets coc-ccls coc-sh coc-pyright coc-vimlsp"

echo "========================== install bash-language-server"
npm i -g bash-language-server

echo "========================== pip2 pip3"
install_pip 3
install_pip 2

install_cmd=brew
check_cmd apt-get && install_cmd="sudo apt-get"
$install_cmd install ccls

