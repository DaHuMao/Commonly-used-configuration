import sys 

import plot_tools as plt_tool 
import read_file
import socket_reader
import plot
import single_line_parser
import multi_line_parser

class PlotEngine:
    _reader = read_file.TxTFileReader()
    _text_processor = plt_tool.TextProcessor()
    _plot_data = plot.PlotData()
    _config_dict = {
                'work_mode': '', \
                'select_y_raw': [], \
                'select_x_raw': [], \
                'select_y_key': [], \
                'select_y_key_multi_line': []
                }

    def update_config(self, key, value):
        if key not in self._config_dict:
            return False
        if isinstance(self._config_dict[key], str) is True:
            self._config_dict[key] = value
        else:
            self._config_dict[key] = value.strip().split()
        return True 

    def init_reader(self):
        select_y_index = []
        for ele in self.get_select_y():
            for ee in ele.split(','):
                select_y_index.append(ee)
        line_parser_x = None
        line_parser_y = None
        if len(self._config_dict['select_y_key_multi_line']) != 0:
            line_parser_y = multi_line_parser.MultiLineParser(select_y_index)
        else:
            line_parser_x = single_line_parser.SingleLineParser(self._config_dict['select_x_raw'])
            line_parser_y = single_line_parser.SingleLineParser(select_y_index)
        self._reader.init(self._text_processor, line_parser_x, line_parser_y)


    def init_plot(self):
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
    
    def init_self(self, argv):
        for ele in argv:
            flag = ele.split('=')
            if len(flag) == 2:
                self.update_config(flag[0], flag[1])
        if len(self._config_dict['select_y_key_multi_line']) != 0:
            self._config_dict['select_y_key'] = self._config_dict['select_y_key_multi_line']
        work_mode = self._config_dict['work_mode']
        if work_mode == 'file_mode':
            self._reader = read_file.TxTFileReader()
        elif work_mode == 'stream_mode':
            self._reader = socket_reader.SocketReader() 
        else:
            Exception('unknow work_mode: %s' % work_mode)
    
    def update_config_memebers(self, argv):
        members = [self._reader, self._text_processor, self._plot_data]
        for i in range(1, len(argv)):
            plt_tool.log_info(argv[i])
            flag = argv[i].split('=')
            if len(flag) == 2 :
                for ele in members:
                    ele.update_config(flag[0], flag[1])

    def init(self, argv):
        self.init_self(argv)
        self.update_config_memebers(argv)
        self.init_reader()
        self.init_plot()
    
    def get_select_y(self):
        if len(self._config_dict['select_y_key']) == 0:
            return self._config_dict['select_y_raw']
        else:
            return self._config_dict['select_y_key']

    def get_data(self):
        select_y = self.get_select_y()
        select_data_x, select_data_y = self._reader.load_data()
        #if len(select_data_y) == 0:
        #    raise Exception('invalid select_data len: 0')
        return plt_tool.get_data(select_data_x, select_data_y, select_y)


    def plot(self):
        work_mode = self._config_dict['work_mode']
        if work_mode == 'file_mode':
            x_data, y_data = self.get_data()
            self._plot_data.show_plot(x_data, y_data)
        else:
            self._reader.start_server()
            while True:
                x_data, y_data = self.get_data()
                self._plot_data.pause_plot(x_data, y_data, 0.1)

plot_engine = PlotEngine()
plot_engine.init(sys.argv)
plot_engine.plot()
