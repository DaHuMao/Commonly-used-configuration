# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
#import numpy as np
#import matplotlib.pyplot as plt
#cc= np.linspace(0,2,500)
#plt.rcParams['font.sans-serif'] = ['SimHei']
#plt.plot(cc,cc,label='linear')
#plt.plot(cc,cc*2,label='两倍')
#plt.plot(cc,cc**3,label='三倍')
#plt.xlabel('x label')
#plt.ylabel('y label')
#plt.title("折线图")
#plt.legend()
#plt.show()
#cc = np.linspace(0,2,100)
#plt.plot(cc,cc,label ='linear')
#plt.plot(cc,cc ** 2,label ='quadratic')
#plt.plot(cc,cc ** 3,label ='cubic')
#plt.xlabel('x label')
#plt.ylabel('y label')
import matplotlib.pyplot as plt
import sys 
import copy
def compress_data(ori_arr,compress_times):
    arr_size=int(len(ori_arr)/compress_times)
    print(arr_size)
    arr=[]
    for j in range(0,arr_size):
        sumsum=0.00
        for k in range(0,compress_times):
            sumsum+=ori_arr[j*compress_times+k]
        arr.append(sumsum/compress_times)
    return arr
class myplot:
    _data=[]
    _label=[]
    _name=''
    _title=''
    _point_size=1
    _yrange=[]
    _xlabel=''
    _sum=0
    _max_num=0
    _min_num=0

    def init(self):
        self._data=[]
        self._label=[]
        self._name=''
        self._title='plot'
        self._point_size=1
        self._yrange=[]
        self._xlabel=''
        self._sum=0
        self._max_num=-11111111111111111
        self._min_num=111111111111111111
    
    def set_label(self,label):
        self._label=label
    def set_title(self,title):
        self._title=title
    def set_point_size(self,point_size):
        self._point_size=point_size
    def set_xlabel(self,label):
        self._xlabel=label
    def set_yrange(self,x,y):
        print(x,",",y)
        self._yrange.append(x)
        self._yrange.append(y)
    def insert_data(self,element):
        if len(self._yrange) > 0 and element < self._yrange[0]:
            return
        if len(self._yrange) > 1 and element > self._yrange[1]:
            return
        self._data.append(element)
        self._sum=self._sum+element
        self._max_num=max(self._max_num,element)
        self._min_num=min(self._min_num,element)
    def plot(self,x,y,index,islast):
        self._name='mean: '+str(round(self._sum/len(self._data),2))+'\n' \
                   +'max: '+str(self._max_num)+'\n' \
                   +'min: '+str(self._min_num)
        print(self._name)
        if self._point_size > 1:
            self._data=compress_data(self._data,self._point_size)
        x_index=range(0,len(self._data))
        plt.subplot(x,y,index)
        plt.plot(x_index,self._data,label=self._name)
        if islast != 1:
            plt.xticks([])
        if islast == 1 and len(self._label) > 0:
            x2=range(0,len(self._data),int(len(self._data)/(len(self._label)-1)))
            plt.xticks(x2,self._label)
        plt.title(self._title)
        if islast == 1 and len(self._xlabel) > 0:
            plt.xlabel(self._xlabel)
        if len(self._yrange) == 2:
            plt.ylim(self._yrange)


data_dict={'label':[],'select_raw':[],'title':[],'point_size':[],'xtitle':[],'yrange':[]}
#plot_list=[]


def init_plot():
    num_argv=0
    for ele in sys.argv:
        num_argv=num_argv+1
        print(ele)
        flag=ele.strip().split('=')
        if len(flag) == 2 :
            if flag[0] in data_dict:
                data_dict[flag[0]]=flag[1].split()
    if num_argv < 2:
        print("you should input file path")
    if len(data_dict['select_raw']) == 0:
        data_dict['select_raw'].append(1);
    _title=data_dict['title']
    _label=data_dict['label']
    _point_size=data_dict['point_size']
    _xtitle=data_dict['xtitle']
    _yrange=data_dict['yrange']
    _raw=data_dict['select_raw']
    global plot_list
    plot_list=[myplot()]*len(_raw)
    plot_list[0].init()
    for i in range(1,len(_raw)):
        plot_list[i]=copy.deepcopy(plot_list[0])
        plot_list[i].init()
    for i in range(0,len(_raw)):
        if i < len(_title):
            plot_list[i].set_title(_title[i])
        if len(_label) > 0:
            plot_list[i].set_label(_label)
        if len(_point_size) > 0:
            plot_list[i].set_point_size(int(_point_size[0]))
        if len(_xtitle) > 0:
            plot_list[i].set_xlabel(_xtitle[0])
        if i < len(_yrange) :
            str_range=_yrange[i].split(',')
            print(str_range)
            if len(str_range) == 2:
                plot_list[i].set_yrange(int(str_range[0]),int(str_range[1]))


def read_data():
    file_path=sys.argv[1]
    f = open(file_path,"r")   #设置文件对象
    _raw=data_dict['select_raw']
    for line in f:
        data = line.strip().split()
        for i in range(0,len(_raw)):
            if int(_raw[i]) >= len(data):
                continue
            try:
                data_num=float(data[int(_raw[i])])
            except ValueError:
                print("error raw: ",data,data[int(_raw[i])]);
                continue
            plot_list[i].insert_data(data_num)

def plotplot():
    print(len(plot_list))
    plot_list_len=len(plot_list)
    if plot_list_len < 1:
        print("has no data")
        return
    for i in range(0,plot_list_len):
        if i != plot_list_len-1:
            plot_list[i].plot(plot_list_len,1,i+1,0)
        else:
            plot_list[i].plot(plot_list_len,1,i+1,1)
        plt.legend()

    plt.show()

init_plot()
read_data()
plotplot()























