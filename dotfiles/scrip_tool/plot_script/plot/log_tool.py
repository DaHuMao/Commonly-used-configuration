import plot_tools as plt_tool

class LogTool:
    _log_level = 0
    _log_level_name_map = ["DEBUG", "INFO", "WARNING", "ERROR"]
    _log_color = [35, 32, 33, 31]
    _text_filter = None
    
    def set_text_filter(self, text_filter):
        self._text_filter = text_filter

    def set_log_level(self, log_level):
        if log_level >= 0 and log_level < len(self._log_level_name_map):
            self._log_level = log_level 

    def get_log_head(self, level): 
        str_time='[' + plt_tool.get_now_time() + '] '
        return "\033[0;%d;20m%s\033[0;%d;40m%s: \033[0m" % (self._log_color[level],\
                str_time, self._log_color[level], self._log_level_name_map[level])

    def log(self, level, value, f=None):
        if level < self._log_level or (self._text_filter != None \
                and not self._text_filter.is_valid_line(value)):
            return
        if level > len(self._log_level_name_map):
            level = len(self._log_level_name_map) - 1
        print("%s %s" % (self.get_log_head(level), value))
        if f is not None:
            log_str= '[' + plt_tool.get_now_time() + ']' + \
                    self._log_level_name_map[level] + value + "\n"
            f.write(log_str)
        return

gLogTool = LogTool()
LOG_DEBUG_LEVEL = 0
LOG_INFO_LEVEL = 1
LOG_WARN_LEVEL = 2
LOG_ERROR_LEVEL = 3

def set_log_level(log_level):
    gLogTool.set_log_level(log_level)

def set_text_filter(text_filter):
    gLogTool.set_text_filter(text_filter)

def format_args(*args):
    value = ""
    for i in range(0, len(args) - 1):
        value += str(args[i]) + " "
    value += str(args[-1])
    return value


def log_debug(*args):
    gLogTool.log(LOG_DEBUG_LEVEL, format_args(*args))

def log_info(*args):
    gLogTool.log(LOG_INFO_LEVEL, format_args(*args))

def log_warn(*args):
    gLogTool.log(LOG_WARN_LEVEL, format_args(*args))

def log_error(*args):
    gLogTool.log(LOG_ERROR_LEVEL, format_args(*args))
