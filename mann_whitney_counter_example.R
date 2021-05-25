library(RVCompare)
library(utils)

N_SAMPLES_PPER_RV <- 400
N_REPS_ESTIMATE_PROB_REJECT_H0 <- 10000
P_VALUE_REJECTED_IF_LOWER_THAN <- 0.005


 # define distributions
w1 <- 45 / (45 + 47)
w2 <- 47 / (45 + 47)
densityA <- mixtureDensity(c(normalDensity(0.05,0.00125), normalDensity(0.07, 0.00125)), weights = c(w1, w2))
densityB <- mixtureDensity(c(normalDensity(0.06,0.00125), normalDensity(0.08, 0.00125)), weights = c(w2, w1))
xlims <- c(0.04, 0.09)

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


# estimate prob of rejection
count_rejected <- 0
pb = utils::txtProgressBar(min = 1, max = N_REPS_ESTIMATE_PROB_REJECT_H0, initial = 1, style = 3)
for (i in 1:N_REPS_ESTIMATE_PROB_REJECT_H0) {
  utils::setTxtProgressBar(pb,i)
  samplesA <- sampleFromDensity(densityA, N_SAMPLES_PPER_RV, xlims, nIntervals = 1e3)
  samplesB <- sampleFromDensity(densityB, N_SAMPLES_PPER_RV, xlims, nIntervals = 1e3)


  
  test_res <- wilcox.test(samplesA,samplesB)
  count_rejected = count_rejected + as.numeric(test_res$p.value < P_VALUE_REJECTED_IF_LOWER_THAN)
}

prob_reject <- count_rejected / N_REPS_ESTIMATE_PROB_REJECT_H0

cat("The probability that the null hypothesis is rejected with the Mann-Whitney test at alpha = ",
    P_VALUE_REJECTED_IF_LOWER_THAN,
    " and a sample size of ",
    N_SAMPLES_PPER_RV,
    " is ",
    prob_reject, 
    " (estimated with ",
    N_REPS_ESTIMATE_PROB_REJECT_H0,
    " monte carlo repetitions)."
    )

