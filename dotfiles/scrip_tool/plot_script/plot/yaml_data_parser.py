import base_line_parser
import log_tool
import yaml
from dataclasses import dataclass, field

DEFAULT_GROUP_NAME = 'default_group'

@dataclass
class DataInfo:
    name: str = ''
    pos: list[int] = field(default_factory=list)
    group: str = DEFAULT_GROUP_NAME
    data: list[float] = field(default_factory=list)
    scale: float = 1.0

@dataclass
class GroupInfo:
    name: str = DEFAULT_GROUP_NAME
    data_index: list[int] = field(default_factory=list)


@dataclass
class KeyInfo:
    key: str = ''
    data_index: list[int] = field(default_factory=list)
    split_reg: list[str] = field(default_factory=list)


class YamlDataParser(base_line_parser.BaseLineParser):
    def __init__(self,  yaml_str:str):
        self._yaml_data = yaml.safe_load(yaml_str)
        self._data_info_list = []
        self._group_order = []
        self._key_list = []
        if not isinstance(self._yaml_data, dict):
            log_tool.log_abort("yaml data is not dict: %s yaml_str: %s" % \
                    (str(self._yaml_data), yaml_str))
        if len(self._yaml_data) == 0:
            log_tool.log_abort("yaml data is empty, str: %s" % yaml_str)
        self.InitDataFromYamlData()
        base_line_parser.BaseLineParser.__init__(self, len(self._data_info_list))
        select_index=0
        for group_info in self._group_order:
            if len(group_info.data_index) == 0:
                log_tool.log_abort("yaml data group has no data: %s" % str(group_info))
            for index in group_info.data_index:
                if index < 0 or index >= len(self._data_info_list):
                    log_tool.log_abort("yaml data group has invalid data index: %s" % str(group_info))
                self._select_data[select_index] = self._data_info_list[index].data
                select_index = select_index + 1

        log_tool.log_info("YamlDataParser data_info_list: %s" % str(self._data_info_list))
        log_tool.log_info("YamlDataParser group_order: %s" % str(self._group_order))
        log_tool.log_info("YamlDataParser key_list: %s" % str(self._key_list))

    def get_select_y_and_scale(self):
        select_y_key = []
        title_name = []
        scale = []
        for group_info in self._group_order:
            if len(group_info.data_index) == 0:
                log_tool.log_abort("yaml data group has no data: %s" % str(group_info))
            y_key = []
            for index in group_info.data_index:
                if index < 0 or index >= len(self._data_info_list):
                    log_tool.log_abort("yaml data group has invalid data index: %s" % str(group_info))
                y_key.append(self._data_info_list[index].name)
                scale.append(self._data_info_list[index].scale)
            select_y_key.append(",".join(y_key))
            title_name.append(group_info.name)
        return select_y_key, scale, title_name

    def InitDataFromYamlData(self):
        group_order = self._yaml_data.get('group_order', [])
        for group in group_order:
            group_info = GroupInfo()
            group_info.name = group
            self._group_order.append(group_info)

        key_infos = self._yaml_data.get('keys', None)
        if key_infos is None or not isinstance(key_infos, dict):
            log_tool.log_abort(f"yaml data keys is invalid: {str(key_infos)}, keys_type: {str(type(key_infos))}")
        for key_it, val_it in key_infos.items():
            if not isinstance(val_it, dict):
                log_tool.log_abort("yaml data key item is not dict: %s" % str(val_it))
            key_info = KeyInfo()
            self._key_list.append(key_info)
            key_info.key = key_it
            key_info.split_reg = val_it.get('split_reg', [])
            if key_info.key == '':
                log_tool.log_abort("yaml data key item is invalid: %s" % str(val_it))
            select_data = val_it.get('select', [])
            if not isinstance(select_data, list) or len(select_data) == 0:
                log_tool.log_abort("yaml data key item select_data is invalid: %s" % key_it)
            index = 0
            for select_item in select_data:
                if not isinstance(select_item, dict):
                    log_tool.log_abort("yaml data key item select_data item is not dict: %s" % str(select_item))
                data_info = DataInfo()
                self._data_info_list.append(data_info)
                key_info.data_index.append(len(self._data_info_list) - 1)
                data_info.pos = select_item.get('pos', [])
                data_info.scale = select_item.get('scale', 1.0)
                if not isinstance(data_info.pos, list) or len(data_info.pos) != len(key_info.split_reg):
                    log_tool.log_abort("yaml data key item select_data item pos is invalid: %s" % str(select_item))
                data_info.name = select_item.get('name', '')
                if data_info.name == '':
                    data_info.name = key_info.key
                    if index > 0:
                        data_info.name = data_info.name + str(index)
                data_info.group = select_item.get('group', DEFAULT_GROUP_NAME)
                current_index = len(self._data_info_list) - 1
                is_find = False
                for group_info in self._group_order:
                    if data_info.group == group_info.name:
                        group_info.data_index.append(current_index)
                        is_find = True
                        break
                if not is_find:
                    group_info = GroupInfo()
                    group_info.name = data_info.group
                    group_info.data_index.append(current_index)
                    self._group_order.append(group_info)
                index = index + 1

    def get_arr(self, str_data, split_reg, index):
        if index == len(split_reg):
                try:
                    float_val = float(str_data)
                    return float_val
                except:
                    log_tool.log_abort("can not convert %s to float" % str_data)
        else:
            tmp_arr = []
            ch = split_reg[index]
            sub_data_arr = [x for x in str_data.split(ch) if x != '']
            for i in range(0, len(sub_data_arr)):
                tmp_arr.append(self.get_arr(sub_data_arr[i], split_reg, index + 1))
            return tmp_arr

    def get_data_in_arr(self, arr_or_val, pos:list[int], pos_index, scale):
        if pos_index == len(pos):
            return arr_or_val * scale
        cur_index = pos[pos_index] - 1
        if cur_index < 0:
            tmp_arr = []
            for ele in arr_or_val:
                tmp_arr.append(self.get_data_in_arr(ele, pos, pos_index + 1, scale))
            return tmp_arr
        else:
            if cur_index >= len(arr_or_val):
                log_tool.log_abort("get_data_in_arr index overflow, index: %d, arr: %s" % (cur_index, str(arr_or_val)))
            return self.get_data_in_arr(arr_or_val[cur_index], pos, pos_index + 1, scale)


    def insert_data(self, data_arr, data_info_index):
        data_info = self._data_info_list[data_info_index]
        data_info.data.extend(self.get_data_in_arr(data_arr, data_info.pos, 0, data_info.scale))

    def insert_key_value(self, key, value):
        for key_info in self._key_list:
            if key == key_info.key:
                if len(key_info.split_reg) > 0:
                    data_arr = self.get_arr(value, key_info.split_reg, 0)
                    for data_index in key_info.data_index:
                        self.insert_data(data_arr, data_index)
                else:
                    if len(key_info.data_index) != 1:
                        log_tool.log_abort("YamlDataParser key has multiple data_index for non array value: %s" % str(key_info))
                    self._data_info_list[key_info.data_index[0]].data.append(float(value))
                return

    def insert_line(self, data):
        if isinstance(data, dict):
            for key, value in data.items():
                self.insert_key_value(key, value)
        elif isinstance(data, list):
            for i in range(0, len(data) - 1):
                    self.insert_key_value(data[i], data[i + 1])
        else:
            log_tool.log_abort("YamlDataParser unsupport data type: %s, data: %s" % (str(type(data)), str(data)))

