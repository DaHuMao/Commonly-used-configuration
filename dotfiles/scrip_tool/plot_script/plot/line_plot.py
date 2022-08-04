import base_plot
import matplotlib.pyplot as plt
import plot_tools as plt_tool

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

class LinePlot(base_plot.BasePlot):
    _point_size = 1
    _x_show_range = [0, -1]

    def config_plt(self, data_y_dim):
        self.base_config_plt(data_y_dim)
        if self._x_show_range[1] > self._x_show_range[0]:
            if len(self._xlabel) > 0:
                data_y_dim = self._x_show_range[1] - self._x_show_range[0]
                xlabel = GenarateXLabel(self._x_show_range[0], self._x_show_range[1], len(self._xlabel) - 1)
                dot = max(1, data_y_dim / (len(xlabel) - 1))
                x2 = range(self._x_show_range[0], self._x_show_range[1] + dot, dot)
                plt_tools.log_info(x2, xlabel, data_y_dim, dot)
                plt.xticks(x2, xlabel)
            plt.xlim(self._x_show_range)

    def plot(self, data_x, data_y, x_pos, y_pos, index):
        if len(data_y) == 0:
            raise Exception('invalid data_len: %d' % len(data_y))
        if self._point_size > 1:
            for i in range(len(data_y)):
                data_y[i] = compress_data(self.data_y[i], self._point_size)
            data_x = compress_data(self.data_x, self._point_size)
        if self.check_data(data_x, data_y) is False:
            raise Exception("invalid dim(data_x) dim(data_y)")
        plt.subplot(x_pos, y_pos, index)
        self.config_plt(len(data_y[0]))
        for i in range(len(data_y)):
            if i < len(self._legend_name) and len(self._legend_name[i]) > 0:
                plt.plot(data_x, data_y[i], label=self._legend_name[i], color=base_plot.color_dict[i])
            else:
                plt.plot(data_x, data_y[i], color=base_plot.color_dict[i])

    
