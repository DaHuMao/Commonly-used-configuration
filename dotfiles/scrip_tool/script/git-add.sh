source tool_function.sh

function git_add_cmd(){
  echo git_add_cmd $1
  git add $1
}

function write_to_file(){
  echo write_to_file $2 $1
  echo $2 >> $1
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
    --add)
      cmd='git_add_cmd'
      shift
      ;;
    --git)
      func='TraverseFromGit'
      shift
      ;;
    --write_file)
      shift
      func='TraverseFromGit'
      cmd="write_to_file $1"
      shift
      ;;
    --read_file)
      shift
      TraverseFileDoforStr $1 . git_add_cmd
      exit 0
      func='TraverseFileDoforStr'
      first_param="$1 ."
      shift
      ;;
    --A)
      CombineFirstParam '\?\?'
      shift
      ;;
    --M)
      CombineFirstParam '^ M'
      shift
      ;;
    --C)
      CombineFirstParam '^M|^A|^D'
      shift
      ;;
    --D)
      CombineFirstParam '^ D'
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
