import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import freqz

# 定义传递函数的分子系数 (b)
b = [1]  # 对应 H(z) = 1 - z^{-1}

# 定义传递函数的分母系数 (a)
a = [1, -0.97]  # 对应 H(z) = 1 (仅仅用于标量)

# 计算频率响应
w, h = freqz(b, a)

# 将幅值转换为dB
h_dB = 20 * np.log10(abs(h))

# 绘制幅值响应
plt.figure()
plt.subplot(2, 1, 1)
plt.plot(w / np.pi, h_dB)
plt.title('Frequency Response')
plt.xlabel('Normalized Frequency (×π rad/sample)')
plt.ylabel('Magnitude (dB)')
plt.grid()

# 绘制相位响应
h_Phase = np.unwrap(np.angle(h))
plt.subplot(2, 1, 2)
plt.plot(w / np.pi, h_Phase)
plt.xlabel('Normalized Frequency (×π rad/sample)')
plt.ylabel('Phase (radians)')
plt.grid()
plt.show()

