file_or_dir=$1/$2
echo $file_or_dir
if [ -f $file_or_dir ];then
  echo $FZF_FILE_HIGHLIGHTER $file_or_dir
  $FZF_FILE_HIGHLIGHTER $file_or_dir
elif [ -d $file_or_dir ];then
  tree $file_or_dir
fi
