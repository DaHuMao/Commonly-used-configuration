import log_tool


class BaseLineParser:
    def __init__(self, data_len):
        self._data_len = data_len
        self._select_data = [[] for _ in range(0, data_len)]
        self.data_scale = [1.0 for _ in range(0, data_len)]

    def move_data(self):
        tmp = self._select_data
        self._select_data = []
        return tmp

    def reference_data(self):
        return self._select_data

    def y_raw_dim(self):
        return self._data_len

    def clear_cache(self):
        for ee in self._select_data:
            ee.clear()
    def set_data_scale(self, scale):
        if not isinstance(scale, list):
            log_tool.log_abort("scale is not list: %s" % str(scale))
        if len(scale) != self._data_len:
            log_tool.log_abort("scale size: %d not eq select_raw size: %d" % (len(scale), self._data_len))
        self.data_scale = scale

