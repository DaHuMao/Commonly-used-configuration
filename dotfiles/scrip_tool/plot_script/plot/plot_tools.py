import time
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

def select_data(select_index, data, return_data):
    for i in range(len(select_index)):
        index = int(select_index[i])
        if index >= len(data):
            raise Exception("select_raw[%d]: %d overflow" % (i, index))
        try:
            return_data[i].append(float(data[index]))
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
        if i >= len(x_data):
            x_data.append(range(0, len(data_y[start_index])))
        end_index = len(select_y[i].split(',')) + start_index
        y_data.append(data_y[start_index : end_index])
        start_index = end_index
    return x_data, y_data

