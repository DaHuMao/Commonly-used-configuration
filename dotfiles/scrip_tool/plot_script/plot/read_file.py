import plot_tools as plt_tool

class TxTFileReader:
    _file_path = ''
    _text_processor = None
    _return_data_x = None
    _return_data_y = None
    _config_dict = {
                'file_path':'', \
                'x_select_range':[]
            }
    
    def update_config(self, key, value):
        if  key not in self._config_dict:
            return False
        if isinstance(self._config_dict[key], str):
            self._config_dict[key] = value
        else:
            self._config_dict[key] = value.strip().split() 
        return True

    def init(self, text_processor, select_raw_x, select_raw_y):
        self._text_processor = text_processor
        f = open(self._config_dict['file_path'], "r")
        select_index_y = []
        select_index_x = []
        self._return_data_x = [[] for _ in range(len(select_raw_x))] 
        self._return_data_y = [[] for _ in range(len(select_raw_y))]
        start_line = -1
        end_line = -1
        if len(self._config_dict['x_select_range']) == 2:
            start_line = int(self._config_dict['x_select_range'][0])
            end_line = int(self._config_dict['x_select_range'][1])
            plt_tool.log_info("x_select_range is %d~%d" % (start_line, end_line))

        count = 0
        first = True
        for line in f:
            count += 1
            if start_line > -1 and count < start_line:
                continue
            if end_line > -1 and count > end_line:
                break
            if self._text_processor.is_valid_line(line) == False:
                continue
            data = self._text_processor.split_str_to_data(line)
            if first is True:
                first = False
                select_index_x = plt_tool.key_to_index(select_raw_x, data)
                select_index_y = plt_tool.key_to_index(select_raw_y, data)
            plt_tool.select_data(select_index_x, data, self._return_data_x)
            plt_tool.select_data(select_index_y, data, self._return_data_y)
        if len(return_data_y) > 0:
            plt_tool.log_info("select_data length: %d" % (len(return_data_y[0])))

    def load_data(self):
        return self._return_data_x, self._return_data_y
