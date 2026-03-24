export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-14.0.1.jdk/Contents/Home
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export ANDROID_NDK_ROOT=$HOME/Library/Android/sdk/ndk/23.1.7779620
export PATH=${PATH}:${ANDROID_SDK_ROOT}/tools
export PATH=${PATH}:${ANDROID_SDK_ROOT}/platform-tools
export PATH=${PATH}:${ANDROID_SDK_ROOT}/tools/bin
export PATH=${PATH}:${ANDROID_SDK_ROOT}/emulator
export PATH=$PATH:$ANDROID_SDK_ROOT/tools
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH
export PATH="$PATH:/usr/bin/conda/bin"
export PATH="/usr/local/opt/conan@1/bin:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/opt/conan@1/bin:$PATH"
export PATH="$PATH:/opt/homebrew/anaconda3/bin"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.pyenv/shims/:$PATH"
export CLANG_FORMAT_PATH=/opt/homebrew/Cellar/clang-format/18.1.5/share/clang/clang-format.py
export VIM_USED_NODE_BIN="$HOME/.nvm/versions/node/v20.0.0/bin/node"



# depot_tools
#export PATH=$PATH:$HOME/GitDownLoad/live_infra_depod_tools/
export DEPOT_TOOLS_UPDATE=0
export DASHSCOPE_API_KEY=sk-939a6fdd6903496db9ca4ae65df255e0

alias code="~/Desktop/software/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code"
alias python="/usr/local/bin/python2"
alias vim=nvim
alias vi=nvim

#conda config --set auto_activate_base false
export CLAUDE_CODE_USE_BEDROCK=1
export CLAUDE_CODE_AWS_PROFILE=claude-profile
export ANTHROPIC_MODEL='arn:aws:bedrock:us-west-2:027950631154:application-inference-profile/lxg1tqrgp16d'
export AWS_REGION=us-west-2
export ANTHROPIC_DEFAULT_HAIKU_MODEL='us.anthropic.claude-3-5-haiku-20241022-v1:0'

review(){
branch_name=`git rev-parse --abbrev-ref HEAD`
if [ -z "$branch_name" ];then
    echo "! [Branch name missing]"
    echo "请在git仓库根目录执行"
    return
fi
reviewers="r=wangcb,r=pengyang,r=zhaoguanxun,r=zhufan,r=gaocy01,r=liguang,r=zhangzhebj03,r=gaoyubj03"
push_command="git push origin HEAD:refs/for/"${branch_name}%${reviewers}
eval $push_command
}

function auditon() {
  local external_command=""
  if [ $# -ge 1 ]; then
    external_command="--open $1"
  fi
  local cmd = "nohup /Applications/Adobe\ Audition\ 2024/Adobe\ Audition\ 2024.app/Contents/MacOS/Adobe\ Audition\ 2024 $external_command > /dev/null 2>&1 &"
  eval $cmd
}
