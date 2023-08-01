#Generic function script

#字符替换
#example stringSubstitution 1_2_3 '_' '/'
#输出 1/2/3
function stringSubstitution(){
  local str=$1
  local src=$2
  local dest=$3
  echo ${str//$src/$dest}
}

#字符串切割数组
#example stringSplit 1_2_3 '_'
#输出数组 1 2 3
function stringSplit(){
  local str=$1
  local src=$2
  local dest=' '
  echo ${str//$src/$dest}
}

#裁剪字符串中某个字符第一次出现之前的字符串
#example substrFrontFirst 1_2_3 '_'
#output: 1
function substrFrontFirst(){
    echo ${1%%$2*}
}

#裁剪字符串中某个字符最后一次出现之前的字符串
#example substrFrontLast 1_2_3 '_'
#output 1_2
function substrFrontLast(){
    echo ${1%$2*}
}

#裁剪字符串中某个字符第一次出现之后的字符串
#example substrBackFirst 1_2_3 '_'
#output 2_3
function substrBackFirst(){
    echo ${1#*$2}
}

#裁剪字符串中某个字符最后一次出现之后的字符串
#example substrBackLast 1_2_3 '_'
#output 3
function substrBackLast(){
    echo ${1##*$2}
}

function getFileDir(){
  echo ${1%/*}
}

function getFileName(){
  echo ${1##*/}
}

function getFileSuffix(){
  echo ${1##*.}
}

function getFileNameWithoutSuffix(){
  echo ${1%.*}
}

function getFileNameWithoutSuffixAndPath(){
  file_name=${1##*/}
  echo ${file_name%.*}
}

#时间获取
function TimeStampMs() {
  echo $(($(date +%s%N)/1000000))
}

#日志打印格式化
#字体颜色 30:黑 31:红 32:绿 33:黄 34:蓝色 35:紫色 36:深绿 37:白色
#背景颜色#40:黑 #41:深红 #42:绿 #43:黄色 #44:蓝色 #45:紫色 #46:深绿 #47:白色
function log_info(){
    echo "\033[40;32m[INFO] ${@}\033[0m"
}

function log_warn(){
    echo "\033[40;33m[WARNING] ${@}\033[0m"
}

function log_error(){
    echo "\033[40;31m[ERROR] ${@}\033[0m"
}

function log_abort() {
  if [ $# -gt 0 ];then
    log_error $@
  fi
  exit 1
}

#判断某个命令是否存在
function check_cmd() {
  cmd=$1
  #hash $cmd &>/dev/null && return 0
  type $cmd &>/dev/null && log_info "${cmd} is aready installed" && return 0
  log_info "${cmd} is not install"
  return 1
}

function traversalFolder(){
  for element in `ls $1`
  do
    dir_or_file=$1"/"$element
    if [ -d $dir_or_file ] && [[ $2 != '' ]];then
      $2 $dir_or_file
    elif [ -f $dir_or_file ] && [[ $3 != '' ]];then
      $3 $dir_or_file
    fi
  done
}

function recursiveTraversalFolder() {
  for element in `ls $1`
  do
    dir_or_file=$1"/"$element
    if [ -d $dir_or_file ];then
      recursiveTraversalFolder $dir_or_file $2
    elif [ -f $dir_or_file ] && [[ $2 != '' ]];then
      $2 $dir_or_file
    fi
  done
}

function TraverseFromGit(){
    cmd=$1
    filter=$2
    traversal_cmd="git status -s | $filter"
    log_info TraverseFromGit traversal_cmd: $traversal_cmd
    for element in `eval $traversal_cmd`
    do
        if [ "$element" = 'M' -o "$element" = '??' -o "$element" = 'A' -o "$element" = 'D' -o "$element" = 'MM' ];then
            continue
        fi
        $cmd $element
    done
}

function TestCmdTimeConsuming() {
  local cmd=$1
  local time_tmp1=$(TimeStampMs)
  eval $cmd
  local time_tmp2=$(TimeStampMs)
  local time_gap=$((time_tmp2 - time_tmp1))
  log_info "${cmd}, it takes ${time_gap} ms"
}

function SourceSh() {
  TestCmdTimeConsuming "source ${1}"
}



