#!/bin/bash
nvim +"CocInstall coc-json coc-rls coc-yaml coc-css coc-html coc-snippets"

echo "install language-servers"

echo "install bash-language-server"
npm i -g bash-language-server
