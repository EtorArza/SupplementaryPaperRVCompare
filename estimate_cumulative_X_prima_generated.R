# Install and load dependencies
if (!require("pacman")) install.packages("pacman")
pacman::p_load(RVCompare, ggplot2)
figsave_dir <- "images/Rfigures/"


dir_to_save_estimation_csv <-"~/Dropbox/BCAM/06_comparing_optimization_algorithms/code/"

n_examples <- 6
n_colums_per_example <- 10

res_mat <- zeros(n_examples,n_colums_per_example)


for (example_index in 1:n_examples) {
  print(paste("--- Example", toString(example_index), "---"))

  nSamples <- 5000
  n <- nSamples
  if (example_index==1)
  {
    w1 <- 45 / (45 + 47)
    w2 <- 47 / (45 + 47)
    densityA <- mixtureDensity(c(normalDensity(0.05,0.00125), normalDensity(0.07, 0.00125)), weights = c(w1, w2))
    densityB <- mixtureDensity(c(normalDensity(0.06,0.00125), normalDensity(0.08, 0.00125)), weights = c(w2, w1))
    xlims <- c(0.04, 0.09)
  }
  else if(example_index==2)
  {
    densityA <- normalDensity(0.211325,0.002)
    densityB <- mixtureDensity(c(normalDensity(0.21875,0.002), normalDensity(0.04875, 0.002)), weights = c(0.925, 0.075))
    xlims <- c(0.0, 0.3)
  }
  else if(example_index==3)
  {
    densityA <- normalDensity(0.3,0.05)
    densityB <- normalDensity(0.32,0.05)
    xlims <- c(0.0, 0.6)
  }
  else if(example_index==4)
  {
    densityA <- mixtureDensity(c(normalDensity(0.3,0.025), normalDensity(0.1, 0.0025)), weights = c(0.95, 0.05))
    densityB <- mixtureDensity(c(normalDensity(0.3,0.025), normalDensity(0.15, 0.0025)), weights = c(0.95, 0.05))
    xlims <- c(0.05, 0.45)
  }
  else if(example_index==5)
  {
    # Beta distribution with alpha=2, beta=5
    densityA <- function(values){sapply(values, function(x) dbeta(x,2,5))}
    densityB <- normalDensity(0.5, 0.1)
    xlims <- c(0,1)
  }
  else if(example_index==6)
  {
    # log-normal distribution with sigma = 0.25, and mu = 0
    densityA <- function(values){sapply(values, function(x) dlnorm(x,0,0.25))}
    densityB <- normalDensity(1, 0.2)
    xlims <- c(0,4)
  }
  cat("Computing samples...")
  samplesA <- sampleFromDensity(densityA, nSamples, xlims, nIntervals = 1e5)
  cat("...")
  samplesB <- sampleFromDensity(densityB, nSamples, xlims, nIntervals = 1e5)
  cat("done!\n")



  cat("Computing Cp from estimator\n")
  Cp_estimation <- 0.5
  for (i in 1:length(samplesA)) {
    for (k in 1:length(samplesA)) {
      Cp_estimation <- Cp_estimation + sign(samplesB[[k]] - samplesA[[i]]) / (2*n*n)
    }
  }

  cat("Computing Cd from estimator")
  Cd_estimation <- NULL

  C2n <- sort(c(samplesA,samplesB))
  C2n_unique <- unique(C2n)

  G_A_j_last <- 0
  G_B_j_last <- 0
  G_A_j <- 0
  G_B_j <- 0
  n_null_phi <- 0

  phi_c_j_sum <- 0
  for (j in 1:length(C2n)) {
    c_j <- C2n[[j]]
    G_A_j_last <- G_A_j
    G_B_j_last <- G_B_j
    G_A_j <- sum(samplesA <= c_j)/n
    G_B_j <- sum(samplesB <= c_j)/n
    phi_c_j <- NULL

    if (G_A_j_last == G_B_j_last && G_A_j == G_B_j)
    {
      phi_c_j <- 0
      n_null_phi <- n_null_phi+1
    }
    else if(G_A_j_last >= G_B_j_last && G_A_j > G_B_j)
    {
      phi_c_j <- 1
    }
    else if(G_A_j_last > G_B_j_last && G_A_j >= G_B_j)
    {
      phi_c_j <- 1
    }
    else if(G_B_j_last >= G_A_j_last && G_B_j > G_A_j)
    {
      phi_c_j <- -1
    }
    else if(G_B_j_last > G_A_j_last && G_B_j >= G_A_j)
    {
      phi_c_j <- -1
    }
    else if(G_B_j_last > G_A_j_last && G_A_j > G_B_j)
    {
      gamma_j <- (G_B_j_last - G_A_j_last) / (sum(samplesB==c_j) - sum(samplesA==c_j))
      phi_c_j <- 1 - 2*gamma_j
    }
    else if(G_A_j_last > G_B_j_last && G_B_j > G_A_j)
    {
      gamma_j <- (G_B_j_last - G_A_j_last) / (sum(samplesB==c_j) - sum(samplesA==c_j))
      phi_c_j <- 2*gamma_j - 1
    }
    else
    {
      print("ERROR: none of the if clauses was entered.")
      cat("G_A_j_last: ",G_A_j_last,
          ", G_B_j_last: ",G_B_j_last,
          ", G_A_j: ",G_A_j,
          ", G_B_j: ",G_B_j, "\n")
      stop()
    }

    phi_c_j_sum <- phi_c_j_sum + phi_c_j
  }
  k_c <- (2*n - n_null_phi) / (2*n)
  Cd_estimation <- (phi_c_j_sum / (2*n) + 1) / 2 * (1/k_c)
  cat("done!\n")




  cat("Computing Cd...")
  Cd <- CdFromDensities(densityA, densityB, xlims)
  cat("Cp...")
  Cp <- CpFromDensities(densityA, densityB, xlims)
  cat("done!\n")


  # compute the estimation of the difference (including upper and lower bounds of confidence band)

  estimated_Y_AB_bounds <- get_Y_AB_bounds_bootstrap(samplesA, samplesB, alpha = 0.05, nOfBootstrapSamples = 1e3)

  diff_estimation <- estimated_Y_AB_bounds$Y_A_cumulative_estimation - estimated_Y_AB_bounds$Y_B_cumulative_estimation
  diff_upper <- estimated_Y_AB_bounds$Y_A_cumulative_upper - estimated_Y_AB_bounds$Y_B_cumulative_lower
  diff_lower <- estimated_Y_AB_bounds$Y_A_cumulative_lower - estimated_Y_AB_bounds$Y_B_cumulative_upper
  p <- estimated_Y_AB_bounds$p

  cp_est_from_cum_diff_plot <- mean(diff_estimation) + 0.5
  cp_lower_from_cum_diff_plot <- mean(diff_lower) + 0.5
  cp_upper_from_cum_diff_plot <- mean(diff_upper) + 0.5


  # grapical_estimation of cd.


  delta_sign <- function(values, delta)
  {
    copy_values <- values
    copy_values[copy_values < delta & copy_values > -delta] <- 0
    return(sign(copy_values))
  }

  delta <- 0.015

  gecv_est <- delta_sign(diff_estimation[2:(length(diff_estimation)-1)], delta)
  gecv_upper <- delta_sign(diff_upper[2:(length(diff_upper)-1)], delta)
  gecv_lower <- delta_sign(diff_lower[2:(length(diff_lower)-1)], delta)

  cd_est_from_cum_diff_plot <- (sum(gecv_est) / length(gecv_est)) / 2 * (length(gecv_est) / sum(gecv_est!=0)) + 0.5
  cd_upper_from_cum_diff_plot <- (sum(gecv_upper) / length(gecv_upper)) / 2 * (length(gecv_upper) / sum(gecv_upper!=0))  + 0.5
  cd_lower_from_cum_diff_plot <- (sum(gecv_lower) / length(gecv_lower)) / 2 * (length(gecv_lower) / sum(gecv_lower!=0)) + 0.5



  cat("\nCd = ", Cd, " ~ proportion where positive = ", cd_est_from_cum_diff_plot, "in (", cd_lower_from_cum_diff_plot, ", ", cd_upper_from_cum_diff_plot, ")", "\n")
  cat("Cp = ", Cp, " ~ integral + 0.5  = ", cp_est_from_cum_diff_plot, "in (", cp_lower_from_cum_diff_plot, ", ", cp_upper_from_cum_diff_plot, ")", "\n")
  cat("Cp from estimator -> ", Cp_estimation, "\n")
  cat("Cd from estimator -> ", Cd_estimation, "\n")

  res_mat[[example_index, 1]] <- Cd
  res_mat[[example_index, 2]] <- Cd_estimation
  res_mat[[example_index, 3]] <- cd_est_from_cum_diff_plot
  res_mat[[example_index, 4]] <- cd_lower_from_cum_diff_plot
  res_mat[[example_index, 5]] <- cd_upper_from_cum_diff_plot
  res_mat[[example_index, 6]] <- Cp
  res_mat[[example_index, 7]] <- Cp_estimation
  res_mat[[example_index, 8]] <- cp_est_from_cum_diff_plot
  res_mat[[example_index, 9]] <- cp_lower_from_cum_diff_plot
  res_mat[[example_index, 10]] <- cp_upper_from_cum_diff_plot

  x <- seq(xlims[1], xlims[2], length.out=201)
  dfPlot <- as.data.frame(list(
    "x"= x,
    "densityA" = densityA(x),
    "densityB" = densityB(x),
    "cumulativeA" = cumulativeFromDensity(densityA, xlims, sanityChecks = FALSE)(x),
    "cumulativeB" = cumulativeFromDensity(densityB, xlims, sanityChecks = FALSE)(x)
  ))



densityPlot = ggplot2::ggplot() +
    ggplot2::xlim(xlims) +
    geom_line(data=dfPlot,
              aes(x=x, y=densityA, colour = "X_A", linetype="X_A")) +
    geom_line(data=dfPlot,
              aes(x=x, y=densityB, colour = "X_B", linetype="X_B")) +

    ggplot2::scale_colour_manual("", breaks = c("X_A", "X_B"),  values = c("#1f77b4", "#ff7f0e")) +
    ggplot2::scale_linetype_manual("", breaks = c("X_A", "X_B"), values = c("solid", "dashed")) +

    ggplot2::xlab('x') +
    ggplot2::ylab('probability density')

resultPath <- paste(figsave_dir, "Example", example_index,"_density.pdf", sep="")
ggsave(resultPath, plot=densityPlot, device="pdf", width = 4, height = 3, )

cumulativePlot = ggplot2::ggplot() +
    ggplot2::xlim(xlims) +
    geom_line(data=dfPlot,
              aes(x=x, y=cumulativeA, colour = "X_A", linetype="X_A")) +
    geom_line(data=dfPlot,
              aes(x=x, y=cumulativeB, colour = "X_B", linetype="X_B")) +
    ggplot2::scale_colour_manual("", breaks = c("X_A", "X_B"),  values = c("#1f77b4", "#ff7f0e")) +
    ggplot2::scale_linetype_manual("", breaks = c("X_A", "X_B"), values = c("solid", "dashed")) +

    ggplot2::xlab('x') +
    ggplot2::ylab('cumulative probability')

resultPath <- paste(figsave_dir, "Example", example_index,"_cumulative.pdf", sep="")
ggsave(resultPath, plot=cumulativePlot, device="pdf", width = 4, height = 3, )



  fig <- plot_Y_AB(estimated_Y_AB_bounds, plotDifference = FALSE)
  fig <- fig + scale_colour_manual("", breaks = c("X_A", "X_B"), values = c("X_A"="#1f77b4", "X_B"="#ff7f0e"))
  ggsave(paste(figsave_dir, "Example", example_index,"_xprimaAB.pdf", sep=""), plot=fig, width = 4, height = 3, device="pdf")
  fig <- plot_Y_AB(estimated_Y_AB_bounds, plotDifference = TRUE)
  print(fig)
  ggsave(paste(figsave_dir, "Example", example_index,"_xprimaABDiff.pdf", sep=""), plot=fig,  width = 4, height = 3, device="pdf")
}



res_df <- as.data.frame(res_mat)

colnames(res_df) <- c("Cd",
                      "Cd_estimation",
                      "cd_est_from_cum_diff_plot",
                      "cd_lower_from_cum_diff_plot",
                      "cd_upper_from_cum_diff_plot",
                      "Cp",
                      "Cp_estimation",
                      "cp_est_from_cum_diff_plot",
                      "cp_lower_from_cum_diff_plot",
                      "cp_upper_from_cum_diff_plot")

write.csv(res_df, paste(dir_to_save_estimation_csv, "cp_cd_estimation_estimate_cumulative_Y_grnerated.csv"), row.names=FALSE)


colors <- c("red", "orange", "blue")
extra_shift <- c(0.1, 0.2, 0.3)


# Plot estimated Cd
fig <- ggplot2::ggplot(data.frame(), aes(x,y)) +
  ggplot2::xlim(c(1,n_examples+1)) +
  ggplot2::ylim(c(0,1)) +
  ggplot2::theme_bw() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

fig <- fig + ggplot2::geom_point(aes(x=1:n_examples + extra_shift[[1]],y=res_mat[1:n_examples,1]),colour=colors[[1]], shape=1)
fig <- fig + ggplot2::geom_point(aes(x=1:n_examples + extra_shift[[2]],y=res_mat[1:n_examples,2]),colour=colors[[2]], shape=2)
fig <- fig + ggplot2::geom_point(aes(x=1:n_examples + extra_shift[[3]],y=res_mat[1:n_examples,3]),colour=colors[[3]], shape=4)
fig <- fig + ggplot2::geom_point(aes(x=1:n_examples + extra_shift[[3]],y=res_mat[1:n_examples,4]),colour=colors[[3]], shape=3)
fig <- fig + ggplot2::geom_point(aes(x=1:n_examples + extra_shift[[3]],y=res_mat[1:n_examples,5]),colour=colors[[3]], shape=3)

fig <- fig + ggplot2::scale_x_continuous("Example", 1:6+0.2, labels = 1:6)
fig <- fig + ggplot2::ylab(" ")

ggsave(paste(figsave_dir, "estimated_Cd_xprimaABDiff_all_examples.pdf", sep=""), plot=fig,  width = 4, height = 3, device="pdf")

print(fig)



# Plot estimated Cp
fig <- ggplot2::ggplot(data.frame(), aes(x,y)) +
  ggplot2::xlim(c(1,n_examples+1)) +
  ggplot2::ylim(c(0,1)) +
  ggplot2::theme_bw() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

fig <- fig + ggplot2::geom_point(aes(x=1:n_examples + extra_shift[[1]],y=res_mat[1:n_examples,6]),colour=colors[[1]], shape=1)
fig <- fig + ggplot2::geom_point(aes(x=1:n_examples + extra_shift[[2]],y=res_mat[1:n_examples,7]),colour=colors[[2]], shape=2)
fig <- fig + ggplot2::geom_point(aes(x=1:n_examples + extra_shift[[3]],y=res_mat[1:n_examples,8]),colour=colors[[3]], shape=4)
fig <- fig + ggplot2::geom_point(aes(x=1:n_examples + extra_shift[[3]],y=res_mat[1:n_examples,9]),colour=colors[[3]], shape=3)
fig <- fig + ggplot2::geom_point(aes(x=1:n_examples + extra_shift[[3]],y=res_mat[1:n_examples,10]),colour=colors[[3]], shape=3)

fig <- fig + ggplot2::scale_x_continuous("Example", 1:6+0.2, labels = 1:6)
fig <- fig + ggplot2::ylab(" ")

ggsave(paste(figsave_dir, "estimated_Cp_xprimaABDiff_all_examples.pdf", sep=""), plot=fig,  width = 4, height = 3, device="pdf")

print(fig)



