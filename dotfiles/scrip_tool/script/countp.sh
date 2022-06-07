function getdir(){
    for element in `ls -a $1`
    do  
        dir_or_file=$1"/"$element
        if [ '.' = $element -o '..' = $element ] ;then
            continue
        fi
        if [ -d $dir_or_file ]
        then 
            cd $dir_or_file
            space=`du -sh`
            echo "$dir_or_file: $space"
            cd ..
        fi  
    done
}
space=`du -sh`
echo ".: $space"
getdir .
