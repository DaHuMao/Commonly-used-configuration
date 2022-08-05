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
import copy
import line_plot
import histogram_plot
import plot_tools as plt_tool



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
                    'plot_arrange_way':[], \
                    'plot_type': None, \
                    'width': '0.9', \
                    'x_classification': []
                } 
    _plot_list = []
    _is_raw_arrange='1'
    _plot_arrange_way=[]
    _is_first = True


    def update_config(self, key, value):
        if key in self._config_dict:
            self._config_dict[key] = value.strip().split()
            return True
        else:
            return False

    def raw_first_array(self):
        count_of_plot = len(self._plot_list)
        if len(self._plot_arrange_way) == 0:
           return [count_of_plot]
        end_index = 0
        tmp_sum = 0
        for ee in self._plot_arrange_way:
            tmp_sum += ee
            if tmp_sum >= count_of_plot:
                break
            end_index += 1
        if end_index > 0 and \
                self._plot_arrange_way[end_index - 1] == self._plot_arrange_way[end_index]:
            return [count_of_plot - i for i in range(self._plot_arrange_way[end_index])]
        else:
            return [tmp_sum - i for i in range(self._plot_arrange_way[end_index])]
            

    def col_first_array(self):
        count_of_plot = len(self._plot_list)
        if len(self._plot_arrange_way) == 0:
            return range(1, count_of_plot + 1)
        ans = []
        tmp_sum = 0
        ans.append(count_of_plot)
        for ee in self._plot_arrange_way:
            tmp_sum += ee
            ans.append(tmp_sum)
        return ans

    def last_raw_index_array(self):
        if self._is_raw_arrange == '1':
            return self.raw_first_array()
        else:
            return self.col_first_array()

    def init_line_plot(self, count_plot):
        x_show_range = self._config_dict['x_show_range']
        point_size = self._config_dict['point_size']
        xlabel_range = self._config_dict['xlabel_range']
        self._plot_list = [line_plot.LinePlot() for _ in range(count_plot)]
        plot_list = self._plot_list
        for i in range(1, count_plot):
            plot_list[i] = copy.deepcopy(plot_list[0])
        for i in range(0,count_plot):
            if len(point_size) > 0:
                plot_list[i].set_point_size(int(point_size[0]))
            if len(x_show_range) > 0:
                tmp = x_show_range[0].split(',')
                if len(tmp) == 2:
                    plot_list[i].set_x_show_range(int(tmp[0]), int(tmp[1]))
            if len(xlabel_range) > 0:
                tmp = xlabel_range[0].split(',')
                if len(tmp) == 3:
                    plot_list[i].set_xlabel_range(int(tmp[0]), int(tmp[1]), int(tmp[2]))
        return
    
    def init_histogram_plot(self, count_plot):
        width = self._config_dict['width']
        x_classification = self._config_dict['x_classification']
        self._plot_list = [histogram_plot.HistogramPlot() for _ in range(count_plot)]
        plot_list = self._plot_list
        for i in range(1, count_plot):
            plot_list[i] = copy.deepcopy(plot_list[0])
        for i in range(0,count_plot):
            if len(width) == 1:
                plot_list[i].set_width(float(width[0]))
            elif i < len(width) and width[i] != 'null':
                plot_list[i].set_width(float(width[i]))
            if len(x_classification) == 1:
                plot_list[i].set_x_classification(x_classification[0])
            elif i < len(x_classification) and x_classification[i] != 'null':
                plot_list[i].set_x_classification(x_classification[i])
        return

    def init_base_plot(self):
        title = self._config_dict['title']
        xlabel = self._config_dict['xlabel']
        xtitle = self._config_dict['xtitle']
        ytitle = self._config_dict['ytitle']
        y_filter_range = self._config_dict['y_filter_range']
        y_show_range = self._config_dict['y_show_range']
        legend_name = self._config_dict['legend_name']
        show_xlabel = self._config_dict['show_xlabel']
        plot_list = self._plot_list
        last_raw_index_array = self.last_raw_index_array()
        print(last_raw_index_array)
        for i in range(len(plot_list)):
            if i + 1 in last_raw_index_array:
                plot_list[i].show_xlabel()
                if len(xlabel) == 1:
                    plot_list[i].set_xlabel(xlabel[0].split(','))
                if (len(xtitle)) == 1:
                    plot_list[i].set_xtitle(xtitle[0])
            if (len(show_xlabel) == 1 and show_xlabel[0] == 'all') or \
                    (i < len(show_xlabel) and show_xlabel[i] == '1'):
                plot_list[i].show_xlabel()
            if i < len(title) and title[i] != 'null':
                plot_list[i].set_title(title[i])
            if len(xtitle) > 1:
                plot_list[i].set_xtitle(xtitle[i])
            if len(ytitle) > i and ytitle[i] != 'null':
                plot_list[i].set_ytitle(ytitle[i])
            if len(xlabel) > 1 and i < len(xlabel) and xlabel[i] != 'null':
                plot_list[i].set_xlabel(xlabel[i].split(','))
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
        return

    def init_plot(self, count_plot):
        self._is_first = True
        plot_type = self._config_dict['plot_type'][0]
        
        if len(self._config_dict['is_raw_arrange']) > 0:
            self._is_raw_arrange = self._config_dict['is_raw_arrange'][0]
        try:
            self._plot_arrange_way = [int(x) for x in self._config_dict['plot_arrange_way']]
        except:
            plt_tool.log_error("invalid config plot_arrange_way: %s" \
                    % str(self._config_dict['plot_arrange_way']))
        if len(self._plot_arrange_way) > 0 and count_plot > sum(self._plot_arrange_way):
            raise Exception( \
                    "count of plot: %d less than sum of plot_arrange_way %d plot_arrange_way is: %s"\
                    % (count_plot, sum(self._plot_arrange_way), self._plot_arrange_way))

        if plot_type == 'line':
            self.init_line_plot(count_plot)
        elif plot_type == 'histogram':
            self.init_histogram_plot(count_plot)
        else:
            raise Exception("unknow plot_type: %s" % plot_type)

        self.init_base_plot()
    
    def get_plot_pos(self, index):
        plot_list_len = len(self._plot_list)
        if sum(self._plot_arrange_way) < plot_list_len:
            if self._is_raw_arrange == '1':
                return [plot_list_len, 1, index]
            else:
                return [1, plot_list_len, index]
        cur_sum, x, y = 0, 0, 0
        plot_arrange_len = len(self._plot_arrange_way)
        i_num = 0
        for i in range(0, plot_arrange_len):
            i_num = self._plot_arrange_way[i]
            if i_num <= 0:
                raise Exception("invalid plot_arrange_way:%s, index of %d less than 1: %d" %\
                        (str(self._plot_arrange_way), i, i_num))
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
            if self._is_first:
                plt_tool.log_info("index:%d, pos is :%s" % (i + 1, str(plot_pos)))
                self._is_first = False
            self._plot_list[i].plot(data_x[i], data_y[i], plot_pos[0], plot_pos[1], plot_pos[2])
            plt.legend(loc='upper right')
   
    def show_plot(self, data_x, data_y):
        self.plotplot(data_x, data_y)
        plt.show()

    def pause_plot(self, data_x, data_y, pause_second):
        plt.clf()
        self.plotplot(data_x, data_y)
        plt.pause(pause_second)






















