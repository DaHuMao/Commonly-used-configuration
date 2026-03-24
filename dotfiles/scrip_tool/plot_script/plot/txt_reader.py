import log_tool as log_tool
import base_reader
import select_data_parser as sdp
import plot_tools as plt_tool

class TxTReader(base_reader.BaseReader):
    def __init__(self):
        super().__init__()
        self._data_paser = sdp.SelectDataParser()

    def init(self, argv:dict):
        plt_tool.update_config_all(self._config_dict, argv)
        self._data_paser.init(argv)
        f = open(self._config_dict['file_path'], "r")
        start_line, end_line = self.get_x_select_range()

        count = 0
        for line in f:
            count += 1
            if start_line > -1 and count < start_line:
                continue
            if end_line > -1 and count > end_line:
                break
            self._data_paser.insert_line(line)

    def load_data(self) -> tuple[list[list[float]], list[list[list[float]]]]:
        return_data_x, return_data_y = self._data_paser.load_data()
        if len(return_data_y) > 0:
            i = 0
            for arr in return_data_y:
                for ele in arr:
                    i = i + 1
                    log_tool.log_info("index of :%d, select_data length: %d" %\
                        (i, len(ele)))
        return return_data_x, return_data_y

    def get_plot_info(self) -> tuple[int, list[str], list[str]]:
        return self._data_paser.get_plot_info()

