import text_processor
import read_file
import plot
import sys 
import time

def GetNowTimeMs():
    t = time.time()
    return int(round(t * 1000))

class PlotEngine:
    _reader = read_file.TxTFileReader()
    _text_processor = text_processor.TextProcessor()
    _plot_data = plot.PlotData()
    _config_dict = {
                'select_y_raw': [], \
                'select_x_raw': [], \
                'select_y_key': []
                }

    def init(self, argv):
        file_path = ''
        if len(argv) > 2:
            file_path = argv[1]
        for i in range(2, len(argv)):
            print(argv[i])
            flag = argv[i].split('=')
            if len(flag) == 2 :
                if self._config_dict.has_key(flag[0]):
                    self._config_dict[flag[0]] = flag[1].strip().split()
                elif self._text_processor.update_config(flag[0], flag[1]) is False \
                        and self._plot_data.update_config(flag[0], flag[1]) is False \
                        and self._reader.update_config(flag[0], flag[1]) is False:
                            raise Exception("Unknow Key: %s" % flag[0])
        self._reader.init(file_path, self._text_processor)
        plot_count = len(self._config_dict['select_y_key'])
        if plot_count == 0:
            plot_count = len(self._config_dict['select_y_raw'])
        else:
            select_y_key = ''
            for ee in self._config_dict['select_y_key']:
                if len(select_y_key) > 0:
                    select_y_key = select_y_key + ' ' + ee
                else:
                    select_y_key = ee

            self._plot_data.update_config('title', select_y_key) 
            self._plot_data.update_config('legend_name', select_y_key)

        self._plot_data.init_plot(plot_count)
        

    def get_data(self):
        select_y = []
        select_x_index = self._config_dict['select_x_raw']
        select_y_index = []
        is_index = len(self._config_dict['select_y_key']) == 0
        if is_index is True:
            select_y = self._config_dict['select_y_raw']
        else:
            select_y = self._config_dict['select_y_key']
        for ele in select_y:
            for ee in ele.split(','):
                select_y_index.append(ee)
        select_data_x, select_data_y = self._reader.load_data(\
                select_x_index, select_y_index, is_index)
        if len(select_data_y) == 0:
            raise Exception('invalid select_data len: 0')
        x_data = select_data_x
        x_data_default = range(0, len(select_data_y[0]))
        if len(x_data) > 0:
            x_data_default = x_data[0]
        y_data = []
        start_index = 0
        for i in range(len(select_y)):
            if i >= len(x_data):
                x_data.append(x_data_default)
            end_index = len(select_y[i].split(',')) + start_index
            y_data.append(select_data_y[start_index : end_index])
            start_index = end_index
        return x_data, y_data


    def plot(self):
        start = GetNowTimeMs()
        x_data, y_data = self.get_data()
        print("=========== load_data comsuming time: %d ms, data_dim: %d" % \
                (GetNowTimeMs() - start, len(y_data[0][0])))
        self._plot_data.plotplot(x_data, y_data)

plot_engine = PlotEngine()
plot_engine.init(sys.argv)
plot_engine.plot()
