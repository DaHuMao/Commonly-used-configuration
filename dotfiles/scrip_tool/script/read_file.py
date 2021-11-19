import rg

class TxTFileReader:
    _include_str = ''
    _exclude_str = ''
    _reg_pattern_include = ''
    _reg_pattern_exclude = ''
    _split_pattern_reg = ' '
    _file_path = ''
    
    def init(self, file_path, split_pattern_reg, include_str, exclude_str, reg_pattern_include, reg_pattern_exclude):
        self._file_path = file_path
        self._include_str = include_str
        self._reg_pattern_include = reg_pattern_include
        self._exclude_str = exclude_str
        self._reg_pattern_exclude = reg_pattern_exclude
        if split_pattern_reg != '':
            self._split_pattern_reg = split_pattern_reg;

    def split_str(self, line):
        if len(self._split_pattern_reg) == 1:
            return line.strip().split(self._split_pattern_reg)
        else:
            return re.split(self._split_pattern_reg, line)

    def is_valid_line(self, line):
        if self._include_str != '' && line.find(self._include_str) == -1:
            return False
        if self._reg_pattern_include != '' && re.search(self.reg_pattern_include, line) == None:
            return False
        if self._exclude_str != '' && line.find(self._exclude_str) != -1:
            return False
        if self._reg_pattern_exclude != '' && re.search(self.reg_pattern_exclude, line) != None:
            return False
        return True

    def read_data(self, select_raw):
        f = open(file_path, "r")
        return_data = []
        for line in f:
            if self.is_valid_line(line) == False:
                continue
            data = self.split_str(line)
            for index in select_raw:
                if int(index) >= len(data):
                    raise Exception("select_raw[%d]: %d overflow" % (i, (int)index))
                return_data.append(float[data[int(index)]])
        return return_data

            

