#!/bin/bash

file_path='/mnt/hgfs/D/output/hisfAndCpu/cpulog/main_thread_cpu_11-4-22-16.txt'
title='PacketBufferSize/TarGetBuffLevel RTT cur_iat optBufferlevel'
legend_name='PacketBufferSize,TarGetBuffLevel RTT cur_iat optBufferlevel'
title='RTT cur_iat 95_iat/optBufferlevel'
legend_name='RTT cur_iat,95_iat,optBufferlevel'
#title='PacketBufferSize/TarGetBuffLevel RTT,OptBufferLevel'
#legend_name='PacketBufferSize,TarGetBuffLevel RTT,OptBufferLevel'
#title='PacketBufferSize/TarGetBuffLevel RTT packet_gap_ms real_gap_ms cur_iat/cur_95_iat/optBufferlevel'
#legend_name='PacketBufferSize,TarGetBuffLevel RTT packet_gap_ms real_gap_ms cur_iat,cur_95_iat,optBufferlevel'
point_size='1'
select_y_raw='2,3 0 4 5'
select_y_raw='0 1,2,3'
#select_y_raw='1,2 0,4'
#select_y_raw='1,2 0 3 4 5,6,7'
select_x_raw=''
xtitle='time'
#xlabel='0 10 20 30 40 50 60 70 80 90 100 110 120 130 140 150'
#xlabel='0 20 40 60 80 100 120 140 160 180 200 220 240 260 280 300 320 340'
xlabel_range='0,20000,10' # 0~400 打20个label
#x_select_range=''
y_show_range='0,700 0,700 -500,700 0,400 0,700'
#y_filter_range=''
#filter_include_keywords=''
#filter_exclude_keywords=''
#filter_include_reg=''
#filter_exclude_reg=''
#split_symbol=''
if [ $# -gt 0 ];then
    file_path=$1
fi
if [ $# -gt 1 ];then
    title=$2
fi
echo 'file_path: '$file_path
echo 'title: '$title
plotpath=`which plot.py`
python $plotpath $file_path  \
               "select_y_raw=$select_y_raw"  \
               "select_x_raw=$select_x_raw" \
               "point_size=$point_size" \
               "xtitle=$xtitle" \
               "xlabel=$xlabel" \
               "title=$title" \
               "y_filter_range=$y_filter_range" \
               "y_show_range=$y_show_range" \
               "legend_name=$legend_name" \
               "ytitle=$ytitle"  \
               "x_need_lable_seq=$x_need_lable_col"\
               "xlabel_range=$xlabel_range"

#xlabel X轴标签
#x_need_lable_seq 需要标签的图的序号
#y_show_range y轴显示范围 
#y_filter_range 不在这个范围内的数值会被过滤掉
#select_y_raw 取文本文档哪些列数据作为Y坐标：ex:select_raw=2 3 4  取2 3 4列的数（0开始）默认取第一列
#select_x_raw 取文本文档哪些列数据作为X坐标 默认会自动生成
#point_size 多少个点取一次平均值 默认值为1
#title 图的名字
#xtitle x轴名字

#注：第一个参数必须是文件路径,除了文件路径 其他参数都是可选。默认情况下会取文件第一列作为Y坐标，然后根据Y坐标个数，自动生成生成X坐标
