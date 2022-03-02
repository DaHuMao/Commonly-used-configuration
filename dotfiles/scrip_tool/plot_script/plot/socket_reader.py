import socket
import threading
import time
import plot_tools as plt_tool

class SocketReader:
    _config_dict = {
                'ip': '127.0.0.1', \
                'port': '9600', \
                'data_storage_len': '1000'
            }
    _stop = True
    _is_first = True
    _receiver_thread = None
    _listen_thread = None
    _listen_socket = None
    _recever_socket = None
    _rlock = threading.Lock()

    _text_processor = None
    _select_raw_y = None
    _select_data_y = []
    _select_data_y_prepare = []
    _remainder_str = ''
   
    def update_config(self, key, value):
        if  key not in self._config_dict:
            return False
        if isinstance(self._config_dict[key], str):
            self._config_dict[key] = value
        else:
            self._config_dict[key] = value.strip().split() 
        return True

    def init(self, text_processor, select_raw_y):
        self._text_processor = text_processor
        self._select_raw_y = select_raw_y
        self._is_first = True
        self._select_data_y = [[] for _ in range(0, len(self._select_raw_y))]
        self._select_data_y_prepare = [[] for _ in range(0, len(self._select_raw_y))]

    def start_server(self):
        if self._stop is False:
            plt_tool.log_info('server has running')
            return
        else:
            self._stop = False
        self._listen_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        host = self._config_dict['ip']
        port = int(self._config_dict['port'])
        self._listen_socket.bind((host, port))
        self._listen_socket.listen(1)
        self._listen_thread = threading.Thread(\
                target = self.listen_client)
        self._listen_thread.start()

    
    def listen_client(self):
        while self._stop is False:
            try:
                self._recever_socket,addr = self._listen_socket.accept()
                plt_tool.log_info("===== client connected: ip:%s port:%s" % (addr[0], addr[1]))
                self._remainder_str = ''
                if self._receiver_thread == None:
                    self._receiver_thread = threading.Thread(\
                            target = self.receiver_data)
                    self._receiver_thread.start()
            except Exception as e:
                plt_tool.log_error(e)

    def get_x_y(self, str_data):
        for line in str_data:
            if self._text_processor.is_valid_line(line) == False:
                continue
            data = self._text_processor.split_str_to_data(line)
            if self._is_first is True:
                self._is_first = False
                self._select_raw_y = plt_tool.key_to_index(self._select_raw_y, data)
            self._rlock.acquire()
            try:
                plt_tool.select_data(self._select_raw_y, \
                        data, self._select_data_y_prepare)
            finally:
                self._rlock.release()

    def receiver_data(self):
        while self._stop is False:
            try:
                if self._recever_socket is None:
                    plt_tool.log_info("no client")
                    time.sleep(2)
                    continue
                data = self._recever_socket.recv(1024)
                recv_str = bytes.decode(data)
                if len(data) > 0:
                    if recv_str == 'exit':
                        plt_tool.log_info('client close')
                        self._recever_socket.close()
                        self._recever_socket = None
                    else:
                        has_remain_str = recv_str[-1] != '\n'
                        str_data = recv_str.split('\n')
                        if str_data[-1] == '':
                            str_data.pop()
                        if self._remainder_str != '':
                            str_data[0] = self._remainder_str + str_data[0]
                            self._remainder_str = ''
                        if has_remain_str:
                            self._remainder_str = str_data[-1]
                            str_data.pop()
                        self.get_x_y(str_data)

                else:
                    plt_tool.log_info('no data')
                    time.sleep(2)
            except Exception as e:
                if self._recever_socket is not None:
                    self._recever_socket.close()
                    self._recever_socket = None
                plt_tool.log_error(e)
    
    def stop(self):
        self._stop = True
        if self._listen_socket is not None:
            self._listen_socket.close()
        if self._recever_socket is not None:
            self._recever_socket.close()
        if self._listen_thread is not None:
            self._listen_thread.join()
        if self._receiver_thread is not None:
            self._receiver_thread.join()
        plt_tool.log_info('SocketReader has stoped')

    def load_data(self):
        self._rlock.acquire()
        try:
            for i in range(len(self._select_data_y_prepare)):
                self._select_data_y[i].extend(self._select_data_y_prepare[i])
                self._select_data_y_prepare[i].clear()
        finally:
            self._rlock.release()
        remove_end_index = len(self._select_data_y[0]) - int(self._config_dict['data_storage_len'])
        if remove_end_index > 0:
            for ele in self._select_data_y:
                del ele[0 : remove_end_index]
        return [], self._select_data_y


