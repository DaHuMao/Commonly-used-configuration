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
import plot_tools as plt_tool
import copy

color_dict = ['blue', 'red', 'orange', 'yellow', 'green', 'black']

def compress_data(ori_arr,compress_times):
    arr_size=int(len(ori_arr)/compress_times)
    plt_tools.log_info(arr_size)
    arr=[]
    for j in range(0,arr_size):
        sumsum=0.00
        for k in range(0,compress_times):
            sumsum+=ori_arr[j*compress_times+k]
        arr.append(sumsum/compress_times)
    return arr

def GenarateXLabel(min_label, max_label, count):
    gap = (int)((max_label - min_label + count - 1) / count);
    label=[]
    while(min_label <= max_label):
        label.append(str(min_label))
        min_label += gap
    return label

class myplot:
    _xlabel = []
    _ylabel = []
    _legend_name = []
    _title = ''
    _point_size = 1
    _y_filter_range = [0, -1]
    _y_show_range = [0, -1]
    _x_show_range = [0, -1]
    _xtitle = ''
    _ytitle = ''
    _title = ''
    _show_xlabel = False

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
   
    def set_ytitle(self, ytitle):
        self._ytitle = ytitle

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
        self._y_filter_range = [lo, hi]

    def set_y_show_range(self, lo, hi):
        self._y_show_range = [lo, hi]

    def set_x_show_range(self, lo, hi):
        self._x_show_range = [lo, hi]
   
    def set_legend_name(self, legend_name):
        self._legend_name = legend_name
    
    def set_data(self, data_x, data_y):
        if check_data(data_x, data_y) == False:
            raise Exception("invalid data_x data_y")

    def show_xlabel(self):
        self._show_xlabel = True

    def config_plt(self, data_y_dim):
        if self._show_xlabel is False:
            plt.xticks([])
        elif len(self._xlabel) > 0:
            dot = max(1, data_y_dim / (len(self._xlabel)-1))
            x2 = list(range(0, data_y_dim, int(dot)))
            if (len(x2) < len(self._xlabel)):
                x2.append(data_y_dim)
            if len(x2) < len(self._xlabel):
                self._xlabel = self._xlabel[0 : len(x2)]
            if len(x2) > len(self._xlabel):
                x2 = x2[0 : len(self._xlabel)]
            plt.xticks(x2, self._xlabel)
        if len(self._xtitle) > 0:
            plt.xlabel(self._xtitle)
        if len(self._ytitle) > 0:
            plt.ylabel(self._ytitle)
        if self._y_show_range[1] > self._y_show_range[0]:
            plt.ylim(self._y_show_range)
        if self._x_show_range[1] > self._x_show_range[0]:
            if len(self._xlabel) > 0:
                data_y_dim = self._x_show_range[1] - self._x_show_range[0]
                xlabel = GenarateXLabel(self._x_show_range[0], self._x_show_range[1], len(self._xlabel) - 1)
                dot = max(1, data_y_dim / (len(xlabel) - 1))
                x2 = range(self._x_show_range[0], self._x_show_range[1] + dot, dot)
                plt_tools.log_info(x2, xlabel, data_y_dim, dot)
                plt.xticks(x2, xlabel)
            plt.xlim(self._x_show_range)
        if len(self._title) > 0:
            plt.title(self._title)
        ax = plt.gca()
        ax.spines['right'].set_color('none') # 右边框设置成无颜色
        ax.spines['top'].set_color('none') # 上边框设置成无颜色
        ax.xaxis.set_ticks_position('bottom') # x轴用下边框代替，默认是这样
        ax.yaxis.set_ticks_position('left') # y轴用左边的边框代替，默认是这样
        #ax.spines['bottom'].set_position(('data',0)) # x轴在y轴，０的位置
        #ax.spines['left'].set_position(('data',0)) # y轴在x轴，０的位置



    def plot(self, data_x, data_y, x_pos, y_pos, index):
        if len(data_y) == 0:
            raise Exception('invalid data_len: %d' % len(data_y))
        if self._point_size > 1:
            for i in range(len(data_y)):
                data_y[i] = compress_data(self.data_y[i], self._point_size)
            data_x = compress_data(self.data_x, self._point_size)
        if self.check_data(data_x, data_y):
            raise Exception("dim(data_x) != dim(data_y), "\
                    "dim(data_x): %d dim(data_y): %d" % (len(data_x), len(data_y)))
        plt.subplot(x_pos, y_pos, index)
        self.config_plt(len(data_y[0]))
        for i in range(len(data_y)):
            if i < len(self._legend_name) and len(self._legend_name[i]) > 0:
                plt.plot(data_x, data_y[i], label=self._legend_name[i], color=color_dict[i])
            else:
                plt.plot(data_x, data_y[i], color=color_dict[i])

class PlotData:
    _config_dict = { \
                    'xlabel':[], \
                    'select_y_raw':[], \
                    'title':[], \
                    'point_size':[], \
                    'xtitle':[], \
                    'ytitle':[], \
                    'y_show_range':[], \
                    'x_show_range':[], \
                    'legend_name':[], \
                    'xlabel_range':[], \
                    'show_xlabel':[], \
                    'y_filter_range':[], \
                    'is_raw_arrange':'1', \
                    'plot_arrange_way':[]
                } 
    _plot_list = []
    _is_raw_arrange='1'
    _plot_arrange_way=[]


    def update_config(self, key, value):
        if key in self._config_dict:
            self._config_dict[key] = value.strip().split()
            return True
        else:
            return False

    def init_plot(self, count_plot):
        title = self._config_dict['title']
        xlabel = self._config_dict['xlabel']
        point_size = self._config_dict['point_size']
        xtitle = self._config_dict['xtitle']
        ytitle = self._config_dict['ytitle']
        y_filter_range = self._config_dict['y_filter_range']
        y_show_range = self._config_dict['y_show_range']
        legend_name = self._config_dict['legend_name']
        xlabel_range = self._config_dict['xlabel_range']
        show_xlabel = self._config_dict['show_xlabel']
        x_show_range = self._config_dict['x_show_range']
        if len(self._config_dict['is_raw_arrange']) > 0:
            self._is_raw_arrange = self._config_dict['is_raw_arrange'][0]
        try:
            self._plot_arrange_way = [int(x) for x in self._config_dict['plot_arrange_way']]
        except:
            plt_tool.log_error("invalid config plot_arrange_way: %s" \
                    % str(self._config_dict['plot_arrange_way']))
        self._plot_list = [myplot() for _ in range(count_plot)]
        plot_list = self._plot_list
        for i in range(1, count_plot):
            plot_list[i]=copy.deepcopy(plot_list[0])
        if len(xlabel) == 1:
            plot_list[count_plot - 1].set_xlabel(xlabel[0].split(','))
        for i in range(0,count_plot):
            if (i < len(show_xlabel) and show_xlabel[i] == '1') or i == count_plot - 1:
                plot_list[i].show_xlabel()
            if i < len(title) and title[i] != 'null':
                plot_list[i].set_title(title[i])
            if len(point_size) > 0:
                plot_list[i].set_point_size(int(point_size[0]))
            if len(xtitle) > 0 and i == count_plot - 1:
                plot_list[i].set_xtitle(xtitle[0])
            if len(ytitle) > i and ytitle[i] != 'null':
                plot_list[i].set_ytitle(ytitle[i])
            if len(xlabel) > 1 and i < len(xlabel) and xlabel[i] != 'null':
                plot_list[i].set_xlabel(xlabel[i].split(','))
            if len(xlabel_range) > 0:
                tmp = xlabel_range[0].split(',')
                if len(tmp) == 3:
                    plot_list[i].set_xlabel_range(int(tmp[0]), int(tmp[1]), int(tmp[2]))
            if len(x_show_range) > 0:
                tmp = x_show_range[0].split(',')
                if len(tmp) == 2:
                    plot_list[i].set_x_show_range(int(tmp[0]), int(tmp[1]))
            if i < len(legend_name) and legend_name[i] != 'null':
                plot_list[i].set_legend_name(legend_name[i].split(','))
            if i < len(y_filter_range) and y_filter_range[i] != 'null':
                str_range = y_filter_range[i].split(',')
                if len(str_range) == 2:
                    plot_list[i].set_y_filter_range(int(str_range[0]),int(str_range[1]))
            if i < len(y_show_range) and y_show_range[i] != 'null':
                str_range = y_show_range[i].split(',')
                if len(str_range) == 2:
                    plot_list[i].set_y_show_range(int(str_range[0]),int(str_range[1]))
    
    def get_plot_pos(self, index):
        plot_list_len = len(self._plot_list)
        if sum(self._plot_arrange_way) < plot_list_len:
            if self._is_raw_arrange == '1':
                return [plot_list_len, 1, index]
            else:
                return [1, plot_list_len, index]
        cur_sum, x, y = 0, 0, 0
        plot_arrange_len = len(self._plot_arrange_way)
        for i in range(0, plot_arrange_len):
            i_num = self._plot_arrange_way[i]
            if index <= cur_sum + i_num:
                x = i + 1
                y = index - cur_sum
                break
            cur_sum += i_num
        if self._is_raw_arrange == '1':
            return [plot_arrange_len, i_num, (x - 1) * i_num + y]
        else:
            return [i_num, plot_arrange_len, (y - 1) * plot_arrange_len + x]


    def plotplot(self, data_x, data_y):
        plot_list_len = len(self._plot_list)
        if plot_list_len != len(data_x) or plot_list_len != len(data_y):
            raise Exception("dim(plot_list):%d != dim(data_x or data_y):%d,%d" % \
                    (plot_list_len, len(data_x), len(data_y)))
        for i in range(0, plot_list_len):
            plot_pos = self.get_plot_pos(i + 1)
            plt_tool.log_info("index:%d, pos is :%s" % (i + 1, str(plot_pos)))
            self._plot_list[i].plot(data_x[i], data_y[i], plot_pos[0], plot_pos[1], plot_pos[2])
            plt.legend(loc='upper right')
   
    def show_plot(self, data_x, data_y):
        self.plotplot(data_x, data_y)
        plt.show()

    def pause_plot(self, data_x, data_y, pause_second):
        plt.clf()
        self.plotplot(data_x, data_y)
        plt.pause(pause_second)






















