#Generic function script
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
    reg=$1
    cmd=$2
    echo "cmd: ${cmd} reg: ${reg}"
    for element in `git status -s | grep -E "${reg}"`
    do
        if [ "$element" = 'M' -o "$element" = '??' -o "$element" = 'A' -o "$element" = 'D' ];then
            continue
        fi
        $cmd $element
    done
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

#字体颜色 30:黑 31:红 32:绿 33:黄 34:蓝色 35:紫色 36:深绿 37:白色
#背景颜色#40:黑 #41:深红 #42:绿 #43:黄色 #44:蓝色 #45:紫色 #46:深绿 #47:白色
function log_info(){
    echo -e "\033[47;32m[INFO: ] ${1}\033[0m"
}
