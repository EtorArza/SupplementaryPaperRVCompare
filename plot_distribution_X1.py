import pandas as pd
from matplotlib import pyplot as plt
import numpy as np
from scipy import stats 


# https://en.wikipedia.org/wiki/Freedman%E2%80%93Diaconis_rule
def n_bins_freedman_diaconis(array_x):
    IQR = stats.iqr(array_x, interpolation = 'midpoint') 
    res = 2.0 / float(len(array_x))**(1.0 / 3.0) * IQR
    

    return int( (max(array_x) - min(array_x)) / res )







# plot distribution of X_1

df = pd.read_csv('data/scores_old.csv', header=None)
array = np.array((df.iloc[:,0]))
print("The fiure has", n_bins_freedman_diaconis(array), "bins.")

fig, ax  = plt.subplots()

ax.hist(array, bins=n_bins_freedman_diaconis(array), density=True, rwidth=0.95)

props = dict(boxstyle='round', facecolor='white', alpha=0.25)
ax.text(0.95, 0.95, f"$n = {len(array)}$",  color='grey',  transform=ax.transAxes,  verticalalignment='top', horizontalalignment='right', bbox=props)
plt.xlabel("Error rate")
plt.ylabel("Probability density")

plt.savefig('figures/X1_dist.pdf')
plt.savefig('../paper/images/X1_dist.pdf')

