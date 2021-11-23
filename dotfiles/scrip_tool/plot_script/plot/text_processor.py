import re

class TextProcessor:
    _config_dict = {
            'filter_include_keywords': '', \
            'filter_exclude_keywords': '', \
            'reg_pattern_include': '', \
            'reg_pattern_exclude': '', \
            'split_pattern_reg': ' ' \
    }

    def update_config(self, key, value):
        if self._config_dict.has_key(key):
            self._config_dict[key] = value
            return True
        else:
            return False

    def split_str_to_data(self, line):
        if len(self._config_dict['split_pattern_reg']) == 1:
            return line.strip().split(self._config_dict['split_pattern_reg'])
        else:
            return re.split(self._config_dict['split_pattern_reg'], line.strip())

    def is_valid_line(self, line):
        if self._config_dict['filter_include_keywords'] != '' \
                and line.find(self._config_dict['filter_include_keywords']) == -1:
            return False
        if self._config_dict['reg_pattern_include'] != '' \
                and re.search(self._config_dict['reg_pattern_include'], line) == None:
            return False
        if self._config_dict['filter_exclude_keywords'] != '' \
                and line.find(self._config_dict['filter_exclude_keywords']) != -1:
            return False
        if self._config_dict['reg_pattern_exclude'] != '' \
                and re.search(self._config_dict['reg_pattern_exclude'], line) != None:
            return False
        return True

