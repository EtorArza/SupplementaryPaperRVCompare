import pandas as pd
from matplotlib import pyplot as plt
import numpy as np
from scipy import stats 
import matplotlib.style as style
import matplotlib
from tqdm import tqdm as tqdm
import math
from decimal import *

# "--- Example 1 ---"
# estimated Cd =  0.618370116120446
# "--- Example 2 ---"
# estimated Cd =  0.719603383576358
# "--- Example 3 ---"
# estimated Cd =  0.586496322178725
# "--- Example 4 ---"
# estimated Cd =  0.507432634261749

# matplotlib.rcParams['mathtext.fontset'] = 'custom'
# matplotlib.rcParams['mathtext.rm'] = 'Bitstream Vera Sans'
# matplotlib.rcParams['mathtext.it'] = 'Bitstream Vera Sans:italic'
# matplotlib.rcParams['mathtext.bf'] = 'Bitstream Vera Sans:bold'
# matplotlib.rcParams['mathtext.fontset'] = 'stix'
# matplotlib.rcParams['font.family'] = 'STIXGeneral'


target_error = 5e-5
COMPUTE_PROB = False

# https://en.wikipedia.org/wiki/Freedman%E2%80%93Diaconis_rule
def n_bins_freedman_diaconis(array_x):
    IQR = stats.iqr(array_x, interpolation = 'midpoint') 
    res = 2.0 / float(len(array_x))**(1.0 / 3.0) * IQR
    

    return int( (max(array_x) - min(array_x)) / res )



def estimate_prob_X_le_Y(X,Y):

    last_prob = -1
    new_prob = -2
    total = 0
    x_le_y = 0
    error_is_ok_times = 0
    while total == 0 or error_is_ok_times < 5:
        np.random.shuffle(X)
        np.random.shuffle(Y)
        if abs(last_prob - new_prob) > target_error:
            error_is_ok_times = 0
        else:
            error_is_ok_times+= 1
        print(x_le_y / max(1,total), end=",")
        #print("{:.2E}".format(new_prob - last_prob), end=",", flush=True)
        last_prob = new_prob

        x_le_y+=  ((np.sign(Y-X) + 1 )/ 2).sum() # X lower than Y -> Y - X is positive
        total += len(X)
        new_prob = x_le_y / total
    
    return new_prob, target_error

def get_x_and_Gx_of_cumulative_distribuition(array):
    N_POINTS = 100000
    array_sorted = np.sort(array)
    n = len(array)
    cum_prob = np.linspace(1/N_POINTS,1, num=N_POINTS)
    values = np.zeros_like(cum_prob)

    for i in range(0, N_POINTS):
        values[i] = array_sorted[round(i * n / N_POINTS)]
    return cum_prob, values


def get_indicator_integral_F_A_comp_F_B(X_A_observed, X_B_observed, nbins, comparison_operator="<"):
    
    EPSILON = 0.01
    
    x_min = min((min(X_A_observed), min(X_B_observed)))
    x_max = max((max(X_A_observed), max(X_B_observed)))



    assert len(X_A_observed) == len(X_B_observed)
    n = len(X_B_observed)


    X_A_observed = np.sort(X_A_observed)
    X_B_observed = np.sort(X_B_observed)

    last_x = None
    i = -1
    res = Decimal(0)

    cases_condition_true = 0
    bin_len = (nbins - 1) / (x_max - x_min)

    F_A_x = 0
    F_B_x = 0

    for x in tqdm(np.linspace(x_min, x_max, nbins)):
        if last_x == None:
            last_x = x
            continue
        i+= 1
        
        F_A_x = len(X_A_observed[X_A_observed <= x]) / n
        F_B_x = len(X_B_observed[X_B_observed <= x]) / n

        if comparison_operator == "<":
            if F_A_x - F_B_x < -EPSILON:
                cases_condition_true += 1
        elif comparison_operator == "=":
            if abs(F_A_x - F_B_x) < EPSILON:
                cases_condition_true += 1
        elif comparison_operator == ">":
            if F_A_x - F_B_x > EPSILON:
                cases_condition_true += 1
        else:
            print(f"ERROR: Operator {comparison_operator} is not valid.")
            raise ArithmeticError
    return cases_condition_true * bin_length




def f_divergence(X_A_observed, X_B_observed, f, nbins):

    print("WARNING: this does not work, and wolfram mathematica was used instead, to avoid wasting time fiddling with numerical errors.")
    raise ValueError
    x_min = min((min(X_A_observed), min(X_B_observed)))
    x_max = max((max(X_A_observed), max(X_B_observed)))

    getcontext().prec = 200


    assert len(X_A_observed) == len(X_B_observed)
    n = len(X_B_observed)


    X_A_observed = np.sort(X_A_observed)
    X_B_observed = np.sort(X_B_observed)

    last_x = None
    i = -1
    res = Decimal(0)
    for x in tqdm(np.linspace(x_min, x_max, nbins)):
        if last_x == None:
            last_x = x
            continue
        i+= 1

        if i == 0:
            g_A = len(X_A_observed[(X_A_observed >= last_x) & (X_A_observed <= x)]) / n
            g_B = len(X_B_observed[(X_B_observed >= last_x) & (X_B_observed <= x)]) / n
        else:
            g_A = len(X_A_observed[(X_A_observed >= last_x) & (X_A_observed <= x)]) / n
            g_B = len(X_B_observed[(X_B_observed >= last_x) & (X_B_observed <= x)]) / n

        if g_B == 0 and g_A == 0:
            res += 0
            continue

        elif g_B == 0:
            g_B = 1e-100

        elif g_A == 0:
            g_A = 1e-100

        assert g_A / g_B >= 0
        g_A = Decimal(g_A)
        g_B = Decimal(g_B)

        integrand_i = Decimal(g_B * f(g_A / g_B)) 
        res += round(integrand_i, ndigits=90) * Decimal(x - last_x)


    print(res)
    assert res > 0
    return float(res)



        
    


for example_idx in (0,1,2, 3):
    print("-------------")
    print("EXAMPLE",example_idx+1)
    print("-------------")
    fig, (ax1, ax2) = plt.subplots(2, 1, sharex=True, sharey=True)
    fig.set_size_inches(4, 3)      

    avgs = []
    medians = []
    array_list = []
    for i, ax in enumerate((ax1, ax2)):
        n = 10000000


        if example_idx == 0:
            bin_length = 0.00005
            if i == 0: #Classifier A
                df = pd.DataFrame(np.append(np.random.normal(loc = 0.05, scale = 0.00125, size = int(n*0.45)),np.random.normal(loc =0.07, scale = 0.00125, size = int(n*0.47))))
            else: #Classifier B
                df = pd.DataFrame(np.append(np.random.normal(loc = 0.06, scale = 0.00125, size = int(n*0.47)),np.random.normal(loc =0.08, scale = 0.00125, size = int(n*0.45))))

        elif example_idx == 1:
            bin_length = 0.00005
            if i == 0: #Classifier A
                df = pd.DataFrame(np.random.normal(loc = 0.211325, scale = 0.002, size = n))
            else: #Classifier B
                df = pd.DataFrame(abs(np.append(np.random.normal(loc = 0.21875, scale = 0.002, size = int(n*0.925)),np.random.normal(loc = 0.04875, scale = 0.002, size = int(n*0.075)))))
        
        elif example_idx == 2:
            bin_length = 0.0004
            if i == 0: #Classifier A
                df = pd.DataFrame(np.random.normal(loc = 0.30, scale = 0.05, size = n))
            else: #Classifier B
                df = pd.DataFrame(np.random.normal(loc = 0.32, scale = 0.05, size = n))

        elif example_idx == 3:
            bin_length = 0.0004
            if i == 0: #Classifier A
                df = pd.DataFrame(np.append(np.random.normal(loc = 0.30, scale = 0.025, size = int(n*0.95)),np.random.normal(loc =0.10, scale = 0.0025, size = int(n*0.05))))
            else: #Classifier B
                df = pd.DataFrame(np.append(np.random.normal(loc = 0.30, scale = 0.025, size = int(n*0.95)),np.random.normal(loc =0.15, scale = 0.0025, size = int(n*0.05))))



        array = np.array((df.iloc[:,0]))
        array_list.append(array)
        avgs.append(df.mean().mean())
        medians.append(np.median(array))
        print("-----")
        print("Average -> ", avgs[i])
        print("Median -> ", medians[i])
        print("The fiure would have according to freedman_diaconis", n_bins_freedman_diaconis(array), "bins.")

        n_steps_line = 10
        nbins = int((max(array)-min(array)) / bin_length)
        ax.hist(array, bins=nbins, density=True, rwidth=1.0, color='silver', edgecolor='silver')

        ax.text(0.95 if example_idx == 0 or example_idx==2 else 0.2, 0.55, f"$X_{'A' if i==0 else 'B'}$",  color='black',  transform=ax.transAxes,  verticalalignment='top', horizontalalignment='right',)



    for i, ax in enumerate((ax1, ax2)):
        y_lim = max(ax1.get_ylim(),ax2.get_ylim())
        linewidth = 0.75
        ax.plot([avgs[i]]*n_steps_line,np.linspace(0,y_lim, n_steps_line),   ls='--', fillstyle="none", lw = linewidth, label=r"Expected value", color = 'black')
        ax.plot([medians[i]]*n_steps_line,np.linspace(0,y_lim,n_steps_line),  ls='-', fillstyle="none", lw = linewidth, label=r"Median", color = 'black')
        ax.set_ylim(y_lim)
        plt.gca().set_prop_cycle(None)



    plt.xlabel("$x$")
    plt.ylabel("                                Probability density")

    handles, labels = plt.gca().get_legend_handles_labels()
    by_label = dict(zip(labels, handles))
    ax1.legend(by_label.values(), by_label.keys(),bbox_to_anchor=(0,1.08,1,0.2), loc="lower left", mode="expand", borderaxespad=0, ncol=3, framealpha=1.0, )

    plt.tight_layout()
    plt.savefig(f'figures/example_{example_idx+1}_mean_median_prob_better.pdf')
    plt.savefig(f'../paper/images/example_{example_idx+1}_mean_median_prob_better.pdf')
    plt.close()


    if COMPUTE_PROB: 
        estimation, error = estimate_prob_X_le_Y(array_list[0], array_list[1])
        print("\nP(X_A < X_B) =", estimation, " in ", (estimation-error, estimation+error))
        print("P_C(X_A,X_B) =", estimation*2 -1)
        print("indicator F_X_A > F_X_B =", get_indicator_integral_F_A_comp_F_B(array_list[0],array_list[1],nbins, ">"))
        print("indicator F_X_A < F_X_B =", get_indicator_integral_F_A_comp_F_B(array_list[0],array_list[1],nbins, "<"))
        # print("KL-div: ", f_divergence(array_list[0], array_list[1], lambda x: Decimal(x) * (x.ln()), nbins=nbins))
        # print("JS-div: ", f_divergence(array_list[0], array_list[1], lambda x: Decimal(x) * (Decimal(2)*Decimal(x) / Decimal(x + 1)).ln() + (Decimal(2) / Decimal(x + Decimal(1))).ln(), nbins=nbins))
        # print("TotalVariation-div: ", f_divergence(array_list[0], array_list[1], lambda x: Decimal(0.5) * abs(x-Decimal(1)), nbins=nbins))
        # print("Helligner-dist: ", math.sqrt(f_divergence(array_list[0], array_list[1], lambda x: Decimal(x) - Decimal(2)*(x.sqrt()) + Decimal(1), nbins=nbins))) # x - 2*math.sqrt(x) + 1 = (1 + sqrt x)^2

    for i, array in enumerate(array_list):
        cum_prob, error_rate_upper_bound = get_x_and_Gx_of_cumulative_distribuition(array)

        # Make sure that both X_A and X_B have the same domain, and therefore, lengthen their domain to enforce this
        cum_prob = np.concatenate((np.array([0]), cum_prob, np.array([1])), axis=0)
        error_rate_upper_bound = np.concatenate((
            np.array([min(min(array_list[0]),min(array_list[1]))]),
            error_rate_upper_bound,
            np.array([max(max(array_list[0]),max(array_list[1]))])
        ), axis=0)

        plt.plot(error_rate_upper_bound, cum_prob, label=f"X_{'A' if i==0 else 'B'}", alpha = 0.35, marker="x" if i==0 else "o", markevery=0.15, fillstyle="none", markersize = 5, )

    # get optimal cumulative distribution
    cum_prob, error_rate_upper_bound = get_x_and_Gx_of_cumulative_distribuition(array_list[0])[0], np.minimum(get_x_and_Gx_of_cumulative_distribuition(array_list[0])[1], get_x_and_Gx_of_cumulative_distribuition(array_list[1])[1])

    # Also need to lengthen the domain of the optimal cumulative distribution
    cum_prob = np.concatenate((np.array([0]), cum_prob, np.array([1])), axis=0)
    error_rate_upper_bound = np.concatenate((
        np.array([min(min(array_list[0]),min(array_list[1]))]),
        error_rate_upper_bound,
        np.array([max(max(array_list[0]),max(array_list[1]))])
    ), axis=0)


    # # Get the pareto front
    # plt.plot(error_rate_upper_bound, cum_prob, color='black', ls=":", linewidth =0.75, label=r"$\max(G_A(x),G_B(x))$")
    left_xlim, right_xlim = plt.xlim()  # return the current xlim
    linewidth = 0.75
    plt.plot([left_xlim, right_xlim],[0.5,0.5], lw = linewidth, label=r"Median", ls="-")
    plt.plot([left_xlim, right_xlim],[0.05,0.05], lw = linewidth, label=r"Best 5%", ls="--")
    plt.plot([left_xlim, right_xlim],[0.95,0.95], lw = linewidth, label=r"Worst 5%", ls="-.")

    plt.xlim((left_xlim, right_xlim))   # set the xlim to left, right

    plt.xlabel(r"$x$")
    plt.ylabel("cumulative probablity")
    #plt.gca().invert_yaxis()
    fig = matplotlib.pyplot.gcf()
    if example_idx==0:
        plt.legend(bbox_to_anchor=(0,1.08,1,0.2), loc="lower left", mode="expand", borderaxespad=0, ncol=3)
        fig.set_size_inches(4, 2.5)
    else:
        fig.set_size_inches(4, 1.9)      
    plt.tight_layout()
    plt.savefig(f'figures/example_{example_idx+1}_pareto.pdf')
    plt.savefig(f'../paper/images/example_{example_idx+1}_pareto.pdf')

    plt.close()

