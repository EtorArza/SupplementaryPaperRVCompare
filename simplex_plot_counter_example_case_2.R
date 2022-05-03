# if (!require("devtools")) {
#   install.packages("devtools")
# }
# install.packages("MCMCpack")
# devtools::install_github("b0rxa/scmamp")


library(scmamp)
library(RVCompare)

figsave_dir <- "figures/"


N_SAMPLES_PPER_RV <- 400

# define distributions
densityA <- normalDensity(0.211325,0.002)
densityB <- mixtureDensity(c(normalDensity(0.21875,0.002), normalDensity(0.04875, 0.002)), weights = c(0.925, 0.075))
xlims <- c(0.0, 0.3)


# plot cdf
x <- seq(xlims[1], xlims[2], length.out=201)
dfPlot <- as.data.frame(list(
  "x"= x,
  "densityA" = densityA(x),
  "densityB" = densityB(x),
  "cumulativeA" = cumulativeFromDensity(densityA, xlims, sanityChecks = FALSE)(x),
  "cumulativeB" = cumulativeFromDensity(densityB, xlims, sanityChecks = FALSE)(x)
))

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

print(cumulativePlot)

samplesA <- sampleFromDensity(densityA, N_SAMPLES_PPER_RV, xlims, nIntervals = 1e3)
samplesB <- sampleFromDensity(densityB, N_SAMPLES_PPER_RV, xlims, nIntervals = 1e3)


testRes <- bSignedRankTest(samplesA, samplesB, rope = c(-1e-3,1e-3))
testRes$posterior.probabilities

fig<-plotSimplex(testRes, plot.density=TRUE, A='X_A',B="X_B", plot.points=TRUE, posterior.label=FALSE, alpha=0.5, point.size=2,font.size = 5)
print(fig)

ggsave(paste(figsave_dir, "simplex_case2.png", sep=""), plot=fig,  width = 3, height = 3, device="png", dpi = 400)




