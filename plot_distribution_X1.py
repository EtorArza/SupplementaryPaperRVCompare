import pandas as pd
from matplotlib import pyplot as plt
import numpy as np
from scipy import stats 
from sklearn.neighbors import KernelDensity




# plot distribution of X_A, X_B

fig, ax = plt.subplots(1, 1)
fig.set_size_inches(5, 2)


x_min = 1e20
x_max = -1e20
y_max = -1e20

for i in range(2):
    x_suffix = ("A","B")[i]
    df = pd.read_csv(f'data/scores{x_suffix}.csv', header=None)
    x_min = min(x_min, df.min().min())
    x_max = max(x_max, df.max().max())

for i in range(2):
    x_suffix = ("A","B")[i]
    df = pd.read_csv(f'data/scores{x_suffix}.csv', header=None)

    


    array = np.array((df.iloc[:,0]))
    band_width = 0.0005 #(max(array) - min(array)) / nbins_diaconis

    print(f"Band size: {band_width}")


    X_plot = np.linspace(x_min, x_max, 10000)[:, np.newaxis]


    array = array[~np.isnan(array)]
 
    kde = KernelDensity(kernel='tophat', bandwidth=band_width).fit(array[:, np.newaxis])
    Y_plot = np.exp(kde.score_samples(X_plot))
    y_max = max(Y_plot.max().max(), y_max)


    #ax.hist(array, bins=n_bins_freedman_diaconis(array), density=False, rwidth=0.93,  color='grey', edgecolor='white')
    ax.plot(X_plot, Y_plot, label = ["$X_A$: adam optimizer", "$X_B$: RMSProp optimizer"][i])
    ax.fill(X_plot, Y_plot, alpha = 0.2)


    props = dict(boxstyle='round', facecolor='white', alpha=0.25)
    # ax.text(0.95, 0.95, f"$n = {len(array)}$",  color='grey',  transform=ax.transAxes,  verticalalignment='top', horizontalalignment='right', bbox=props)


# # plot kernel size
# ax.text(0.95, 0.95, "Kernel size",  color='grey',  transform=ax.transAxes,  verticalalignment='top', horizontalalignment='right', bbox=props)
# print(np.array([band_width/2]) + x_min + 0.9 * (x_max - x_min))
# ax.plot(np.array([-band_width/2,-band_width/2,-band_width/2,band_width/2,band_width/2,band_width/2]) + x_min + 0.91 * (x_max - x_min), np.array([y_max*0.81, y_max*0.79, y_max*0.80, y_max*0.80, y_max*0.81,y_max*0.79]), color = 'grey', lw=1.5)

plt.tight_layout()
plt.subplots_adjust(left=0.12)

plt.xlabel("error rate in the test set")
plt.ylabel("Probability density")
plt.legend(loc = "center right")

plt.savefig('figures/X1_dist.pdf')
plt.savefig('../paper/images/X1_dist.pdf')

