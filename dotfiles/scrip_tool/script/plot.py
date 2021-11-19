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
import read_file

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

def GenarateXLabel(min_label, max_label, count):
    gap = (max_label - min_label + count - 1) / count;
    label=[]
    while(min_label <= max_label):
        label.append(str(min_label))
        min_label += gap
    return label

class myplot:
    _data_x = []
    _data_y = []
    _xlabel = []
    _ylabel = []
    _legend_name = []
    _title = ''
    _point_size = 1
    _y_filter_range = []
    _y_show_range = []
    _xtitle = ''
    _title = ''
    _genarate_default_xtick = False

    def init(self):
        self._xlabel = []
        self._ylabel = []
        self._data_name = []
        self._title = ''
        self._point_size = 1
        self._y_show_range = []
        self._xtitle = ''
        self._title = ''
    
    def check_data(self, data_x, data_y):
        if len(data_y) == 0:
            return False
        data_len = len(data_y)
        for i in range(len(data_y)):
            if data_len != data_y[i]:
                return False
        if len(data_x) != len(data_y):
            return False
        return True

    def set_xlabel(self, xlabel):
        self._xlabel = xlabel

    def set_xlabel_range(self, min_label, max_label, label_count):
        if len(self._xlabel) == 0:
            self._xlabel = GenarateXLabel(min_label, max_label, label_count)
    
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
    
    def set_data(self, data_x, data_y):
        if check_data(data_x, data_y) == False:
            raise Exception("invalid data_x data_y")

    def enable_default_xtick(self):
        self._genarate_default_xtick = True

    def config_plt(self):
        if len(self._xlabel) > 0:
            dot = max(1, int(len(self._data_y[0])/(len(self._xlabel)-1)))
            x2=range(0,len(self._data_y[0]), dot)
            plt.xticks(x2, self._xlabel)
        elif self._genarate_default_xtick is False:
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



    def plot(self, x_pos, y_pos, index):
        if self._point_size > 1:
            for i in range(len(data_y)):
                self.data_y[i] = compress_data(self.data_y[i], self._point_size)
                self.data_x = compress_data(self.data_x, self._point_size)
        plt.subplot(x,y,index)
        self.config_plt()
        for i in range(len(self._data)):
            if i < len(self._legend_name) and len(self._legend_name[i]) > 0:
                plt.plot(self._data_x, self._data_y[i], label=self._legend_name[i], color=color_dict[i])
            else:
                plt.plot(self._data_x, self._data_y[i], color=color_dict[i])

class PlotFile:
    _config_dict = { \
                    'xlabel':[], \
                    'x_need_lable_seq':[], \
                    'select_y_raw':[], \
                    'show_y_raw':[], \
                    'select_x_raw':[], \
                    'title':[], \
                    'point_size':[], \
                    'xtitle':[], \
                    'y_show_range':[], \
                    'x_show_range':[], \
                    'legend_name':[], \
                    'xlabel_range':[], \
                    'y_filter_range':[]
                } 
    _plot_list = []
    _data = []

    def load_data(self, file_path):


    def init_plot(self, config_dict):
        _title = config_dict['title']
        _xlabel = config_dict['xlabel']
        _point_size = config_dict['point_size']
        _xtitle = config_dict['xtitle']
        _y_filter_range = config_dict['y_filter_range']
        _y_raw = config_dict['select_y_raw']
        _y_show_range = config_dict['y_show_range']
        _legend_name = config_dict['legend_name']
        _xlabel_range = config_dict['xlabel_range']
        global plot_list
        plot_list = [myplot()]*len(_y_raw)
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
            if len(_xlabel_range) > 0 and i == len(_y_raw) - 1:
                tmp = _xlabel_range[0].split(',')
                if len(tmp) == 3:
                    plot_list[i].set_xlabel_range(int(tmp[0]), int(tmp[1]), int(tmp[2]))
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
    
    
    def plotplot():
        plot_list_len=len(plot_list)
        if plot_list_len < 1:
            print("has no data")
            return
        for i in range(0,plot_list_len):
            plot_list[i].plot(plot_list_len,1,i+1)
            plt.legend()
    
        plt.show()

def read_env():
    num_argv=0
    for ele in sys.argv:
        num_argv=num_argv+1
        print(ele)
        flag=ele.strip().split('=')
        if len(flag) == 2 :
            if flag[0] in config_dict:
                config_dict[flag[0]]=flag[1].split()
    if num_argv < 2:
        print("you should input file path")
    if len(config_dict['select_y_raw']) == 0:
        config_dict['select_y_raw'].append('0');

init_plot()
read_data()
plotplot()























