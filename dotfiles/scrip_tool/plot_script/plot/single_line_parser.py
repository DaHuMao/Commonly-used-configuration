import base_line_parser
import plot_tools as plt_tool

class SingleLineParser(base_line_parser.BaseLineParser):
    _is_first = False
    def __init__(self, select_raw):
        base_line_parser.BaseLineParser.__init__(self, select_raw)
        self._is_first = True

    def insert_line(self, data):
        if self._is_first is True:
            self._is_first = False
            self._select_raw = plt_tool.key_to_index(self._select_raw, data)
        plt_tool.select_data(self._select_raw, data, self._select_data)
    pass
