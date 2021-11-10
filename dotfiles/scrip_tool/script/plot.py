# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
#import numpy as np
#import matplotlib.pyplot as plt
#cc= np.linspace(0,2,500)
#plt.rcParams['font.sans-serif'] = ['SimHei']
#plt.plot(cc,cc,label='linear')
#plt.plot(cc,cc*2,label='两倍')
#plt.plot(cc,cc**3,label='三倍')
#plt.xlabel('x label')
#plt.ylabel('y label')
#plt.title("折线图")
#plt.legend()
#plt.show()
#cc = np.linspace(0,2,100)
#plt.plot(cc,cc,label ='linear')
#plt.plot(cc,cc ** 2,label ='quadratic')
#plt.plot(cc,cc ** 3,label ='cubic')
#plt.xlabel('x label')
#plt.ylabel('y label')
import matplotlib.pyplot as plt
import sys 
import copy

color_dict = ['blue', 'red', 'orange', 'yellow', 'green', 'black']

def compress_data(ori_arr,compress_times):
    arr_size=int(len(ori_arr)/compress_times)
    print(arr_size)
    arr=[]
    for j in range(0,arr_size):
        sumsum=0.00
        for k in range(0,compress_times):
            sumsum+=ori_arr[j*compress_times+k]
        arr.append(sumsum/compress_times)
    return arr
class myplot:
    _sum = 0
    _max_num = 0
    _min_num = 0
    _data = []
    _x_index = []
    _xlabel = []
    _ylabel = []
    _legend_name = []
    _title = ''
    _point_size = 1
    _y_filter_range = []
    _y_show_range = []
    _xtitle = ''
    _title = ''
    genarate_default_xtick = False

    def init(self):
        self._sum=0
        self._max_num=-11111111111111111
        self._min_num=111111111111111111
        self._data = []
        self._x_index = []
        self._xlabel = []
        self._ylabel = []
        self._data_name = []
        self._title = ''
        self._point_size = 1
        self._y_filter_range = [self._max_num, self._min_num]
        self._y_show_range = []
        self._xtitle = ''
        self._title = ''
    
    def set_xlabel(self, xlabel):
        self._xlabel = xlabel
    
    def set_xtitle(self, xtitle):
        self._xtitle = xtitle
   
    def set_ylable(self, ylabel):
        self._ylabel = ylabel

    def set_y_title(self, ytitle):
        self._ytitle = ytitle

    def set_title(self, title):
        self._title = title

    def set_point_size(self, point_size):
         self._point_size = point_size
    
    def set_xlabel(self, xlabel):
        self._xlabel = xlabel

    def set_y_filter_range(self, lo, hi):
        self._y_filter_range[0] = lo
        self._y_filter_range[1] = hi

    def set_y_show_range(self, lo, hi):
        self._y_show_range.append(lo)
        self._y_show_range.append(hi)
   
    def set_legend_name(self, legend_name):
        self._legend_name = legend_name

    def enable_default_xtick(self):
        self.genarate_default_xtick = True

    def insert_x_y_data(self, x, element):
        if self.insert_y_data(element):
            self._x_index.append(x)

    def insert_y_data(self, element):
        if len(self._data) == 0:
            while len(self._data) < len(element):
                self._data.append([])
        if len(self._data) != len(element):
            raise Exception("insert_y_data exception: \
                    element len: %d self.data len %d" % (len(element), len(self._data)))
        for i in range(len(element)):
            if element[i] < self._y_filter_range[0] or element[i] > self._y_filter_range[1]:
                return False
        for i in range(len(element)):
            ele = element[i]
            self._data[i].append(ele)
            self._sum=self._sum+ele
            self._max_num=max(self._max_num, ele)
            self._min_num=min(self._min_num, ele)
        return True


    def config_plt(self):
        if len(self._xlabel) > 0:
            dot = max(1, int(len(self._data[0])/(len(self._xlabel)-1)))
            x2=range(0,len(self._data[0]), dot)
            plt.xticks(x2, self._xlabel)
        elif self.genarate_default_xtick is False:
            plt.xticks([])
        if len(self._xtitle) > 0:
            plt.xlabel(self._xtitle)
        if len(self._y_show_range) == 2:
            plt.ylim(self._y_show_range)
        if len(self._title) > 0:
            plt.title(self._title)
        ax = plt.gca()
        ax.spines['right'].set_color('none') # 右边框设置成无颜色
        ax.spines['top'].set_color('none') # 上边框设置成无颜色
        ax.xaxis.set_ticks_position('bottom') # x轴用下边框代替，默认是这样
        ax.yaxis.set_ticks_position('left') # y轴用左边的边框代替，默认是这样
        #ax.spines['bottom'].set_position(('data',0)) # x轴在y轴，０的位置
        #ax.spines['left'].set_position(('data',0)) # y轴在x轴，０的位置

    def plot(self, x, y, index):
        #self._name='mean: '+str(round(self._sum/len(self._data),2))+'\n' \
        #           +'max: '+str(self._max_num)+'\n' \
        #           +'min: '+str(self._min_num)
        if self._point_size > 1:
            self._data=compress_data(self._data,self._point_size)
            self._x_index = compress_data(self._x_index, self._point_size);
        if len(self._x_index) != len(self._data[0]):
            self._x_index=range(0,len(self._data[0]))
        plt.subplot(x,y,index)
        self.config_plt()
        print("=====: ", len(self._data[0]), len(self._x_index))
        for i in range(len(self._data)):
            if i < len(self._legend_name) and len(self._legend_name[i]) > 0:
                plt.plot(self._x_index, self._data[i], label=self._legend_name[i], color=color_dict[i])
            else:
                plt.plot(self._x_index, self._data[i], color=color_dict[i])


data_dict={'xlabel':[], \
           'x_need_lable_seq':[], \
           'select_y_raw':[], \
           'select_x_raw':[], \
           'title':[], \
           'point_size':[], \
           'xtitle':[], \
           'y_show_range':[], \
           'legend_name':[], \
           'y_filter_range':[]} \
#plot_list=[]


def init_plot():
    num_argv=0
    for ele in sys.argv:
        num_argv=num_argv+1
        print(ele)
        flag=ele.strip().split('=')
        if len(flag) == 2 :
            if flag[0] in data_dict:
                data_dict[flag[0]]=flag[1].split()
    if num_argv < 2:
        print("you should input file path")
    if len(data_dict['select_y_raw']) == 0:
        data_dict['select_y_raw'].append('0');
    _title = data_dict['title']
    _xlabel = data_dict['xlabel']
    _point_size = data_dict['point_size']
    _xtitle = data_dict['xtitle']
    _y_filter_range = data_dict['y_filter_range']
    _y_raw = data_dict['select_y_raw']
    _x_raw = data_dict['select_x_raw']
    _y_show_range = data_dict['y_show_range']
    _legend_name = data_dict['legend_name']
    global plot_list
    plot_list=[myplot()]*len(_y_raw)
    plot_list[0].init()
    for i in range(1,len(_y_raw)):
        plot_list[i]=copy.deepcopy(plot_list[0])
        plot_list[i].init()
    for i in range(0,len(_y_raw)):
        if i == len(_y_raw) - 1:
            plot_list[i].enable_default_xtick()
        if i < len(_title) and _title[i] != 'null':
            plot_list[i].set_title(_title[i])
        if len(_point_size) > 0:
            plot_list[i].set_point_size(int(_point_size[0]))
        if len(_xtitle) > 0 and i == len(_y_raw) - 1:
            plot_list[i].set_xtitle(_xtitle[0])
        if len(_xlabel) > 0 and i == len(_y_raw) - 1:
            plot_list[i].set_xlabel(_xlabel)
        if i < len(_legend_name) and _legend_name[i] != 'null':
            plot_list[i].set_legend_name(_legend_name[i].split(','))
        if i < len(_y_filter_range) and _y_filter_range[i] != 'null':
            str_range=_y_filter_range[i].split(',')
            if len(str_range) == 2:
                plot_list[i].set_y_filter_range(int(str_range[0]),int(str_range[1]))
        if i < len(_y_show_range) and _y_show_range[i] != 'null':
            str_range=_y_show_range[i].split(',')
            if len(str_range) == 2:
                plot_list[i].set_y_show_range(int(str_range[0]),int(str_range[1]))


def read_data():
    file_path=sys.argv[1]
    f = open(file_path,"r")   #设置文件对象
    y_raw = data_dict['select_y_raw']
    x_raw = data_dict['select_x_raw']
    count=0
    count1=0
    for line in f:
        count1 += 1
        data = line.strip().split()
        for i in range(0,len(y_raw)):
            y_index = y_raw[i].strip().split(',')
            data_num = []
            for ele in y_index:
                if int(ele) >= len(data):
                    raise Exception("select_y_raw[%d]: %s overflow" % (i, y_raw[i]))
                data_num.append(float(data[int(ele)]))
            if len(x_raw) > i and x_raw[i] != 'null':
                plot_list[i].insert_x_y_data(int(data[int(x_raw[i])]), data_num)
            else:
                count += 1
                plot_list[i].insert_y_data(data_num)
    print("-----------: ", count, " ", count1)

def plotplot():
    plot_list_len=len(plot_list)
    if plot_list_len < 1:
        print("has no data")
        return
    for i in range(0,plot_list_len):
        plot_list[i].plot(plot_list_len,1,i+1)
        plt.legend()

    plt.show()

init_plot()
read_data()
plotplot()























