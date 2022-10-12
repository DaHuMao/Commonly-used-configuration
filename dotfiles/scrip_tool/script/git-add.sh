source tool_function.sh

function git_add_cmd() {
  log_info git_add_cmd $1
  git add $1
}

function print() {
  log_info 'print' $1
}

function write_to_file() {
  log_info write_to_file $2 $1
  echo $2 >> $1
}

function grep_filter() {
  grep_param=''
  while [[ 0 < $# ]]
  do
    case "$1" in
      -e)
        shift
        if [ ! -z "${1}" ];then
          grep_param="${grep_param} | grep ${1}"
        fi
        shift
        ;;
      -E)
        shift
        if [ ! -z "${1}" ];then
          grep_param="${grep_param} | grep -E \"${1}\""
        fi
        shift
        ;;
      -v)
        shift
        if [ ! -z "${1}" ];then
          grep_param="${grep_param} | grep -v ${1}"
        fi
        shift
        ;;
      -ee)
        shift
        if [ ! -z "${1}" ];then
          grep_param="${grep_param} | grep -e ${1}"
        fi
        shift
        ;;
       *)
        log_error invalid param $1 >&2
        shift
        ;;
    esac
  done
  log_info "filter_cmd: cat $grep_param" >&2
  echo `eval cat $grep_param`
}

cmd=''
e_param=''
E_param=''
v_param=''
ee_param=''
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
    --print)
      cmd='print'
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
    --V)
      shift
      v_param=`stringSubstitution "${1}" '|' " | grep -v "`
      shift
      ;;
    --e)
      shift
      ee_param=$1
      shift
      ;;
    --E)
      shift
      E_param=$1
      shift
      ;;
    --A)
      e_param="${e_param} -e '\?\?'"
      shift
      ;;
    --M)
      e_param="${e_param} -e '^ M'"
      shift
      ;;
    --C)
      e_param="${e_param} -e '^ M' -e '^ A' -e '^D'"
      shift
      ;;
    --D)
      e_param="${e_param} -e '^D'"
      shift
      ;;
    *)
      log_error invalid param $1
      shift
      ;;
  esac
done
if [[ -z $func || -z $cmd ]];then
  log_error 'invalid command ======>>>' $func $cmd
else
  log_info 'run: ' $func $cmd "grep_filter -e ${e_param} -E ${E_param} -v ${v_param} -ee ${ee_param}" 
  $func $cmd "grep_filter -e \"${e_param}\" -E \"${E_param}\" -v \"${v_param}\" -ee \"${ee_param}\"" 
fi

#  for str in `git status -s | grep -E "\.cpp$|\.c$|\.cc$|\.h$|\.java$"`
#  do
#    file="${cur_dir}/${str}"
#    if [ -f $file ];then
#      sed -i "" 's/[ ]*$//g' $file
#      echo $file
#    fi
#  done
