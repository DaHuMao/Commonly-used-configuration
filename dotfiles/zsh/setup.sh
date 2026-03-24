#!/usr/bin/env bash
set -o errexit
source zsh_config/env.sh
source zsh_config/tool_function.sh
# get the dir of the current script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) && cd "$SCRIPT_DIR" || return 1

TAR_ZSH_DIR=~/.myzsh
mkdir_and_rm $TAR_ZSH_DIR

#if [ -f ~/.gitconfig ]; then
#  log_info "~/.gitconfig exists, backup to ~/.gitconfig.bak"
#  mv ~/.gitconfig ~/.gitconfig.bak
#fi
#
#mklink "$SCRIPT_DIR/gitconfig"   ~/.gitconfig

if [ -f ~/.gitconfig ];then
  cat ./gitconfig_alias >> ~/.gitconfig
  log_info "append gitconfig_alias to ~/.gitconfig"
else
  cp ./gitconfig_alias >> ~/.gitconfig
  log_info "cp gitconfig_alias to ~/.gitconfig"
fi


#如果~/.zshrc存在，且跟./zshrc不是同一个文件，则备份~/.zshrc
if [ -f ~/.zshrc ] && ! isSameFile ~/.zshrc $SCRIPT_DIR/zshrc; then
  log_info "~/.zshrc exists, mv to ~/.zshrc.bak"
  mv ~/.zshrc ~/.zshrc.bak
fi

if [ ! -f ${TAR_ZSH_DIR}/custom_config.zsh ]; then
  log_info "cp custom_config.zsh to ${TAR_ZSH_DIR}"
  cp ${SCRIPT_DIR}/custom_config.zsh ${TAR_ZSH_DIR}/custom_config.zsh
fi

mklink ${SCRIPT_DIR}/zshrc  ~/.zshrc

for ee in `ls ./`
do
  if [ -d $ee ];then
    mklink ${SCRIPT_DIR}/$ee $TAR_ZSH_DIR/$ee
  fi
done

for bin_file in `ls $TAR_ZSH_DIR/bin`
do
  chmod 777 $TAR_ZSH_DIR/bin/$bin_file
done

if is_windows; then
  if [ ! -f ~/.bashrc ]; then
    touch ~/.bashrc
  fi
  echo "export HOME=$HOME" >> $WIN_HOME/.bashrc
  echo "zsh" >> $WIN_HOME/.bashrc
else
  [[ "$SHELL" =~ "zsh" ]] || chsh -s "$(command -v zsh)"
fi

if ! is_windows; then
  source ~/.zshrc
fi
