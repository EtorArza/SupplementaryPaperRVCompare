library(RVCompare)


samplesA <- c(1,2,2,2,2,3,3,3,3,3)
samplesB <- c(1,2,2,4,5,6,7,8,9,9)


C2n <- sort(c(samplesA,samplesB))
C2n_unique <- unique(C2n)


if(length(samplesA) == length(samplesB))
{

  n <- length(samplesA)




  ###################################################

  cat("Computing Cp from estimator")
  Cp_estimation_summation1 <- 0
  Cp_estimation_summation2 <- 0
  for (i in 1:length(samplesA)) {
    for (k in 1:length(samplesA)) {
      Cp_estimation_summation1 <- Cp_estimation_summation1 + sign(samplesB[[k]] - samplesA[[i]]) / (2*n*n)
    }
  }
  first_estimation_Cp <- Cp_estimation_summation1 + 0.5

Cp_estimation_22_summation1 <- 0
Cp_estimation_22_summation2 <- 0

 for (c in C2n) {
   Cp_estimation_22_summation1 <- Cp_estimation_22_summation1 + (sum(samplesA < c) - sum(samplesB < c))/(2*n^2)
 }

 for (c in C2n) {
   Cp_estimation_22_summation2 <- Cp_estimation_22_summation2 + (sum(samplesA == c) - sum(samplesB == c))/2/(2*n^2)
 }

second_estimation_Cp <- 0.5 + Cp_estimation_22_summation1 + Cp_estimation_22_summation2


  ###################################################


  estimated_Y_AB_bounds <- get_Y_AB_bounds_bootstrap(samplesA, samplesB, alpha = 0.05, nOfBootstrapSamples = 1e3, ignoreMinimumLengthCheck = TRUE)



  diff_estimation <- estimated_Y_AB_bounds$Y_A_cumulative_estimation - estimated_Y_AB_bounds$Y_B_cumulative_estimation
  diff_upper <- estimated_Y_AB_bounds$Y_A_cumulative_upper - estimated_Y_AB_bounds$Y_B_cumulative_lower
  diff_lower <- estimated_Y_AB_bounds$Y_A_cumulative_lower - estimated_Y_AB_bounds$Y_B_cumulative_upper
  p <- estimated_Y_AB_bounds$p



  cat("\n")
  # cat("Cd =  ~ proportion where positive = ", mean(diff_estimation[2:(length(diff_estimation)-1)] > 0), "in (", mean(diff_lower[2:(length(diff_estimation)-1)] > 0), ", ", mean(diff_upper[2:(length(diff_estimation)-1)] > 0), ")", "\n")
  cat("Cp =  ~ integral + 0.5  = ", mean(diff_estimation) + 0.5, "in (",  mean(diff_lower) + 0.5, ", ", mean(diff_upper) + 0.5, ")", "\n")
  cat("Cp from Cp_estimation_first -> ",  first_estimation_Cp , "\n")
  cat("Cp from Cp_estimation_second -> ", second_estimation_Cp  , "\n")




  plot_Y_AB(estimated_Y_AB_bounds, plotDifference=TRUE)
}

