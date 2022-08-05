import plot_tools 
import matplotlib.pyplot as plt
import base_plot

def add_rect_labels(rects):
    for rect in rects:
        height = rect.get_height()
        plt.text(rect.get_x() + rect.get_width()/2,height,height, ha='center', va='bottom')
        #rect.set_edgecolor('white')

def get_histogram_x(x, y_dim, index, width):
    x_ans = []
    for xx in x:
        base_pos = xx - width / 2;
        start_pos = base_pos + index * width / y_dim
        end_pos = base_pos + (index + 1) * width / y_dim
        x_ans.append((start_pos + end_pos) / 2)
    return x_ans

class HistogramPlot(base_plot.BasePlot):
    _x_classification = []
    _width = 0.9
    def set_x_classification(self, x_classification):
        self._x_classification = []
        self._xlabel = []
        x_classification_arr = x_classification.split(',')
        for ee in x_classification_arr:
            self._x_classification.append([int(val) for val in ee.split('-')])
            tmp = self._x_classification[-1]
            if len(tmp) != 2:
                raise Exception("invalid len(x_classification): %d" % len(tmp))
        self._x_classification.sort()
        print(self._x_classification)
        for ee in self._x_classification:
            self._xlabel.append('[%d-%d]' % (ee[0], ee[1]))

    def set_width(self, width):
        self._width = width

    def config_plt(self, data_y_dim):
        self.base_config_plt(data_y_dim)

    def get_default_data(self, data):
        data_x = []
        data_y = []
        if len(data) == 0:
            return data_x,data_y
        data.sort()
        data_x.append(data[0])
        data_y.append(0)
        for i in range(len(data)):
            if data[i] == data_x[-1]:
                data_y[-1] += 1
            else:
                data_y.append(1)
                data_x.append(data[i])
        return data_x,data_y
       
    def get_classfi_data(self, data, data_y_dim, index):
        data_y = len(self._x_classification) * [0]
        for ee in data:
            for i in range(len(self._x_classification)):
                if ee >= self._x_classification[i][0] and ee < self._x_classification[i][1]:
                    data_y[i] += 1
        return get_histogram_x(range(0, len(data_y)), data_y_dim, index, self._width),data_y

    def get_data(self, data, data_y_dim, index):
        if len(data) == 0:
            plot_tools.log_warn("len(data) is 0");
        data_dim = len(self._x_classification)
        if data_dim == 0 and data_y_dim > 1:
            raise Exception("len(self._x_classification) is 0 but data_y_dim is %d" % data_y_dim)
        if data_dim == 0:
            return self.get_default_data(data)
        else:
            return self.get_classfi_data(data, data_y_dim, index)


    def plot(self, data_x, data_y, x_pos, y_pos, index):
        y_dim = len(data_y)
        if y_dim == 0:
            raise Exception('invalid data_len: %d' % y_dim)
        if self.check_data(data_x, data_y) is False:
            raise Exception("invalid dim(data_x) dim(data_y)")
        plt.subplot(x_pos, y_pos, index)
        self.config_plt(len(self._x_classification))
        for i in range(y_dim):
            bar = None
            x, y = self.get_data(data_y[i], y_dim, i)
            if i < len(self._legend_name) and len(self._legend_name[i]) > 0:
                bar = plt.bar(x, y, width=self._width / y_dim, facecolor=base_plot.color_dict[i], \
                        label=self._legend_name[i])
            else:
                bar = plt.bar(x, y, width=self._width / y_dim, facecolor=base_plot.color_dict[i])
            add_rect_labels(bar)

