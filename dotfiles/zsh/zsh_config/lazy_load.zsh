nvm_init_fun() {
  if [ -d $NVM_DIR ];then
    if is_macos;then
      nvm_install_path=$(brew --prefix nvm)
      if [ ! -s "${nvm_install_path}/nvm.sh" ]; then
        return 1
      fi
      [ -s "${nvm_install_path}/nvm.sh" ] && \. "${nvm_install_path}/nvm.sh"
      [ -s "${nvm_install_path}/etc/bash_completion.d/nvm" ] && \. "${nvm_install_path}/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
      #nvm use 16.20.0
    elif is_windows; then
      export PATH=$PATH:$SCOOP_HOME/nvm/current/nodejs/v16.20.0/
    fi
  fi
  return 0
}

nvm_is_loaded=0
check_load_nvm() {
  if [[ $nvm_is_loaded -eq 0 ]];then
    nvm_init_fun
    if [[ $? -ne 0 ]];then
      log_error "nvm_init_fun failed"
      return 1
    fi
    nvm_is_loaded=1
  fi
  return 0
}

yarn() {
  check_load_nvm
  if [[ $? -ne 0 ]];then
    log_error "check_load_nvm failed"
    return 1
  fi
  command yarn "$@"
}

nvm() {
  check_load_nvm
  if [[ $? -ne 0 ]];then
    log_error "check_load_nvm failed"
    return 1
  fi
  command nvm "$@"
}

