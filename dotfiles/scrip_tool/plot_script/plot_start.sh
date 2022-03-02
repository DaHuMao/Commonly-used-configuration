#!/bin/bash

#=======================工作模式==================================
#工作模式有两种，一种是从文件读取数据，一次画一个静态图，一种是从流中动态读取数据，实时画
#file_mode  or stream_mode
work_mode='stream_mode'

#####  file_mode
file_path=''
#文件中，尤其是日志文件可能不是所有数据都是我们要的，这个就是选取固定范围的行数
#-1 表示不限制
#x_select_range='-1 3000'表示只解析3000行以前的数据
#x_select_range='1000 -1'表示只解析1000行以后的数据
#x_select_range='1000 3000'表示只解析1000-3000行的数据
x_select_range=''
#####  file_mode


#####  stream_mode
#ip='127.0.0.1'
ip='0.0.0.0'
port='9600'
#流式读取数据时存储的数据长度，单位为点个数
#注：存储多少并不代表显示多少，存储只是代表存储的数据跨度
#    真正显示是由后面的图配置中的x_show_range决定的
data_storage_len='1000'
#####  stream_mode

#=======================工作模式==================================

#=======================选择X轴Y轴的数据==================================
#这个选项是用来筛选Y轴关键词的数据，在日志场景会很有用:
#比如文本为： [INFO] audio_delay:30,video_delay:40 x_tt 50
#select_y_key='audio_delay video_delay',表示提取关键字为audio_delay, video_delay的数据，分别打印两张图
#如果要放在一张图：select_y_key='audio_delay,video_delay' 用逗号链接即可.
#后面所有选项都是如此，用空格分隔代表不在一张图上，用逗号分隔代表在一张图上
#NOTE: 这种模式会覆盖selete_y_raw
select_y_key='current_buffer_size seq'

#与上面不同的是，上面的选项只针对一行数据，必须有全部的key,也就是说如果某一行数据没有全部的key会报错
#这个更加通用，是在所有数据里查找，也就是不限制行，但是不同行不能有重复key，否则会覆盖。
#比如文本为：[INFO] audio_delay:30  [INFO] video_delay:50 这两个key分别在不同行，
#按照上面的方法是没办法是没办法提取的， 必须使用下面这个关键字
#NOTE1: 上面的模式效率更高.
#NOTE2: 这种模式优先级最高，会覆盖其他模式。如果想要其不生效直接置空即可：select_y_key_multi_line=''
select_y_key_multi_line=''

#这个也是用来筛选Y轴数据，但是却是用列来选取，比如当前有一行文本为： 【INFO】audio_delay:30 video_delay:40
#按空格跟冒号切割变成（后面会说到）：【INFO】audio_delay 30 video_delay 40, 那么第2列跟第四列就是我们要的数字
#我们可以设置select_y_raw='2 4'  如果要让两个数据在同一张图： select_y_raw='2,4'
#NOTE: 这种模式只会在上面两种模式都为空的情况下才会生效，优先级最低
select_y_raw=''

#这个跟select_y_raw是差不多的，不过这个是用来设置X轴的数据
#注：这个选项不填，会自动生成
select_x_raw=''


#当数据太多需要做平滑的时候，可能会把好几个点合并成一个点
#point_size='3' 表示三个点才取一个值，这个值等于三个值的平均
point_size=''
#=======================选择X轴Y轴的数据==================================


#=======================数据过滤与筛选==================================
#filter_include_keywords='recv media_info' 表示只有包含'recv media_info'的行才会被解析
filter_include_keywords='NeteqTest'

#filter_exclude_keywords='recv media_info' 表示包含'recv media_info'的行不会被解析
filter_exclude_keywords=''

#filter_include_keywords差不多的功能，只不过这个会以正则表达式的形式去解析
#举个例子 filter_include_keywords=media_info.c,表示包含media_info.c的行，在media_info.c中的点
#在正则表达式里表示任意字母
reg_pattern_include=''

#同上，只不过是不包含
reg_pattern_exclude=''

#这个是切割字符串的关键字。在上面我们我们说到了切割字符串，尤其是在日志文件，如果不切割的话，根本没法解析
#还是这个例子：[INFO] audio_delay:30,video_delay:40 jitter 50
#上面的字符串假设我们关心的是audio_delay video_delay jitter的值，但是由于日志不规范，根本没有固定格式
#所以我们要切割成一个个的字符串然后解析，在这个例子中我们看到分隔符需要多种，空格，冒号，逗号
#可以令 split_pattern_reg='[ :,]+', 这是一个正则表达式，表示按照空格，冒号，逗号分隔，
#加号表示并且连续的空格或者逗号会被直接剪掉
#分割完变成：[INFO] audio_delay 30 video_delay 40 jitter 50   
#针对这个数组我们无论是用selete_y_key  还是selete_y_raw都很好处理
#注： 这个选项如果不填，默认按照空格分割
split_pattern_reg='[ :,]+'
#=======================数据过滤与筛选==================================


#=======================图配置==================================
#注： 所有配置都是可选的，可以不填
#图的名字，以及图例（一幅图上有多个线，需要图例）
#这个格式是跟select_y_raw一一对应的
#比如 select_y_raw='1 2,3' 这表示画两张图，一张Y轴是第一列，另一张Y轴有两列（也就是两条线）
#此时可以设置title='RTT audio_delay/video_delay',因为是两张图，所以两个标题
#此时图例：legend_name='RTT audio_delay,video_delay' 第二个图有两个图例，所以有两个值用逗号分开
#注: 在 select_y_key模式下，这两个选项不生效，因为在select_y_key模式下title legend_name自动等于select_y_key
title=''
legend_name=''

#设置X轴跟Y轴的单位。比如xtile='time(ms)' ytitle='百分比%'
xtitle=''
ytitle=''

#设置显示的Y轴跟X轴的范围，
#有时候Y轴有些异常大的点，导致看不清图的细节，这时候需要设置Y轴范围。
#比如 y_show_range='0,700 null -100,200' 表示第一张图只显示0-700 第二张图不设置， 第三张图设置-100-200（null为不设置）
#有时候X轴太宽，需要只显示一小段，这时候可以设置X轴显示范围
#比如 x_show_range='1000,2000' 表示只显示1000-2000个点
#这个主要为了以后界面化的时候使用，尤其是X轴设置
y_show_range=''
x_show_range=''

#自己设置X的显示label
#用于需要自己定制label的场景，比如时间： xlabel='10:20 10:30 10:40 10:50 11:00 11:10'
#这些label会均匀的分布在X轴上
xlabel=''

#给定数据范围，生成label
#比如 xlabel_range='0,300,5'表示0-300生成5个间隔，会生成【0 60 120 180 240 300】
xlabel_range=''
#=======================图配置==================================


if [ $# -gt 0 ];then
    file_path=$1
fi
echo 'file_path: '$file_path
plotpath=./plot/run_plot.py
python3 $plotpath "file_path=$file_path"  \
                 "work_mode=$work_mode" \
                 "ip=$ip" \
                 "port=$port" \
                 "data_storage_len=$data_storage_len" \
                 "select_y_raw=$select_y_raw"  \
                 "select_y_key=$select_y_key"  \
                 "select_y_key_multi_line=$select_y_key_multi_line"  \
                 "select_x_raw=$select_x_raw" \
                 "x_select_range=$x_select_range" \
                 "point_size=$point_size" \
                 "xtitle=$xtitle" \
                 "xlabel=$xlabel" \
                 "title=$title" \
                 "y_filter_range=$y_filter_range" \
                 "y_show_range=$y_show_range" \
                 "x_show_range=$x_show_range" \
                 "legend_name=$legend_name" \
                 "ytitle=$ytitle"  \
                 "x_need_lable_seq=$x_need_lable_col"\
                 "xlabel_range=$xlabel_range" \
                 "filter_include_keywords=$filter_include_keywords" \
                 "filter_exclude_keywords=$filter_exclude_keywords" \
                 "reg_pattern_include=$reg_pattern_include" \
                 "reg_pattern_exclude=$reg_pattern_exclude" \
                 "split_pattern_reg=$split_pattern_reg" \


#注：第一个参数必须是文件路径,除了文件路径跟Y轴数据 其他参数都是可选.
