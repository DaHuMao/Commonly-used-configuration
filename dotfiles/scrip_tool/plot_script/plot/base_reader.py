import log_tool
from abc import ABC, abstractmethod
class BaseReader(ABC):
    def __init__(self):
        self._config_dict = {
                'file_path':'', \
                'x_select_range':[]
            }

    def get_x_select_range(self):
        start_line = -1
        end_line = -1
        if len(self._config_dict['x_select_range']) == 2:
            start_line = int(self._config_dict['x_select_range'][0])
            end_line = int(self._config_dict['x_select_range'][1])
            log_tool.log_info("x_select_range is %d~%d" % (start_line, end_line))
        return start_line, end_line

    @abstractmethod
    def load_data(self) -> tuple[list[list[float]], list[list[list[float]]]]:
        pass

    @abstractmethod
    def get_plot_info(self) -> tuple[int, list[str], list[str]]:
        pass

