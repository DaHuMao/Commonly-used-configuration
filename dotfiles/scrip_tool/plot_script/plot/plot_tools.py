import re
import time
import datetime

gLogLevel=0
gLogMap=["INFO: ","WARNING: ","ERROR: "]
gColorMap=[32,33,31]

def get_now_time(format_time='%Y-%m-%d %H:%M'):
    now_time=datetime.datetime.now()
    return now_time.strftime(format_time)

def GetNowTimeMs():
    t = time.time()
    return int(round(t * 1000))

def mylog(level, value, f=None):
    if level < gLogLevel:
        return
    if level > 2:
        level = 2
    str_time='['+get_now_time()+'] '
    print("\033[0;%d;20m%s\033[0;%d;40m%s\033[0m%s"%(gColorMap[level],\
            str_time, gColorMap[level], gLogMap[level], value))
    if f is not None:
        log_str=str_time + gColorMap[level] + value + "\n"
        f.write(log_str)
    return

def log_info(value):
    mylog(0, value)

def log_warn(value):
    mylog(1, value)

def log_error(value):
    mylog(2, value)

def can_to_int(select_raw):
    for ee in select_raw:
        if ee.isdigit() is False:
            return False
    return True

def key_to_index(select_raw, data):
    if can_to_int(select_raw):
        return select_raw
    select_index = []
    for ee in select_raw:
        try:
            select_index.append(data.index(ee) + 1)
        except ValueError:
            raise Exception("ValueError find %s in: " % ee, data)
    return select_index

def select_data(select_index, data, return_data):
    for i in range(len(select_index)):
        index = int(select_index[i])
        if index >= len(data):
            raise Exception("select_raw[%d]: %d overflow" % (i, index))
        return_data[i].append(float(data[index]))

def get_data(data_x, data_y, select_y):
    x_data = data_x
    x_data_default = range(0, len(data_y[0]))
    if len(x_data) > 0:
        x_data_default = x_data[0]
    y_data = []
    start_index = 0
    for i in range(len(select_y)):
        if i >= len(x_data):
            x_data.append(x_data_default)
        end_index = len(select_y[i].split(',')) + start_index
        y_data.append(data_y[start_index : end_index])
        start_index = end_index
    return x_data, y_data

class TextProcessor:
    _config_dict = {
            'filter_include_keywords': '', \
            'filter_exclude_keywords': '', \
            'reg_pattern_include': '', \
            'reg_pattern_exclude': '', \
            'split_pattern_reg': ' ' \
    }

    def update_config(self, key, value):
        if key in self._config_dict:
            self._config_dict[key] = value
            return True
        else:
            return False

    def split_str_to_data(self, line):
        if len(self._config_dict['split_pattern_reg']) == 1:
            return line.strip().split(self._config_dict['split_pattern_reg'])
        else:
            return re.split(self._config_dict['split_pattern_reg'], line.strip())

    def is_valid_line(self, line):
        if self._config_dict['filter_include_keywords'] != '' \
                and line.find(self._config_dict['filter_include_keywords']) == -1:
            return False
        if self._config_dict['reg_pattern_include'] != '' \
                and re.search(self._config_dict['reg_pattern_include'], line) == None:
            return False
        if self._config_dict['filter_exclude_keywords'] != '' \
                and line.find(self._config_dict['filter_exclude_keywords']) != -1:
            return False
        if self._config_dict['reg_pattern_exclude'] != '' \
                and re.search(self._config_dict['reg_pattern_exclude'], line) != None:
            return False
        return True

