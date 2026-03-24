import plot_tools as plt_tool
import log_tool
import text_process
import single_line_parser
import multi_line_parser
import base_line_parser
import json
import yaml_data_parser
class SelectDataParser:
    def __init__(self):
        self._config_dict = {
                'select_y_raw': [], \
                'select_x_raw': [], \
                'select_y_key': [], \
                'select_y_key_multi_line': [], \
                'data_scale_factor': '', \
                'key_message_is_json': False
                }
        self._txt_reader = None
        self._line_parser_x = None
        self._line_parser_y = None
        self._title_name = []

    def init(self, argv:dict):
        plt_tool.update_config_all(self._config_dict, argv)
        if len(self._config_dict['select_y_key_multi_line']) != 0:
            self._config_dict['select_y_key'] = self._config_dict['select_y_key_multi_line']
        self._text_processor = text_process.TextProcessor()
        plt_tool.update_obj_config(self._text_processor, argv)
        select_y_index, data_scale = self.get_y_and_scale()
        self._title_name = self._config_dict['select_y_key']
        if len(argv.get('select_y_with_yaml_format', '')) != 0:
            self._line_parser_y = yaml_data_parser.YamlDataParser(argv['select_y_with_yaml_format'])
            self._config_dict['select_y_key'], data_scale, self._title_name = self._line_parser_y.get_select_y_and_scale()
        elif len(self._config_dict['select_x_raw']) != 0:
            self._line_parser_x = single_line_parser.SingleLineParser(self._config_dict['select_x_raw'])
        elif len(self._config_dict['select_y_key_multi_line']) != 0:
            self._line_parser_y = multi_line_parser.MultiLineParser(select_y_index)
        else:
            self._line_parser_y = single_line_parser.SingleLineParser(select_y_index)
        self._line_parser_y.set_data_scale(data_scale)


    def insert_line(self, line):
        if self._text_processor.is_valid_line(line) == False:
            return
        key_message_is_json = self._config_dict.get('key_message_is_json', False)
        if key_message_is_json:
            json_data = None
            try:
                json_data = json.loads(line)
            except:
                try:
                    json_data = json.loads(line.replace("'", "\""))
                except:
                    log_tool.log_abort("invalid json line: %s" % line)
            if self._line_parser_y != None:
                self._line_parser_y.insert_line(json_data)
        else:
            data = self._text_processor.split_str_to_data(line)
            if self._line_parser_y != None:
                self._line_parser_y.insert_line(data)
            if self._line_parser_x != None:
                self._line_parser_x.insert_line(data)

    def update_select_y(self, select_y:list[str]):
        self._config_dict['select_y_key'] = select_y

    def get_select_y(self):
        if len(self._config_dict['select_y_key']) == 0:
            return self._config_dict['select_y_raw']
        else:
            return self._config_dict['select_y_key']

    def get_data(self):
        select_y = self.get_select_y()
        select_data_x = []
        if self._line_parser_x != None:
            select_data_x = self._line_parser_x.move_data()
        select_data_y = []
        if self._line_parser_y != None:
            select_data_y = self._line_parser_y.move_data()
        return plt_tool.get_data(select_data_x, select_data_y, select_y)

    def get_y_and_scale(self):
        select_y_index = []
        data_scale = []
        data_scale_str = self._config_dict['data_scale_factor'].strip().split()
        select_y = self.get_select_y()
        for i in range(0, len(select_y)):
            tmp_arr = select_y[i].split(',')
            scale_arr = None
            if len(data_scale_str) < i + 1 or data_scale_str[i] == 'null':
                data_scale.extend([1.0 for _ in range(0, len(tmp_arr))])
            else:
                scale_arr = data_scale_str[i].split(',')
            if scale_arr != None and len(scale_arr) != len(tmp_arr):
                # 打印 i select_y[i] scale_arr tmp_arr
                log_tool.log_abort("invalid scale_arr i: %s, scale_arr:%s, select_y[i]:%s" % (i, scale_arr, tmp_arr))
            for i in range(0, len(tmp_arr)):
                select_y_index.append(tmp_arr[i])
                if scale_arr != None:
                    try:
                        data_scale.append(float(scale_arr[i]))
                    except:
                        Exception('invalid data_scale_factor: %s' % scale_arr[i])
        return select_y_index, data_scale

    def load_data(self):
        return self.get_data()

    def get_plot_info(self) -> tuple[int, list[str], list[str]]:
        if len(self._config_dict['select_y_key']) == 0:
            return len(self._config_dict['select_y_raw']), [], []
        else:
            return len(self._config_dict['select_y_key']), self._title_name, self._config_dict['select_y_key'],

    def get_x_parse(self)-> base_line_parser.BaseLineParser:
        return self._line_parser_x

    def get_y_parser(self)-> base_line_parser.BaseLineParser:
        return self._line_parser_y
