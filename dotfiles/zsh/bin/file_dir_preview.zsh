file_or_dir=$1/$2
echo $file_or_dir

check_file_type_and_size() {
  # Check if file is a text file
  is_text=$(file "$1" | grep 'text')

  # Get file size in bytes
  file_size=$(stat -f%z "$1")

  # If file is not a text file
  if [[ -z $is_text ]]; then
    # And file size is larger than 1MB (1048576 bytes)
    if (( file_size > 1048576 )); then
      echo 0
    fi
  fi
  echo 1
}

if [ -f $file_or_dir ];then
  echo $FZF_FILE_HIGHLIGHTER $file_or_dir
  is_text=$(check_file_type_and_size $file_or_dir)
  if [[ $is_text='0' ]];then
    more -f $file_or_dir
  else
    $FZF_FILE_HIGHLIGHTER $file_or_dir
  fi
elif [ -d $file_or_dir ];then
  tree $file_or_dir
fi
