library("RVCompare")
figsave_dir <- "~/Dropbox/BCAM/06_comparing_optimization_algorithms/paper/images/Rfigures/"

for (i in 1:4) {
  print(paste("--- Example", toString(i), "---"))

  nSamples <- 400

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

  estimated_X_prima_AB_bounds <- get_X_prima_AB_bounds_bootstrap(samplesA, samplesB, alpha = 0.05, nOfEstimationPoints=100, nOfBootstrapSamples = 1e3)

  diff_estimation <- estimated_X_prima_AB_bounds$X_prima_A_cumulative_estimation - estimated_X_prima_AB_bounds$X_prima_B_cumulative_estimation
  diff_upper <- estimated_X_prima_AB_bounds$X_prima_A_cumulative_upper - estimated_X_prima_AB_bounds$X_prima_B_cumulative_lower
  diff_lower <- estimated_X_prima_AB_bounds$X_prima_A_cumulative_lower - estimated_X_prima_AB_bounds$X_prima_B_cumulative_upper
  p <- estimated_X_prima_AB_bounds$p



  cat("\n")
  cat("Cd = ", Cd, " ~ proportion where positive = ", mean(diff_estimation[2:(length(diff_estimation)-1)] > 0), "in (", mean(diff_lower[2:(length(diff_estimation)-1)] > 0), ", ", mean(diff_upper[2:(length(diff_estimation)-1)] > 0), ")", "\n")
  cat("Cp = ", Cp, " ~ integral + 0.5  = ", mean(diff_estimation) + 0.5, "in (",  mean(diff_lower) + 0.5, ", ", mean(diff_upper) + 0.5, ")", "\n")


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

    ggplot2::scale_colour_manual("", breaks = c("X_A", "X_B"),  values = c("#00BFC4", "#F8766D")) +
    ggplot2::scale_linetype_manual("", breaks = c("X_A", "X_B"), values = c("solid", "dashed")) +

    ggplot2::xlab('x') +
    ggplot2::ylab('probability density')

resultPath <- paste(figsave_dir, "Example", i,"_density.pdf", sep="")
ggsave(resultPath, plot=densityPlot, device="pdf", width = 4, height = 3, )

cumulativePlot = ggplot2::ggplot() +
    ggplot2::xlim(xlims) +
    geom_line(data=dfPlot,
              aes(x=x, y=cumulativeA, colour = "X_A", linetype="X_A")) +
    geom_line(data=dfPlot,
              aes(x=x, y=cumulativeB, colour = "X_B", linetype="X_B")) +
    ggplot2::scale_colour_manual("", breaks = c("X_A", "X_B"),  values = c("#00BFC4", "#F8766D")) +
    ggplot2::scale_linetype_manual("", breaks = c("X_A", "X_B"), values = c("solid", "dashed")) +

    ggplot2::xlab('x') +
    ggplot2::ylab('cumulative probability')

resultPath <- paste(figsave_dir, "Example", i,"_cumulative.pdf", sep="")
ggsave(resultPath, plot=cumulativePlot, device="pdf", width = 4, height = 3, )




  fig <- plot_X_prima_AB(estimated_X_prima_AB_bounds, plotDifference = FALSE)
  ggsave(paste(figsave_dir, "Example", i,"_xprimaAB.pdf", sep=""), plot=fig, width = 4, height = 3, device="pdf")
  fig <- plot_X_prima_AB(estimated_X_prima_AB_bounds, plotDifference = TRUE)
  ggsave(paste(figsave_dir, "Example", i,"_xprimaABDiff.pdf", sep=""), plot=fig,  width = 4, height = 3, device="pdf")
}
