#!/bin/bash
file=""
tarpath="./"
if [ $# -gt 0 ];then
    file=$1
    echo "The file with decompression is: $file"
fi

if [ "$file" == "" ];then
    echo "ERROR: You need to enter a file that needs to be decompressed"
    exit 1
fi

if [ $# -gt 1 ];then
    tarpath=$2
    echo "You chose the decompression path: $2"
else
    echo "You did not choose the pressure path, the default path is: ./"
fi

if [[ "$file" == *.tar.gz ]] || [[ "$file" == *.tgz ]];then
    echo "The type of unzipped file is: .tar.gz or .tgz"
    tar -xzf $file -C $tarpath
    exit $?
fi

if [[ "$file" == *tar ]];then
    echo "The type of unzipped file is: .tar"
    tar -xvf $file -C $tarpath
    exit $?
fi

if [[ "$file" == *.gz ]];then
    echo "The type of unzipped file is: .gz"
    tar -xvf $file -C $tarpath
    exit $?
fi


if [[ "$file" == *.tar.bz2 ]];then
    echo "The type of unzipped file is: .tar.bz2"
    tar -xjf $file -C $tarpath
    exit $?
fi


if [[ "$file" == *.bz2 ]];then
    echo "The type of unzipped file is: .bz2"
    if [[ "$tarpath" != "./" ]];then
        echo "bzip does not support specified directories"
    fi
    bzip2 -d  $file  
    exit $?
fi


if [[ "$file" == *.zip ]];then
    echo "The type of unzipped file is: .zip"
    unzip  $file -d $tarpath
    exit $?
fi


if [[ "$file" == *.rar ]];then
    echo "The type of unzipped file is: .rar"
    unrar e -xvf $file $tarpath
    exit $?
fi

echo "ERROR: There is no decompression type that matches the type you need: ${file#*.}"



