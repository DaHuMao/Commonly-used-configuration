class BaseLineParser:
    def __init__(self, select_raw):
        self._select_raw = select_raw
        self._select_data = [[] for _ in range(0, len(self._select_raw))]

    def move_data(self):
        tmp = self._select_data
        self._select_data = []
        return tmp

    def reference_data(self):
        return self._select_data

    def y_raw_dim(self):
        return len(self._select_raw)

    def clear_cache(self):
        for ee in self._select_data:
            ee.clear()

