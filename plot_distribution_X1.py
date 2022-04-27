from traceback import print_tb
from turtle import position
import pandas as pd
from matplotlib import pyplot as plt
import numpy as np
from scipy import stats 
from sklearn.neighbors import KernelDensity
import matplotlib
matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42

# matplotlib.rcParams.update({'font.size': 20})


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

plt.xlabel("Error rate in the test set")
plt.ylabel("Probability density")
plt.legend(loc = "center right")

plt.savefig('figures/figure1.pdf')
plt.close()



for N in [10, 20, 100, 1000, 12000]:
    

    fig, ax = plt.subplots(1, 1)
    arrays  = []
    for i in range(2):
        x_suffix = ("A","B")[i]
        df = pd.read_csv(f'data/scores{x_suffix}.csv', header=None)
        array = np.array((df.iloc[:,0]))
        array = array[~np.isnan(array)]
        array = array[100:(100+N)]
        arrays.append(array)

    print(arrays)
    print("--------------")
    ax.boxplot(arrays, labels=["ADAM", "RMSProp"])

    ax.text(0.05,0.95,f'$n = {N}$',horizontalalignment='left', verticalalignment='top', transform = ax.transAxes)
    plt.tight_layout()
    plt.subplots_adjust(left=0.14, bottom=0.07)
    plt.xlabel("Algorithm")
    plt.ylabel("Error rate in the test set")

    plt.savefig(f'figures/X1_boxplot_{N}_points.pdf')
 
    plt.close()


    fig, ax = plt.subplots(1, 1)
    bins = np.linspace(0.23, 0.35, 30)
    ax.hist(arrays, label=["ADAM", "RMSProp"])

    # ax.text(0.05,0.95,f'$n = {N}$',horizontalalignment='left', verticalalignment='top', transform = ax.transAxes)
    plt.tight_layout()
    plt.legend()
    plt.subplots_adjust(left=0.16, bottom=0.15)
    plt.xlabel("Error rate in the test set")
    plt.ylabel("Count")

    plt.savefig(f'figures/X1_hist_{N}_points.pdf')

    plt.close()
