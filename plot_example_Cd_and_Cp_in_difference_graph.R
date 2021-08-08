library(RVCompare)
library(ggplot2)

figsave_dir <- "~/Dropbox/BCAM/06_comparing_optimization_algorithms/paper/images/Rfigures/"


xlims <- c(-2,4)

densityA <- uniformDensity(c(0,1))
densityB <- mixtureDensity(c(normalDensity(0.5,0.5), normalDensity(1,1)), weights = c(0.4,0.6))


nSamples <- 400

cat("Computing samples...")
samplesA <- sampleFromDensity(densityA, nSamples, xlims, nIntervals = 1e5)
cat("...")
samplesB <- sampleFromDensity(densityB, nSamples, xlims, nIntervals = 1e5)
cat("done!\n")



estimated_X_prima_AB_bounds <- get_X_prima_AB_bounds_bootstrap(samplesA, samplesB, alpha = 0.99, nOfBootstrapSamples = 1e2)
fig <- plot_X_prima_AB(estimated_X_prima_AB_bounds, plotDifference = TRUE)

diff_estimation <- estimated_X_prima_AB_bounds$X_prima_A_cumulative_estimation - estimated_X_prima_AB_bounds$X_prima_B_cumulative_estimation
diff_upper <- estimated_X_prima_AB_bounds$X_prima_A_cumulative_upper - estimated_X_prima_AB_bounds$X_prima_B_cumulative_lower
diff_lower <- estimated_X_prima_AB_bounds$X_prima_A_cumulative_lower - estimated_X_prima_AB_bounds$X_prima_B_cumulative_upper
p <- estimated_X_prima_AB_bounds$p
zerosSizeP <- rep(0, length(p))

diff_plotdf_head <- head(data.frame(p, zerosSizeP, diff_estimation, diff_lower, diff_upper), 25)
diff_plotdf_tail <- tail(data.frame(p, zerosSizeP, diff_estimation, diff_lower, diff_upper), -25)



fig <- fig + ggplot2::geom_ribbon(data = diff_plotdf_head, ggplot2::aes(x=p, ymin = diff_estimation, ymax = zerosSizeP), fill = "#ff0000", alpha = 0.75)
fig <- fig + ggplot2::geom_ribbon(data = diff_plotdf_tail, ggplot2::aes(x=p, ymin = diff_estimation, ymax = zerosSizeP), fill = "#1a9900", alpha = 0.75)
fig <- fig + ggplot2::geom_line(data = diff_plotdf_head, ggplot2::aes(x=p, y=zerosSizeP), color='#ffb026', size=2)
fig <- fig + ggplot2::geom_line(data = diff_plotdf_tail, ggplot2::aes(x=p, y=zerosSizeP), color='#3cde92', size=2)
fig <- fig + annotate("text", x=0.1, y=-0.3, label= "Area1", color="#ff0000")
fig <- fig + annotate("text", x=0.55, y=0.35, label= "Area2", color="#1a9900")
fig <- fig + annotate("text", x=0.1, y=0.15, label= "Length1", color="#ffb026")
fig <- fig + annotate("text", x=0.75, y=-0.15, label= "Length2", color="#3cde92")



print(fig)
ggsave(paste(figsave_dir, "plot_example_Cd_and_Cp_in_difference_graph.pdf", sep=""), plot=fig,  width = 4, height = 3, device="pdf")


