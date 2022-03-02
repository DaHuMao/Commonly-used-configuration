import matplotlib.pyplot as plt
import numpy as np

n = 12
X = np.arange(n)
Y1 = (1-X/n)*np.random.uniform(0.5,1.0,n)
print(type(X))
print(Y1)
Y1 = [0.25, 0.31, 0.21, 0.13, 0.03, 0, 0.03, 0, 0]
Y2 = [3, 2, 3, 5, 8, 1, 1, 2, 1]
print([1] * 5)
# 由于返回值，进过提取是str，操作小数位数不方便，外面提前处理好
p1 = plt.bar(range(len(Y1)),Y1,width=0.8,facecolor='deeppink',label='IAT')

def autolabel(rects):
    """Attach a text label above each bar in *rects*, displaying its height."""
    for rect in rects:
        height = rect.get_height()
        plt.annotate('{}'.format(height),
                    xy=(rect.get_x() + rect.get_width() / 2, height),
                    xytext=(0, 3),  # 3 points vertical offset
                    textcoords="offset points",
                    ha='center', va='bottom')

# 为什么有两个hight
def add_labels(rects):
    for rect in rects:
        height = rect.get_height()
        plt.text(rect.get_x() + rect.get_width()/2,height,height, ha='center', va='bottom')
        rect.set_edgecolor('white')

# add_labels(p1)

autolabel(p1)

plt.legend(loc='best')
plt.show()   



