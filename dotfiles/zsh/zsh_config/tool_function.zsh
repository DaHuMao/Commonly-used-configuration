zmodload zsh/datetime
# 定义获取当前时间毫秒的函数
get_current_millisecond() {
  local epoch_realtime=$EPOCHREALTIME
  local seconds=${epoch_realtime%.*}
  local nanoseconds=${epoch_realtime#*.}
  local milliseconds=$((10#${nanoseconds:0:3}))
  printf "%d%03d\n" "$seconds" "$milliseconds"
}

get_time_strftime() {
  echo $(strftime "$1" $EPOCHSECONDS)
}

TestCmdTimeConsuming() {
  local cmd=$1
  local time_tmp1=$(get_current_millisecond)
  eval $cmd
  local res=$?
  local time_tmp2=$(get_current_millisecond)
  local time_gap=$((time_tmp2 - time_tmp1))
  log_info "${cmd}, it takes ${time_gap} ms"
  return $res
}

function SourceSh() {
  TestCmdTimeConsuming "source ${1}"
  return $?
}

TestCmdTimeConsumingNCount() {
  local cmd=$1
  local count=$2
  local time_tmp1=$(get_current_millisecond)
  local i=0
  for (( ; i<$count; i++ )); do
    eval $cmd > /dev/null 2>&1
  done
  local res=$?
  local time_tmp2=$(get_current_millisecond)
  local time_gap=$((time_tmp2 - time_tmp1))
  log_info "${cmd}, it takes ${time_gap} ms"
  return $res
}



