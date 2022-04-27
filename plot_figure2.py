import pandas as pd
from matplotlib import pyplot as plt
import numpy as np
from scipy import stats 

# matplotlib.rcParams['mathtext.fontset'] = 'custom'
# matplotlib.rcParams['mathtext.rm'] = 'Bitstream Vera Sans'
# matplotlib.rcParams['mathtext.it'] = 'Bitstream Vera Sans:italic'
# matplotlib.rcParams['mathtext.bf'] = 'Bitstream Vera Sans:bold'
# matplotlib.rcParams['mathtext.fontset'] = 'stix'
# matplotlib.rcParams['font.family'] = 'STIXGeneral'



# https://en.wikipedia.org/wiki/Freedman%E2%80%93Diaconis_rule
def n_bins_freedman_diaconis(array_x):
    IQR = stats.iqr(array_x, interpolation = 'midpoint') 
    res = 2.0 / float(len(array_x))**(1.0 / 3.0) * IQR
    

    return int( (max(array_x) - min(array_x)) / res )







# plot distribution of X_1


fig, (ax1, ax2) = plt.subplots(2, 1, sharex=True, sharey=True)
fig.set_size_inches(4, 3)      


for i, ax in enumerate((ax1, ax2)):

    n = 100000000

    if i == 0:
        df = pd.DataFrame(np.append(np.random.normal(loc = 0.021, scale = 0.002, size = int(n*0.925)),np.random.normal(loc =0.01, scale = 0.0025, size = int(n*0.075)))+0.0005- 0.000175)
    else:
        df = pd.DataFrame(np.append(np.random.normal(loc = 0.02-0.00125, scale = 0.002, size = int(n*0.975)),np.random.normal(loc = 0.07-0.00125, scale = 0.001, size = int(n*0.025))))

    average = df.mean().mean()
    print("Mean -> ", average)
    array = np.array((df.iloc[:,0]))
    print("The fiure has", n_bins_freedman_diaconis(array), "bins.")


    ax.hist(array, bins=n_bins_freedman_diaconis(array) // 20, density=True, rwidth=1.0, color='silver', edgecolor='silver')


    #props = dict(boxstyle='round', facecolor='white', alpha=0.25)
    #ax.text(0.95, 0.95, "$n = {:.0e}$".format(len(array)),  color='grey',  transform=ax.transAxes,  verticalalignment='top', horizontalalignment='right', bbox=props)
    ax.text(0.95, 0.55, f"$X_{'A' if i==0 else 'B'}$",  color='black',  transform=ax.transAxes,  verticalalignment='top', horizontalalignment='right', )#bbox=props)
    ax.axvline(average, color = 'black', ls='--', lw = 0.85, label=r"Expected value")
    plt.xlabel("x")

ax1.legend(bbox_to_anchor=(0,1.08,1,0.2), loc="lower left", mode="expand", borderaxespad=0, ncol=3)

plt.tight_layout()
plt.savefig('figures/fig2.pdf')
