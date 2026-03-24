#Generic function script
#获取当前文件所在目录
function getScriptDir(){
  echo $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
  #echo $(dirname "$0")
}
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
#输出数组 1 2 3$'\n'
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

#裁剪字符串中某个字符最后一次出现之前的字符串
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

#判断两个文件是不是同一个文件
#1. 如果是软链接，获取软链接的真实绝对路径
#2. 如果不是软链接，获取绝对路径
#3. 比较两个路径是否相同
function isSameFile(){
  local file1=$1
  local file2=$2
  if [ -L $file1 ];then
    file1=$(readlink -f $file1)
  else
    file1=$(realpath $file1)
  fi
  if [ -L $file2 ];then
    file2=$(readlink -f $file2)
  else
    file2=$(realpath $file2)
  fi
  if [ $file1 = $file2 ];then
    return 0
  else
    return 1
  fi
}

#时间获取
if is_macos;then
  alias date=/usr/local/opt/coreutils/libexec/gnubin/date
fi
function TimeStampMs() {
  echo $(($(date +%s%N)/1000000))
}

#判断某个命令是否存在
function check_cmd() {
  cmd=$1
  #hash $cmd &>/dev/null && return 0
  type $cmd &>/dev/null && log_info "${cmd} is already installed" && return 0
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

function power_shell() {
  if is_windows;then
    PowerShell.exe -NoProfile -Command "${@}"
  fi
}

function convert_to_win_path() {
  # 检查参数是否为空
  if [ -z "$1" ]; then
    echo "convert_path: path is empty"
    return 1
  fi

  # 提取驱动器字母并转换成大写
  drive_letter=$(echo $1 | cut -d '/' -f 2 | tr '[:lower:]' '[:upper:]')

  # 检查驱动器字母是否符合要求（只针对c,d,e,f）
  if [[ ! $drive_letter =~ ^[CDEFG]$ ]]; then
    echo $1
    return 0
  fi

  # 构建新路径
  # 使用sed来替换路径格式，去掉开头的/，替换第一个字符（驱动器）后面的/为:
  new_path=$(echo $1 | sed -E "s|^/([cdef])|\U\1:|I")
  #| sed "s|/|\\\\|g")

  # 输出新路径
  echo $new_path
}


function mklink() {
  if [ $# -ne 2 ]; then
    log_error "mklink: parameter error, usage: mklink src dest"
    return 1
  fi
  if [ -L $2 ]; then
    log_warn "$2 already exist"
    return 0
  fi
  src=$1
  dest=$2
  if is_windows;then
    src=$(convert_to_win_path $src) || { log_error "convert_path error: $src"; return 1; }
    dest=$(convert_to_win_path $dest) ||{ log_error "convert_path error: $dest"; return 1; }
    log_info "mklink: $src -> $dest"
    PowerShell.exe -NoProfile -Command "New-Item -ItemType SymbolicLink -Path $dest -Target $src" && return 0
  else
    log_info "mklink: $src -> $dest"
    ln -sf $src $dest && return 0
  fi
  log_error "mklink: $src -> $dest failed"
  return -1
}

function safe_mkdir() {
  if [ ! -d $1 ];then
    mkdir -p $1
    log_info "mkdir $1"
  else
    log_info "$1 is already exits"
  fi

}

if is_windows;then
  function open() {
    PowerShell.exe -Command " Invoke-Item $1"
  }
fi

function mkdir_and_mv() {
  if [ -d $1 ]; then
    log_info "Backup $1 to $1.bak"
    mv $1 $1.bak
  fi
  mkdir $1
}

function mkdir_and_rm() {
  if [ -d $1 ]; then
    log_info "$1 is already exits, remove it"
    rm -rf $1
  fi
  mkdir $1
}

function mklink_and_rm() {
  if [ -L $2 ]; then
    log_info "$2 is already exits, remove it"
    rm -rf $2
  fi
  mklink $1 $2
}

function get_file_real_dir() {
  if [ ! -f $1 ]; then
    log_abort "get_file_real_dir: $1 not found"
  fi
  local file=$(readlink -f "$1" 2> /dev/null || realpath "$1" 2> /dev/null || echo "$1")
  echo "$(dirname "$file")"
}





