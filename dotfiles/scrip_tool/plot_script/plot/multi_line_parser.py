import base_line_parser
import log_tool

class MultiLineParser(base_line_parser.BaseLineParser):
    def __init__(self, select_raw):
        base_line_parser.BaseLineParser.__init__(self, select_raw)

    def select_data(self, data):
        for i in range(0, len(data) - 1):
            for j in range(0, len(self._select_raw)):
                if data[i] == self._select_raw[j]:
                    try:
                        self._select_data[j].append(float(data[i + 1]))
                    except:
                        log_tool.log_error("in %s\n, index: %d value: %s is invalid" % \
                                (str(data), i, data[i + 1]))
                        raise Exception("can not  convert  %s to float" % (data[i + 1]))
                    break

    def insert_line(self, data):
        self.select_data(data)

