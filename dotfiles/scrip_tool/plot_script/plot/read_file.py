import plot_tools as plt_tool
import log_tool as log_tool

class TxTFileReader:
    _file_path = ''
    _text_processor = None
    _return_data_x = []
    _return_data_y = []
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

    def init(self, text_processor, data_parser_x, data_parser_y):
        self._text_processor = text_processor
        f = open(self._config_dict['file_path'], "r")
        start_line = -1
        end_line = -1
        if len(self._config_dict['x_select_range']) == 2:
            start_line = int(self._config_dict['x_select_range'][0])
            end_line = int(self._config_dict['x_select_range'][1])
            log_tool.log_info("x_select_range is %d~%d" % (start_line, end_line))

        count = 0
        for line in f:
            count += 1
            if start_line > -1 and count < start_line:
                continue
            if end_line > -1 and count > end_line:
                break
            if self._text_processor.is_valid_line(line) == False:
                continue
            data = self._text_processor.split_str_to_data(line)
            if data_parser_x != None:
                data_parser_x.insert_line(data)
            if data_parser_y != None:
                data_parser_y.insert_line(data)

        if data_parser_x != None:
            self._return_data_x = data_parser_x.move_data()
        self._return_data_y = data_parser_y.move_data()
        if len(self._return_data_y) > 0:
            for i in range(len(self._return_data_y)):
                log_tool.log_info("index of :%d, select_data length: %d" %\
                        (i, len(self._return_data_y[0])))

    def load_data(self):
        return self._return_data_x, self._return_data_y
