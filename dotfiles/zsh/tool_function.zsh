. ~/bin/tool_function.sh
function git_file_traverse() {
  local filter=$1
  local -A filter_str_table=('M' 1 'MM' 1 '??' 1 'A' 1 'D' 1)
  local cmd_str='git status -s'
  [[ ! -z $filter ]] && cmd_str+=" | ${filter}"
  log_info "cmd_str: ${cmd_str}"
  for ele  ($(eval $cmd_str)) {
    (($+filter_str_table[$ele])) && continue
    echo $ele
  }
}

function git_file_filter() {
  local e_param=''
  while {getopts nmad arg} {
    case $arg {
      (n)
        e_param+=" -e '^??'"
        ;;
      (m)
        e_param+=" -e '^ M' -e '^MM'"
        ;;
      (a)
        e_param+=" -e '^ A'"
        ;;
      (d)
        e_param+=" -e '^ D'"
        ;;
      (?)
        log_abort "error param ${arg}"
    }
  }
  [ ! -z $e_param ] && e_param='grep '$e_param
  echo $e_param
}

function is_param() {
  local param=$1
  local opt=(${=2})
  local param_arr=()
  ((($#param < 2)) || [[ $param[1] != '-' ]]) && return  1
  for i ({2..$#param}) {
    local ele=$param[i]
    if ((! $opt[(I)$ele])) {
      return 1
    }
  }
  return 0
}

function is_git_param() {
  return $(is_param $1 'n m a d')
}

function is_dir_param() {
  return $(is_param $1 'd')
}

function is_special_opt() {
  (is_git_param $1 || is_dir_param $1) && return 0
  return 1
}

