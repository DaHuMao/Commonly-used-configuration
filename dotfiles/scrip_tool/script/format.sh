source tool_function.sh

clang_format_diff_file='/Users/zhangtongxiao/Software/clang+llvm-11.0.0/share/clang/clang-format-diff.py'

pre_view='-i'
function clang_format_cmd(){
  local tar_file=`echo $1 | grep -E "$cpp_reg"`
  if [[ ! -z $tar_file && -f $tar_file ]];then
    echo clang_format_cmd $tar_file
    clang-format -style=file $pre_view $1 
  fi
}

clang_format_diff_cmd(){
  local tar_file=`echo $1 | grep -E "$cpp_reg"`
  if [[ ! -z $tar_file && -f $tar_file ]];then
    echo clang_format_diff_cmd $tar_file
    git diff $1 | $clang_format_diff_file $pre_view -p1 -style file
  fi
}

cmd=''
first_param=''
func=''
function CombineFirstParam(){
  local flag='|'
  if [ '' = "$first_param" ];then
    flag=''
  fi
  first_param=$first_param$flag$1
}

while [[ 0 < $# ]]
do
  case "$1" in
    --git)
      func='TraverseFileForGit'
      cmd='clang_format_cmd'
      shift
      ;;
    --git-diff)
      func='TraverseFileForGit'
      cmd='clang_format_diff_cmd'
      shift
      ;;
    --dir_all)
      shift
      func='TraverseFolderDoForFile'
      cmd='clang_format_cmd'
      first_param=$1
      if [[ ! -f $1 && ! -d $1 ]];then
        echo error: invalid param: --dir_all $1
        echo error: invalid dir or file: $1
        exit 1
      fi 
      shift
      ;;
    --A)
      CombineFirstParam '^\?\?'
      shift
      ;;
    --M)
      CombineFirstParam '^ M'
      shift
      ;;
    --C)
      CombineFirstParam '^M|^A'
      shift
      ;;
    --pre_view)
      pre_view=''
      shift
      ;;
    *)
      echo invalid param $1
      shift
      ;;
  esac
done
if [[ -z $func || -z $first_param || -z $cmd ]];then
  echo 'invalid command ======>>>' $func $first_param $cmd
else
  echo exec $func $first_param $cmd
  $func "$first_param" "$cmd" 
fi

#  for str in `git status -s | grep -E "\.cpp$|\.c$|\.cc$|\.h$|\.java$"`
#  do
#    file="${cur_dir}/${str}"
#    if [ -f $file ];then
#      sed -i "" 's/[ ]*$//g' $file
#      echo $file
#    fi
#  done
