# This example is derived from the following webpage:
# https://matplotlib.org/3.1.1/gallery/statistics/histogram_cumulative.html

import numpy as np
import matplotlib.pyplot as plt

#fig1, ax = plt.subplots()

fig, (ax1, ax2) = plt.subplots(2, 1)
fig.subplots_adjust(hspace=0.4)

#### First, plot the empirical result
y = np.loadtxt('c:/Users/Chao Wang/code/inter-arrival_time.out10N')
n_bins = len(y)-1
n, bins, patches = ax1.hist(y, n_bins, density=True, histtype='step',
          cumulative=True, label='Empirical result', color='g')
# the following line is used to remove the last point
patches[0].set_xy(patches[0].get_xy()[:-1])
ax1.set_xlim(-0.005, 4.0)
ax1.set_xlabel('Inter-arrival time (second)')
ax1.set_ylabel('Probability')
ax1.set_title('Cumulative Distribution Function (N=100)')
ax1.legend(loc=4)

#### Then plot the theoretical expontential distribution
G = np.random.default_rng()
y = G.exponential(scale=0.55, size=898)
# Now, plot the cumulative distributioin function (CDF)
n_bins = len(y)-1
n, bins, patches = ax2.hist(y, n_bins, density=True, histtype='step',
          cumulative=True, label='Exponential distribution', color='b')
# the following line is used to remove the last point
patches[0].set_xy(patches[0].get_xy()[:-1])
ax2.set_xlim(-0.005, 4.0)
ax2.set_xlabel('Inter-arrival time (second)')
ax2.set_ylabel('Probability')
#ax2.set_title('Cumulative Distribution Function (N=100)')
ax2.legend(loc=4)

plt.show()
#plt.savefig('./cdf.pdf')