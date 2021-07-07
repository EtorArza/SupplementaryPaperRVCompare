library(RVCompare)
figsave_dir <- "~/Dropbox/BCAM/06_comparing_optimization_algorithms/paper/images/Rfigures/"


print("WARNING: The labels of the Figure were edited with inkscape to add LaTex fonts.")


xlims <- c(-0.5,1)

X_A <- uniformDensity(c(0,1))
X_B1 <- uniformDensity(c(0.1,1))
X_B2 <- uniformDensity(c(-0.5,0))
X_B <- mixtureDensity(c(X_B1, X_B2), weights = c(0.9,0.1))


x <- seq(xlims[1], xlims[2], length.out=201)
dfPlot <- as.data.frame(list(
  "x"= x,
  "densityA" = X_A(x),
  "densityB" = X_B(x),
  "densityB1" = X_B1(x),
  "cumulativeA" = cumulativeFromDensity(X_A, xlims, sanityChecks = FALSE)(x),
  "cumulativeB" = cumulativeFromDensity(X_B, xlims, sanityChecks = FALSE)(x),
  "cumulativeB1" = cumulativeFromDensity(X_B1, xlims, sanityChecks = FALSE)(x)
))

dfPlotReduced <- dfPlot[seq(1, nrow(dfPlot), 24), ]


densityPlot = ggplot2::ggplot() +
  ggplot2::xlim(xlims) +
  geom_line(data=dfPlot,
            aes(x=x, y=densityA, colour = "X_A", linetype="X_A"), alpha = 0.6) +
  geom_line(data=dfPlot,
            aes(x=x, y=densityB, colour = "X_B", linetype="X_B"), alpha = 0.6) +
  geom_line(data=dfPlot,
            aes(x=x, y=densityB1, colour = "X_B1", linetype="X_B1"), alpha = 0.6) +

  ggplot2::scale_colour_manual("", breaks = c("X_A", "X_B", "X_B1"),  values = c("#1f77b4", "#ff7f0e", "#2ca02c")) +
  ggplot2::scale_linetype_manual("", breaks = c("X_A", "X_B", "X_B1"), values = c("solid", "dashed", "dotted")) +

  ggplot2::xlab('x') +
  ggplot2::ylab('probability density')

resultPath <- paste(figsave_dir, "impossibility_porp7and1_density.pdf", sep="")
ggsave(resultPath, plot=densityPlot, device="pdf", width = 4, height = 2)

transparency <- 0.5
cumulativePlot = ggplot2::ggplot() +
  ggplot2::xlim(xlims) +
  ggplot2::geom_line(data=dfPlot,
            aes(x=x, y=cumulativeA, colour = "X_A", linetype="X_A"), alpha=transparency) +
  ggplot2::geom_line(data=dfPlot,
            aes(x=x, y=cumulativeB, colour = "X_B", linetype="X_B"), alpha=transparency) +
  ggplot2::geom_line(data=dfPlot,
            aes(x=x , y=cumulativeB1, colour = "X_B1", linetype="X_B1"), alpha=transparency) +
  ggplot2::geom_point(data=dfPlotReduced,
            aes(x=x, y=cumulativeA, colour = "X_A",  shape="X_A"), alpha=transparency) +
  ggplot2::geom_point(data=dfPlotReduced,
            aes(x=x, y=cumulativeB, colour = "X_B", shape="X_B"), alpha=transparency) +
  ggplot2::geom_point(data=dfPlotReduced,
            aes(x=x, y=cumulativeB1, colour = "X_B1", shape="X_B1"), alpha=transparency) +
  ggplot2::scale_colour_manual("", breaks = c("X_A", "X_B", "X_B1"),  values = c("#1f77b4", "#ff7f0e", "#2ca02c")) +
  ggplot2::scale_linetype_manual("", breaks = c("X_A", "X_B", "X_B1"), values = c("solid", "solid", "solid")) +
  ggplot2::scale_shape_manual("", breaks = c("X_A", "X_B", "X_B1"), values=c(4,1,0))+
  ggplot2::xlab('x') +
  ggplot2::ylab('cumulative probability') +
  ggplot2::theme_minimal()


print(cumulativePlot)

resultPath <- paste(figsave_dir, "impossibility_porp7and1_cumulative.pdf", sep="")
ggsave(resultPath, plot=cumulativePlot, device="pdf", width = 4, height = 2, )
