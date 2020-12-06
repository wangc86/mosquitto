# This example is derived from the following webpage:
# https://matplotlib.org/3.1.1/gallery/statistics/histogram_cumulative.html

import numpy as np
import matplotlib.pyplot as plt

fig, ax1 = plt.subplots()
#fig.subplots_adjust(hspace=0.4)

#### First, plot the empirical result
y = np.loadtxt('c:/Users/Chao Wang/code/n.log')
ax1.plot(y, color='g', ls='-',marker="o")

#ax1.set_xlim(-0.005, 4.0)
ax1.set_xlabel('Series of data (labelled in time order)')
ax1.set_ylabel('Number of messages seen in the flight structure')
ax1.set_title('Number of messages seen by a message arrival.')
#ax1.legend(loc=4)

plt.show()
#plt.savefig('./cdf.pdf')