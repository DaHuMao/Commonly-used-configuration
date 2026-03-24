import time
import os
import sys
import datetime

import log_tool
def get_now_time(format_time='%Y-%m-%d %H:%M:%S'):
    now_time=datetime.datetime.now()
    return now_time.strftime(format_time)

def get_now_time_ms():
    t = time.time()
    return int(round(t * 1000))

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

def select_data(select_index, data, data_scale, return_data):
    for i in range(len(select_index)):
        index = int(select_index[i])
        if index >= len(data):
            raise Exception("select_raw[%d]: %d overflow" % (i, index))
        try:
            return_data[i].append(float(data[index]) * data_scale[i])
        except:
            log_tool.log_error("in %s\n, index: %d value: %s is invalid" % \
                    (str(data), index, data[index]))
            raise Exception("can not  convert  %s to float" % (data[index]))


def get_data(data_x, data_y, select_y):
    if len(data_y) == 0 or len(select_y) == 0:
        raise Exception("invalid length of array, " \
                "len(data_y):%d, len(select_y): %d" % \
                (len(data_y), len(select_y)))
    x_data = data_x
    y_data = []
    start_index = 0
    for i in range(len(select_y)):
        end_index = len(select_y[i].split(',')) + start_index
        y_data.append(data_y[start_index : end_index])
        start_index = end_index
    for i in range(len(y_data)):
        if i >= len(x_data):
            tmp_data=[]
            for ee in y_data[i]:
                tmp_data.append(range(0, len(ee)))
            x_data.append(tmp_data)
    return x_data, y_data

def get_data_from_dict(data_dict:dict[str, dict[str,list[float]]], select_key:list[str]):
    data = {}
    for key, val in data_dict.items():
        data[key] = []
        for key_str in select_key:
            if key_str == 'null':
                data[key].append([])
                continue
            ele_arr = key_str.split(',')
            tmp_data = []
            for ele in ele_arr:
                if ele in val:
                    tmp_data.append(val[ele])
                else:
                    log_tool.log_abort(f'key: {key} not in data_dict {data_dict.keys()}')
            data[key].append(tmp_data)
    return data


def update_config(config_dict, key, value):
    if key not in config_dict:
        return False
    if isinstance(value, type(config_dict[key])) is True:
        config_dict[key] = value
    elif isinstance(value, str) is True:
        if isinstance(value, list) is True:
            config_dict[key] = value
        else:
            config_dict[key] = value.strip().split()
    else:
        log_tool.log_abort("invalid value type: %s" % value)
    return True

def update_config_all(config_dict:dict, argv:dict):
   for key, value in argv.items():
       update_config(config_dict, key, value)

def update_obj_config(obj, argv:dict):
    for key, val in argv.items():
        obj.update_config(key, val)

def is_esc_pressed():
    if os.name == 'nt':
        # This is for windows OS
        import msvcrt
        if msvcrt.kbhit():
            return msvcrt.getch() == b'\x1b'
    else:
        # Unix/Linux system
        import termios
        import tty
        def getch():
            fd = sys.stdin.fileno()
            original_attributes = termios.tcgetattr(fd)
            try:
                tty.setraw(sys.stdin.fileno())
                ch = sys.stdin.read(1)
            finally:
                termios.tcsetattr(fd, termios.TCSADRAIN, original_attributes)
            return ch

        return getch() == '\x1b'
    return False

