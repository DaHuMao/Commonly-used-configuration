import matplotlib.pyplot as plt
import numpy as np

n = 12
X = np.arange(n)
Y1 = (1-X/n)*np.random.uniform(0.5,1.0,n)
print(type(X))
print(Y1)
Y1 = [0.25, 0.31, 0.21, 0.13, 0.03, 0, 0.03, 0, 0]
Y2 = [3, 2, 3, 5, 8, 1, 1, 2, 1]
# 由于返回值，进过提取是str，操作小数位数不方便，外面提前处理好
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
        #rect.set_edgecolor('white')

def get_x(x, y_dim, index, width):
    x_ans = []
    for xx in x:
        base_pos = xx - width / 2;
        start_pos = base_pos + index * width / y_dim
        end_pos = base_pos + (index + 1) * width / y_dim
        x_ans.append((start_pos + end_pos) / 2)
    return x_ans


# add_labels(p1)

loss_arr = []
def CaculateCost(loss_weight):
    loss = 1.0
    for i in range(len(arr)):
        loss -= loss_arr[i]

#autolabel(p1)
y_dim = 3
y_width = 0.9
x = range(0, len(Y1))
print(x)
color_dict = ['deeppink', 'red', 'green']
for i in range(y_dim):
    xx = get_x(x, y_dim, i, y_width)
    print(xx)
    p = plt.bar(get_x(x, y_dim, i, y_width),Y1,width=y_width / y_dim,facecolor=color_dict[i],label='IAT %d' % i)
    add_labels(p)

plt.legend(loc='best')
plt.show()   



