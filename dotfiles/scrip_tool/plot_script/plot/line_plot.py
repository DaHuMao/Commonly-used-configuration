import base_plot
import matplotlib.pyplot as plt
import log_tool

def compress_data(ori_arr,compress_times):
    arr_size=int(len(ori_arr)/compress_times)
    log_tool.log_info(arr_size)
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
    _show_statistics_info = True
    _grid_show: 0
    _grid_color: 'gray'
    _grid_linestyle: ':'
    _grid_linewidth: 0.5

    def set_xlabel_range(self, min_label, max_label, label_count):
        if len(self._xlabel) == 0:
            self._xlabel = GenarateXLabel(min_label, max_label, label_count)

    def set_x_show_range(self, lo, hi):
        self._x_show_range = [lo, hi]

    def set_grid(self, grid_show, grid_color, grid_linestyle, grid_linewidth):
        self._grid_show = int(grid_show)
        self._grid_color = grid_color
        self._grid_linestyle = grid_linestyle
        self._grid_linewidth = float(grid_linewidth)


    def config_plt(self, data_y_dim):
        self.base_config_plt(data_y_dim)
        if self._x_show_range[1] > self._x_show_range[0]:
            if len(self._xlabel) > 0:
                data_y_dim = self._x_show_range[1] - self._x_show_range[0]
                xlabel = GenarateXLabel(self._x_show_range[0], self._x_show_range[1], len(self._xlabel) - 1)
                dot = max(1, data_y_dim / (len(xlabel) - 1))
                x2 = range(self._x_show_range[0], self._x_show_range[1] + dot, dot)
                log_tool.log_info(x2, xlabel, data_y_dim, dot)
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
        if self._show_statistics_info:
            for i in range(len(data_y)):
                sum , max_value, min_value = 0, 0, 99999999999
                for value in data_y[i]:
                    sum += value
                    max_value = max(max_value, value)
                    min_value = min(min_value, value)
                count = len(data_y[i])
                avg = 0
                if count > 0:
                    avg = sum * 1.0 / count
                legend_name = i
                if len(self._legend_name) > i:
                    legend_name = self._legend_name[i]
                log_tool.log_info("{} count: {} avg: {} max: {} min: {}".format(\
                        legend_name, count, avg, max_value, min_value))
            self._show_statistics_info = False
        plt.subplot(x_pos, y_pos, index)
        self.config_plt(len(data_y[0]))

        if self._grid_show > 0 and self._grid_show < 4:
            axs = plt.gca()
            # 开启次刻度
            axs.minorticks_on()
            if self._grid_show & 1 == 1:
                # X轴只显示主网格线
                axs.xaxis.grid(True, which='both', color=self._grid_color, \
                        linestyle=self._grid_linestyle, linewidth=self._grid_linewidth)
            if self._grid_show & 2 == 2:
                # Y轴显示全部网格线（主、次网格线）
                axs.yaxis.grid(True, which='both', color=self._grid_color, \
                        linestyle=self._grid_linestyle, linewidth=self._grid_linewidth)

        for i in range(len(data_y)):
            if i < len(self._legend_name) and len(self._legend_name[i]) > 0:
                plt.plot(data_x, data_y[i], label=self._legend_name[i], color=base_plot.color_dict[i])
            else:
                plt.plot(data_x, data_y[i], color=base_plot.color_dict[i], label='none')


