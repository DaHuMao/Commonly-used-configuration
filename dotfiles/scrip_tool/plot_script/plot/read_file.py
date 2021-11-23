import text_processor

class TxTFileReader:
    _file_path = ''
    _text_processor = None
    _config_dict = {
                'x_select_range':[]
            }
    
    def update_config(self, key, value):
        if  self._config_dict.has_key(key) is False:
            return False
        self._config_dict[key] = value.strip().split() 
        return True

    def init(self, file_path, text_processor):
        self._file_path = file_path
        self._text_processor = text_processor

    def key_to_index(self, select_raw, data):
        select_index = []
        for ee in select_raw:
            try:
                select_index.append(data.index(ee) + 1)
            except ValueError:
                raise Exception("ValueError find %s in: " % ee, data)
        return select_index

    def select_data(self, select_index, data, return_data):
        for i in range(len(select_index)):
            index = int(select_index[i])
            if index >= len(data):
                raise Exception("select_raw[%d]: %d overflow" % (i, index))
            return_data[i].append(float(data[index]))


    def load_data(self, select_raw_x, select_raw_y, is_index):
        f = open(self._file_path, "r")
        select_index_y = []
        if is_index is True:
            select_index_y = select_raw_y
        return_data_x = [[] for _ in range(len(select_raw_x))] 
        return_data_y = [[] for _ in range(len(select_raw_y))]
        start_line = -1
        end_line = -1
        if len(self._config_dict['x_select_range']) == 2:
            start_line = int(self._config_dict['x_select_range'][0])
            end_line = int(self._config_dict['x_select_range'][1])
            print("x_select_range is %d~%d" % (start_line, end_line))
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
            if len(select_index_y) == 0:
                select_index_y = self.key_to_index(select_raw_y, data)
            self.select_data(select_raw_x, data, return_data_x)
            self.select_data(select_index_y, data, return_data_y)
        return return_data_x, return_data_y

            

