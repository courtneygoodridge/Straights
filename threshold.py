# -*- coding: utf-8 -*-
"""
Created on Mon Aug  5 15:54:44 2019

@author: pscmgo
"""

import numpy as np
import matplotlib.pyplot as plt

speed = 10
ts = 100
step = 0.1
thresh = 1
distance = ts * 10
np.arange(0, 100, step)

heading = 0.5

x = np.sin(heading * distance)
y = np.cos(heading)

plt.plot(x, y)
plt.show()

