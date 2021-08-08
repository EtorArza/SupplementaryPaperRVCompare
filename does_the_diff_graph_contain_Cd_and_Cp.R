library("RVCompare")
library("stats")

N_examples = 6
nSamples = 4000
nOfBootstrapSamples = 1e3


df <- data.frame(
  Cd_from_dist=numeric(),
  Cd_from_plot_estimation=numeric(),
  Cd_from_plot_lower=numeric(),
  Cd_from_plot_upper=numeric(),
  Cp_from_dist=numeric(),
  Cp_from_plot_estimation=numeric(),
  Cp_from_plot_lower=numeric(),
  Cp_from_plot_upper=numeric()
                 )




for (i in 1:N_examples) {
  print(paste("--- Example", toString(i), "---"))


  if (i==1)
  {
    w1 <- 45 / (45 + 47)
    w2 <- 47 / (45 + 47)
    densityA <- mixtureDensity(c(normalDensity(0.05,0.00125), normalDensity(0.07, 0.00125)), weights = c(w1, w2))
    densityB <- mixtureDensity(c(normalDensity(0.06,0.00125), normalDensity(0.08, 0.00125)), weights = c(w2, w1))
    xlims <- c(0.04, 0.09)
  }
  else if(i==2)
  {
    densityA <- normalDensity(0.211325,0.002)
    densityB <- mixtureDensity(c(normalDensity(0.21875,0.002), normalDensity(0.04875, 0.002)), weights = c(0.925, 0.075))
    xlims <- c(0.0, 0.3)
  }
  else if(i==3)
  {
    densityA <- normalDensity(0.3,0.05)
    densityB <- normalDensity(0.32,0.05)
    xlims <- c(0.0, 0.6)
  }
  else if(i==4)
  {
    densityA <- mixtureDensity(c(normalDensity(0.3,0.025), normalDensity(0.1, 0.0025)), weights = c(0.95, 0.05))
    densityB <- mixtureDensity(c(normalDensity(0.3,0.025), normalDensity(0.15, 0.0025)), weights = c(0.95, 0.05))
    xlims <- c(0.05, 0.45)
  }
  else if(i==5)
  {
    xlims <- c(0, 16)
    densityA <- function(x) stats::dchisq(x, 2)
    densityB <- normalDensity(4, 1)
  }
  else if(i==6)
  {
    xlims <- c(0, 8)
    densityA <- function(x) stats::dgamma(x, shape =2, scale = 0.5)
    densityB <- function(x) stats::dunif(x, min =1, max = 3)
  }

  cat("Computing samples...")
  samplesA <- sampleFromDensity(densityA, nSamples, xlims, nIntervals = 1e5)
  cat("...")
  samplesB <- sampleFromDensity(densityB, nSamples, xlims, nIntervals = 1e5)
  cat("done!\n")

  cat("Computing Cd...")
  Cd <- CdFromDensities(densityA, densityB, xlims)
  cat("Cp...")
  Cp <- CpFromDensities(densityA, densityB, xlims)
  cat("done!\n")

  estimated_X_prima_AB_bounds <- get_X_prima_AB_bounds_bootstrap(samplesA, samplesB, alpha = 0.05, nOfBootstrapSamples = nOfBootstrapSamples)

  diff_estimation <- estimated_X_prima_AB_bounds$X_prima_A_cumulative_estimation - estimated_X_prima_AB_bounds$X_prima_B_cumulative_estimation
  diff_upper <- estimated_X_prima_AB_bounds$X_prima_A_cumulative_upper - estimated_X_prima_AB_bounds$X_prima_B_cumulative_lower
  diff_lower <- estimated_X_prima_AB_bounds$X_prima_A_cumulative_lower - estimated_X_prima_AB_bounds$X_prima_B_cumulative_upper
  p <- estimated_X_prima_AB_bounds$p

  Cd_from_plot_estimation <- mean(diff_estimation[2:(length(diff_estimation)-1)] > 0)
  Cd_from_plot_lower <- mean(diff_lower[2:(length(diff_estimation)-1)] > 0)
  Cd_from_plot_upper <- mean(diff_upper[2:(length(diff_estimation)-1)] > 0)
  Cp_from_plot_estimation <- mean(diff_estimation) + 0.5
  Cp_from_plot_lower <- mean(diff_lower) + 0.5
  Cp_from_plot_upper <- mean(diff_upper) + 0.5
  
  
  cat("\n")
  cat("Cd = ", Cd, " ~ proportion where positive = ", Cd_from_plot_estimation, "in (", Cd_from_plot_lower, ", ", Cd_from_plot_upper, ")", "\n")
  cat("Cp = ", Cp, " ~ integral + 0.5  = ", Cp_from_plot_estimation, "in (", Cp_from_plot_lower, ", ", Cp_from_plot_upper, ")", "\n")

  print("------------------")
  
  df[nrow(df) + 1,] = c(Cd, Cd_from_plot_estimation, Cd_from_plot_lower, Cd_from_plot_upper, Cp, Cp_from_plot_estimation, Cp_from_plot_lower, Cp_from_plot_upper)
  
}

print(df)

write.csv(df, "results_does_the_diff_graph_contain_Cd_and_Cp.csv")



