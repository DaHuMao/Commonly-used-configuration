source ~/bin/tool_function.sh
official_origion=https://github.com/Homebrew/brew.git
official_brew_core=https://github.com/Homebrew/homebrew-core.git
ts_origion=https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git
ts_brew_core=https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git
ali_origion=https://mirrors.aliyun.com/homebrew/brew.git
ali_brew_core=https://mirrors.aliyun.com/homebrew/homebrew-core.git
trtc_origion=https://mirrors.cloud.tencent.com/homebrew/brew.git
trtc_brew_core=https://mirrors.cloud.tencent.com/homebrew/homebrew-core.git
ustc_origion=https://mirrors.ustc.edu.cn/brew.git
ustc_brew_core=https://mirrors.ustc.edu.cn/homebrew-core.git

pre_fix=''
echo "请选择你要切换的源：\n0：官方\n1：清华大学\n2：阿里\n3：腾讯\n4：中科大\n"
read select_origion
case $select_origion in
  0)
    pre_fix='official'
    log_info '你选择了官方源'
    ;;
  1)
    pre_fix='ts'
    log_info '你选择了清华大学源'
    ;;
  2)
    pre_fix='ali'
    log_info '你选择了阿里源'
    ;;
  3)
    pre_fix='trtc'
    log_info '你选择了腾讯源'
    ;;
  4)
    pre_fix='ustc'
    log_info '你选择了中科大源'
    ;;
  *)
    log_error 'invalid input $select_origion, you should input a num in range(0, 4)'
    exit 1
    ;;
  esac

brew_url="${pre_fix}_origion"
brew_url=${!brew_url}
brew_core_url="${pre_fix}_brew_core"
brew_core_url=${!brew_core_url}

cd "$(brew --repo)"
log_info `pwd` 'git remote set-url origin' $brew_url
git remote set-url origin $brew_url

cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
log_info `pwd` 'git remote set-url origin' $brew_core_url
git remote set-url origin $brew_core_url

log_info "brew update..."
brew update || log_abort 'faild brew update' 
log_info 'brew upgrade...'
brew upgrade

