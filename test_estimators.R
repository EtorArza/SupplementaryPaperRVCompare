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


  for (unique_c in C2n_unique) {
    Cp_estimation_summation2 <- Cp_estimation_summation2 + (sum(samplesA == unique_c)^2 - sum(samplesB == unique_c)^2)/(4*n*n)
  }


  cat("Computing Cd from estimator (not implemented yet)")
  cat("done!\n")




###################################################

  cat("Computing Cp from middle step page 22")
  Cp_estimation_22 <- 0.5
  Cp_estimation_22_summation1 <- 0
  Cp_estimation_22_summation2 <- 0

  for (c in C2n) {
    Cp_estimation_22_summation1 <- Cp_estimation_22_summation1 + (sum(samplesA < c) - sum(samplesB < c))/(2*n^2)
  }

  for (c in C2n) {
    Cp_estimation_22_summation2 <- Cp_estimation_22_summation2 + (sum(samplesA == c) - sum(samplesB == c))/2/(2*n^2)
  }

  ###################################################


  cat("Computing Cp from beta estimator")
  Cp_estimation_beta_sumation1 <- 0
  Cp_estimation_beta_sumation2 <- 0
  Cp_estimation_beta_sumation3 <- 0

  for (i in 1:length(samplesA)) {
    for (k in 1:length(samplesA)) {
      Cp_estimation_beta_sumation1 <- Cp_estimation_beta_sumation1 + sign(samplesB[[k]] - samplesA[[i]]) / (2*n^2)
    }
  }

  for (k in 1:length(samplesA)) {
    Cp_estimation_beta_sumation2 <- Cp_estimation_beta_sumation2 + (sum(samplesA < samplesA[[k]]) - sum(samplesB < samplesB[[k]])) / (2*n^2)
    Cp_estimation_beta_sumation3 <- Cp_estimation_beta_sumation3 +
      (
      sum(samplesA == samplesA[[k]]) -
      sum(samplesB == samplesA[[k]]) +
      sum(samplesA == samplesB[[k]]) -
      sum(samplesB == samplesB[[k]])
      ) / (4*n^2)
  }



  ###################################################



  cat("Computing Cp from gamma estimator")
  Cp_estimation_gamma_sumation1 <- 0
  Cp_estimation_gamma_sumation2 <- 0
  Cp_estimation_gamma_sumation3 <- 0

  for (i in 1:length(samplesA)) {
    for (k in 1:length(samplesA)) {
      Cp_estimation_gamma_sumation1 <- Cp_estimation_gamma_sumation1 + sign(samplesB[[k]] - samplesA[[i]]) / (2*n^2)
    }
  }

  for (k in 1:length(samplesA)) {
    Cp_estimation_gamma_sumation2 <- Cp_estimation_gamma_sumation2 + (sum(samplesA <= samplesA[[k]]) - sum(samplesB <= samplesB[[k]])) / (2*n^2)
    Cp_estimation_gamma_sumation3 <- Cp_estimation_gamma_sumation3 +
      (
          - sum(C2n == samplesA[[k]]) +
          sum(C2n == samplesB[[k]])
      ) / (4*n^2)
  }







  ###################################################



  cat("Computing Cp from delta estimator")
  Cp_estimation_delta_sumation1 <- 0
  Cp_estimation_delta_sumation2 <- 0
  Cp_estimation_delta_sumation3 <- 0

  for (i in 1:length(samplesA)) {
    for (k in 1:length(samplesA)) {
      Cp_estimation_delta_sumation1 <- Cp_estimation_delta_sumation1 + sign(samplesB[[k]] - samplesA[[i]]) / (2*n^2)
    }
  }

  for (k in 1:length(C2n_unique)) {
    Cp_estimation_delta_sumation2 <- Cp_estimation_delta_sumation2 + (sum(samplesA == C2n_unique[[k]])^2 - sum(samplesB == C2n_unique[[k]])^2) / (2*n^2)
  }
  for (k in 1:length(samplesA)) {
    Cp_estimation_delta_sumation3 <- Cp_estimation_delta_sumation3 +
      (
        - sum(C2n == samplesA[[k]]) +
          sum(C2n == samplesB[[k]])
      ) / (4*n^2)
  }



  ###################################################










  estimated_Y_AB_bounds <- get_Y_AB_bounds_bootstrap(samplesA, samplesB, alpha = 0.05, nOfBootstrapSamples = 1e3, ignoreMinimumLengthCheck = TRUE)



  diff_estimation <- estimated_Y_AB_bounds$Y_A_cumulative_estimation - estimated_Y_AB_bounds$Y_B_cumulative_estimation
  diff_upper <- estimated_Y_AB_bounds$Y_A_cumulative_upper - estimated_Y_AB_bounds$Y_B_cumulative_lower
  diff_lower <- estimated_Y_AB_bounds$Y_A_cumulative_lower - estimated_Y_AB_bounds$Y_B_cumulative_upper
  p <- estimated_Y_AB_bounds$p



  cat("\n")
  cat("Cd =  ~ proportion where positive = ", mean(diff_estimation[2:(length(diff_estimation)-1)] > 0), "in (", mean(diff_lower[2:(length(diff_estimation)-1)] > 0), ", ", mean(diff_upper[2:(length(diff_estimation)-1)] > 0), ")", "\n")
  cat("Cp =  ~ integral + 0.5  = ", mean(diff_estimation) + 0.5, "in (",  mean(diff_lower) + 0.5, ", ", mean(diff_upper) + 0.5, ")", "\n")
  cat("Cp from Cp_estimation -> 0.5 + term1 + term2  = 0.5 + ", Cp_estimation_summation1, " + ", Cp_estimation_summation2, " = ", 0.5 + Cp_estimation_summation1 + Cp_estimation_summation2  , "\n")
  cat("Cp from Cp_estimation_22 -> 0.5 + term1 + term2  = 0.5 + ", Cp_estimation_22_summation1, " + ", Cp_estimation_22_summation2, " = ", 0.5 + Cp_estimation_22_summation1 + Cp_estimation_22_summation2  , "\n")
  cat("Cp from Cp_estimation_beta -> 0.5 + term1 + term2 + term3  = 0.5 + ", Cp_estimation_beta_sumation1, " + ", Cp_estimation_beta_sumation2, " + ",Cp_estimation_beta_sumation3, " = ", + 0.5 + Cp_estimation_beta_sumation1 + Cp_estimation_beta_sumation2 + Cp_estimation_beta_sumation3  , "\n")
  cat("Cp from Cp_estimation_gamma -> 0.5 + term1 + term2 + term3  = 0.5 + ", Cp_estimation_gamma_sumation1, " + ", Cp_estimation_gamma_sumation2, " + ",Cp_estimation_gamma_sumation3, " = ", + 0.5 + Cp_estimation_gamma_sumation1 + Cp_estimation_gamma_sumation2 + Cp_estimation_gamma_sumation3  , "\n")
  cat("Cp from Cp_estimation_delta -> 0.5 + term1 + term2 + term3  = 0.5 + ", Cp_estimation_delta_sumation1, " + ", Cp_estimation_delta_sumation2, " + ",Cp_estimation_delta_sumation3, " = ", + 0.5 + Cp_estimation_delta_sumation1 + Cp_estimation_delta_sumation2 + Cp_estimation_delta_sumation3  , "\n")




  plot_Y_AB(estimated_Y_AB_bounds, plotDifference=TRUE)
}

