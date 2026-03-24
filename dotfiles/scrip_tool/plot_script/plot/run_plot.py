import os
import time
import threading

import plot_tools as plt_tool
import txt_reader
import csv_reader
import socket_reader
import log_tool
import plot
import text_process

class PlotEngine:
    def __init__(self):
        self._reader = None
        self._plot_data = plot.PlotData()
        self._log_filter = text_process.TextFilter()
        self._log_level = 0
        self._work_mode = ''
        self._is_exit = False
        self._event_listen_thread = None
        self._event_listen_thread_stop = True

    def event_listen(self):
        log_tool.log_info("_event_listen_thread is listenning....")
        while self._event_listen_thread_stop is False:
            if plt_tool.is_esc_pressed():
                self._is_exit = True
                log_tool.log_info("ESC pressed, exit....")
                return
            else:
                time.sleep(1)

    def init_reader(self, argv:dict):
        if self._work_mode == 'stream_mode':
            log_tool.log_info("init socket reader...")
            self._reader = socket_reader.SocketReader()
        elif self._work_mode == 'file_mode':
            suffix = os.path.splitext(argv['file_path'])[1]
            if suffix == '.csv' and not argv['force_read_as_txt']:
                log_tool.log_info("init csv reader...")
                self._reader = csv_reader.CSVReader()
            else:
                log_tool.log_info("init txt reader...")
                self._reader = txt_reader.TxTReader()
        else:
            log_tool.log_abort("invalid work_mode: %s" % self._work_mode)
        self._reader.init(argv)

    def init_plot(self, argv:dict):
        self._plot_data.update_config(argv)
        plot_count, title_name, legend_name = self._reader.get_plot_info()
        self._plot_data.set_title(title_name)
        self._plot_data.set_legend_name(legend_name)
        self._plot_data.init_plot(plot_count)


    def init_self(self, argv):
        self._work_mode = argv['work_mode']
        self._event_listen_thread = threading.Thread(target = self.event_listen)

    def check_if_is_log_config(self, key, val):
        log_key_val = {'log_filter_include_keywords':'filter_include_keywords', \
                'log_filter_exclude_keywords':'filter_exclude_keywords', \
                'log_reg_pattern_include':'reg_pattern_include', \
                'log_reg_pattern_exclude':'reg_pattern_exclude'}
        if key in log_key_val:
            self._log_filter.update_config(log_key_val[key], val)
            return True
        if key == 'log_level':
            self._log_level = int(val)

    def init_log_tool(self, argv:dict):
        for key, val in argv.items():
            self.check_if_is_log_config(key, val)
        log_tool.set_log_level(self._log_level)
        log_tool.set_text_filter(self._log_filter)

    def init(self, argv):
        self.init_self(argv)
        self.init_reader(argv);
        self.init_plot(argv)
        self.init_log_tool(argv)


    def plot(self):
        work_mode = self._work_mode
        sleep_s = 0.1
        if work_mode == 'file_mode':
            x_data, y_data = self._reader.load_data()
            self._plot_data.show_plot(x_data, y_data)
        else:
            self._event_listen_thread_stop = False
            self._event_listen_thread.start()
            self._reader.start_server()
            while self._is_exit is False:
                x_data, y_data = self._reader.load_data()
                try:
                    self._plot_data.pause_plot(x_data, y_data, sleep_s)
                except Exception as e:
                    log_tool.log_error("cache Exception: " + str(e))
                    break

    def exit(self):
        if self._work_mode == 'stream_mode':
            self._reader.stop()
            self._event_listen_thread_stop = True
            log_tool.log_info("stop _event_listen_thread...")
            self._event_listen_thread.join()
            log_tool.log_info("plot engine successed exited...")

