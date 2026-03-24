import base_line_parser
import log_tool

class MultiLineParser(base_line_parser.BaseLineParser):
    def __init__(self, select_raw):
        self._select_raw = select_raw
        base_line_parser.BaseLineParser.__init__(self, len(select_raw))

    def select_data_with_list(self, data):
        # self._select_raw 数据的标志位
        flags = [False for _ in range(0, len(self._select_raw))]
        for i in range(0, len(data) - 1):
            for j in range(0, len(self._select_raw)):
                if data[i] == self._select_raw[j] and flags[j] == False:
                    try:
                        flags[j] = True
                        self._select_data[j].append(float(data[i + 1]) * self.data_scale[j])
                    except:
                        log_tool.log_error("error in str " + str(data))
                        log_tool.log_error("key: %s index: %d value: %s scale: %s is invalid" % \
                                (data[i], i, data[i + 1], str(self.data_scale)))
                        raise Exception("can not  convert  %s to float" % (data[i + 1]))
                    break
    def select_data_with_dict(self, data:dict):
        for key, val in data.items():
            for j in range(0, len(self._select_raw)):
                if key == self._select_raw[j]:
                    try:
                        self._select_data[j].append(float(val) * self.data_scale[j])
                    except:
                        log_tool.log_error("error in str " + str(data))
                        log_tool.log_error("key: %s value: %s scale: %s is invalid" % \
                                (key, str(val), str(self.data_scale)))
                        raise Exception("can not  convert  %s to float" % (val))
                    break


    def insert_line(self, data):
        if isinstance(data, list):
            self.select_data_with_list(data)
        elif isinstance(data, dict):
            self.select_data_with_dict(data)
        else:
            log_tool.log_abort("MultiLineParser data is not list or dict: %s" % str(data))

