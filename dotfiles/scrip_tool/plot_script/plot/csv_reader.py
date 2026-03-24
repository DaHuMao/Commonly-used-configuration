import base_reader
import select_data_parser as sdp
import log_tool
import plot_tools as plt_tool
import csv
import re

def insert_data_to_dict(str_key:str, data:dict[str, list], keys:list[str], value:dict[str, float]):
    if str_key not in data:
       data[str_key] = {}
       for key in keys:
           data[str_key][key] = []
    for key in keys:
        if key == 'null':
            continue
        if key not in value:
            log_tool.log_abort(f'key: {key} not in value: {value}')
        try:
            data[str_key][key].append(float(value[key]))
        except:
            log_tool.log_abort(f'key: {key} value: {value[key]} is invalid')

class CSVReader(base_reader.BaseReader):
    def __init__(self):
        super().__init__()
        self._config_dict.update({
            'select_key_y_csv': [],
            'select_key_x_csv': [],
            'select_filter_key_csv': '',
            'enable_combination_mode': False,
        })
        self._data_dict_y = {}
        self._data_dict_x = {}
        self._data_parse = None

    def get_filter_info(self):
        if (self._config_dict['select_filter_key_csv'] == ''):
            return True, None
        filter_key_arr = re.split(r'[:,]', self._config_dict['select_filter_key_csv'])
        return filter_key_arr[-1] == '1', filter_key_arr[0:-1]

    def get_key_dict(self, key_str_arr:list[str])-> list[str]:
        key_set = set()
        for key in key_str_arr:
            arr = key.strip().split(',')
            for ele in arr:
                key_set.add(ele)
        return list(key_set)



    def InitWithUnCombinationMode(self):
        log_tool.log_info(f'filter_key: {self._config_dict["select_filter_key_csv"]}')
        x_key_len = len(self._config_dict['select_key_x_csv'])
        if x_key_len > 0:
            while x_key_len < len(self._config_dict['select_key_y_csv']):
                self._config_dict['select_key_x_csv'].append(self._config_dict['select_key_x_csv'][-1])
                x_key_len = x_key_len + 1

        x_list = self.get_key_dict(self._config_dict['select_key_x_csv'])
        y_list = self.get_key_dict(self._config_dict['select_key_y_csv'])
        _, filter_key = self.get_filter_info()
        with open(self._config_dict['file_path'], mode='r', newline='') as file:
            # 创建一个字典阅读器对象
            csv_dict_reader = csv.DictReader(file)
            read_count = 0
            start_line, end_line = self.get_x_select_range()
            for row in csv_dict_reader:
                read_count += 1
                if start_line > -1 and read_count < start_line:
                    continue
                if end_line > -1 and read_count > end_line:
                    break
                str_key = ' '
                if filter_key is not None:
                    for key in filter_key:
                        if key not in row:
                            log_tool.log_abort(f'filter key: {key} not in csv file row: {row}')
                        if str_key != '':
                            str_key = str_key + '_' + row[key]
                        else:
                            str_key = row[key]
                insert_data_to_dict(str_key, self._data_dict_y, y_list, row)
                insert_data_to_dict(str_key, self._data_dict_x, x_list, row)

    def InitWithCombinationMode(self, message:str):
        with open(self._config_dict['file_path'], mode='r', newline='') as file:
            # 创建一个字典阅读器对象
            csv_dict_reader = csv.DictReader(file)
            read_count = 0
            start_line, end_line = self.get_x_select_range()
            for row in csv_dict_reader:
                read_count += 1
                if start_line > -1 and read_count < start_line:
                    continue
                if end_line > -1 and read_count > end_line:
                    break
                key_str = row.get(message, '')
                if key_str == '':
                    log_tool.log_abort(f'key: {message} not in csv file row: {row}')
                self._data_parse.insert_line(key_str)


    def init(self, argv:dict):
        plt_tool.update_config_all(self._config_dict, argv)
        enable_combination_mode = argv.get('enable_combination_mode', False)
        log_tool.log_info(f'enable_combination_mode: {enable_combination_mode}')
        if enable_combination_mode:
            message = argv.get('combination_message', '')
            if message == '':
                log_tool.log_abort('key_message is empty')
            self._data_parse = sdp.SelectDataParser()
            self._data_parse.init(argv)
            self.InitWithCombinationMode(message)
        else:
            self.InitWithUnCombinationMode()


    def load_data(self) -> tuple[list[list[float]], list[list[list[float]]]]:
        if self._data_parse != None:
            return self._data_parse.load_data()
        tmp_data_x = plt_tool.get_data_from_dict(\
                self._data_dict_x, self._config_dict['select_key_x_csv'])
        tmp_data_x2 = {}
        for key, val in tmp_data_x.items():
            tmp_data_x2[key] = []
            for ele in val:
                if len(ele) > 0:
                    if len(ele) != 1:
                        log_tool.log_abort(f'invalid data length: {len(ele)}')
                    tmp_data_x2[key].append(ele[0])
                else:
                    tmp_data_x2[key].append([])
        tmp_data_y = plt_tool.get_data_from_dict(\
                    self._data_dict_y, self._config_dict['select_key_y_csv'])
        merge_col, _ = self.get_filter_info()
        return_data_x = []
        return_data_y = []
        for key, val in tmp_data_y.items():
            if len(return_data_y) == 0:
                return_data_y = val
                return_data_x = tmp_data_x2[key]
            else:
                if merge_col:
                    return_data_y.extend(val)
                    return_data_x.extend(tmp_data_x2[key])
                else:
                    for i in range(0, len(val)):
                        return_data_y[i].extend(val[i])
        if len(return_data_x) == 0:
            return_data_x.append([])
        if len(return_data_y) > 0:
            count = 0
            for i in range(0, len(return_data_y)):
                max_arr_len = 0
                for ele in return_data_y[i]:
                    max_arr_len = max(max_arr_len, len(ele))
                    count = count + 1
                    log_tool.log_info("index of :%d, select_data length: %d" %\
                        (count, len(ele)))
                if len(return_data_x) < i + 1:
                    return_data_x.append(return_data_x[-1])
                elif len(return_data_x[i]) == 0:
                    return_data_x[i] = range(0, max_arr_len)
        return return_data_x, return_data_y

    def get_plot_info(self) -> tuple[int, list[str], list[str]]:
        if self._data_parse != None:
            return self._data_parse.get_plot_info()
        merge_col, _ = self.get_filter_info()
        select_y_key = self._config_dict['select_key_y_csv']
        count = len(select_y_key)
        if len(self._data_dict_y) == 1:
            return count, select_y_key, select_y_key
        if merge_col:
            count = count * len(self._data_dict_y)
        legend_name = []
        title_name = []
        if merge_col:
            for key in self._data_dict_y.keys():
                for ele in select_y_key:
                    title_name.append(key + '_' + ele)
                    legend_name.append(ele)
        else:
            for ele in select_y_key:
                key_name_with_ele = ''
                for key in self._data_dict_y.keys():
                    key_name_arr = ele.split(',')
                    for key_name in key_name_arr:
                        if key_name_with_ele == '':
                            key_name_with_ele = key + '_' + key_name
                        else:
                            key_name_with_ele = key_name_with_ele + ',' + key + '_' + key_name
                title_name.append(key_name_with_ele)
            legend_name = title_name
        return count, title_name, legend_name
