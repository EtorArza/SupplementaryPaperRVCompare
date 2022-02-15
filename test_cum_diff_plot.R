source("~/Dropbox/BCAM/06_comparing_optimization_algorithms/RVCompare/R/RVCompare.R")

f1 <- c(1,2,3,4)
f2 <- c(2,3,2,3)



ranksObj <- ranksOfObserved(f1, f2)
print(ranksObj$rank_interval_multA)

density_Y_A <- helper_from_ranks_to_integrable_values(ranksObj$rank_interval_multA, j_max = 200, cumulative = FALSE)

print(density_Y_A)

print(helperTrapezoidRule(density_Y_A))


print(ranksObj)


estimated_Y_AB_bounds <- get_Y_AB_bounds_bootstrap(f1, f2, alpha = 0.1, nOfBootstrapSamples = 1e4, ignoreMinimumLengthCheck = TRUE)
plot_Y_AB(estimated_Y_AB_bounds)


