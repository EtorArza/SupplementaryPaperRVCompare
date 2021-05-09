library(RVCompare)
figsave_dir <- "~/Dropbox/BCAM/06_comparing_optimization_algorithms/paper/images/Rfigures/"


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


densityPlot = ggplot2::ggplot() +
  ggplot2::xlim(xlims) +
  geom_line(data=dfPlot,
            aes(x=x, y=densityA, colour = "X_A", linetype="X_A")) +
  geom_line(data=dfPlot,
            aes(x=x, y=densityB, colour = "X_B", linetype="X_B")) +
  geom_line(data=dfPlot,
            aes(x=x, y=densityB1, colour = "X_B1", linetype="X_B1")) +

  ggplot2::scale_colour_manual("", breaks = c("X_A", "X_B", "X_B1"),  values = c("#00BFC4", "#F8766D", "#FF0000")) +
  ggplot2::scale_linetype_manual("", breaks = c("X_A", "X_B", "X_B1"), values = c("solid", "dashed", "dotted")) +

  ggplot2::xlab('x') +
  ggplot2::ylab('probability density')

resultPath <- paste(figsave_dir, "impossibility_porp7and1_density.pdf", sep="")
ggsave(resultPath, plot=densityPlot, device="pdf", width = 4, height = 3, )

cumulativePlot = ggplot2::ggplot() +
  ggplot2::xlim(xlims) +
  geom_line(data=dfPlot,
            aes(x=x, y=cumulativeA, colour = "X_A", linetype="X_A")) +
  geom_line(data=dfPlot,
            aes(x=x, y=cumulativeB, colour = "X_B", linetype="X_B")) +
  geom_line(data=dfPlot,
            aes(x=x, y=cumulativeB1, colour = "X_B1", linetype="X_B1")) +
  ggplot2::scale_colour_manual("", breaks = c("X_A", "X_B", "X_B1"),  values = c("#00BFC4", "#F8766D", "#FF0000")) +
  ggplot2::scale_linetype_manual("", breaks = c("X_A", "X_B", "X_B1"), values = c("solid", "dashed", "dotted")) +

  ggplot2::xlab('x') +
  ggplot2::ylab('cumulative probability')

resultPath <- paste(figsave_dir, "impossibility_porp7and1_cumulative.pdf", sep="")
ggsave(resultPath, plot=cumulativePlot, device="pdf", width = 4, height = 3, )
