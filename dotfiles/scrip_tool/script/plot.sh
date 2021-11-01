#!/bin/bash

file_path='/mnt/hgfs/D/output/hisfAndCpu/cpulog/main_thread_cpu_11-4-22-16.txt'
title='VmSize VmRSS CPU' 
point_size='1'
select_raw='3 4 2'
xtitle='time'
#label='10:00 11:00 12:00 13:00 14:00 15:00 16:00'
#yrange='30000,60000 40000,600000 400000,600000'
if [ $# -gt 0 ];then
    file_path=$1
fi
if [ $# -gt 1 ];then
    title=$2
fi
echo 'file_path: '$file_path
echo 'title: '$title
python plot.py $file_path  \
               "select_raw=$select_raw"  \
               "point_size=$point_size" \
               "xtitle=$xtile" \
               "label=$label" \
               "yrange=$yrange" \
               "title=$title"  


#label X轴标签
#yrange y轴取值范围
#select_raw 取文本文档哪些列数据：ex:select_raw=2 3 4  取2 3 4列的数（0开始）
#point_size 多少个点取一次平均值
#title 图的名字
#xtitle x轴坐标

#注：第一个参数必须是文件路径
