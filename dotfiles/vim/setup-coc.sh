#!/bin/bash
nvim +"CocInstall coc-json coc-rls coc-yaml coc-css coc-html coc-snippets"

echo "install language-servers"

echo "install bash-language-server"
npm i -g bash-language-server
which pip3 || (curl -O https://bootstrap.pypa.io/get-pip.py && \
  sudo python3 get-pip.py && \
  sudo python2 get-pip.py || exit 1)
pip3 install python-language-server
pip2 install python-language-server
brew install ccls

