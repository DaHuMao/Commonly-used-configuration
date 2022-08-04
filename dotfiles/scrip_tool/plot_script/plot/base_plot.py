import matplotlib.pyplot as plt

color_dict = ['blue', 'red', 'orange', 'yellow', 'green', 'deeppink']

class BasePlot:
    _xlabel = []
    _ylabel = []
    _legend_name = []
    _title = ''
    _y_filter_range = [0, -1]
    _y_show_range = [0, -1]
    _xtitle = ''
    _ytitle = ''
    _title = ''
    _show_xlabel = False

    def check_data(self, data_x, data_y):
        if len(data_y) == 0:
            return False
        data_len = len(data_x)
        for i in range(len(data_y)):
            if data_len != len(data_y[i]):
                plt_tool.log_error("index of %d: dim(x): %d not eq dim(y): %d" % \
                        (i, data_len,len(data_y[i])))
                return False
        return True

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
    
    def show_xlabel(self):
        self._show_xlabel = True

    def base_config_plt(self, data_y_dim):
        if self._show_xlabel is False:
            plt.xticks([])
        elif len(self._xlabel) > 1:
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
        if len(self._title) > 0:
            plt.title(self._title)
        ax = plt.gca()
        ax.spines['right'].set_color('none') # 右边框设置成无颜色
        ax.spines['top'].set_color('none') # 上边框设置成无颜色
        ax.xaxis.set_ticks_position('bottom') # x轴用下边框代替，默认是这样
        ax.yaxis.set_ticks_position('left') # y轴用左边的边框代替，默认是这样
        #ax.spines['bottom'].set_position(('data',0)) # x轴在y轴，０的位置
        #ax.spines['left'].set_position(('data',0)) # y轴在x轴，０的位置

