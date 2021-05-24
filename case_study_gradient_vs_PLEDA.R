library(RVCompare)
library(ggplot2)

setwd("~/Dropbox/BCAM/06_comparing_optimization_algorithms/code")
csv_path1 <- "data/pleda_gradient/results/gradient_results.csv"
csv_path2 <- "data/pleda_gradient/results/pleda_results.csv"
figsave_dir <- "/home/paran/Dropbox/BCAM/06_comparing_optimization_algorithms/paper/images/Rfigures/case_study_eda_pl/"




df1 <- read.csv(csv_path1, sep = ";")
df2 <- read.csv(csv_path2, sep = ";")


names(df1) <- c("Instance", "Fitness")
names(df2) <- c("Instance", "Fitness")




instance_names <- as.character(unique(df1[,1]))



for (instance in instance_names) {

  instance_name_for_savce <- tail(strsplit(instance, "/")[[1]],1)

  f1 <- df1[df1["Instance"] == instance,]["Fitness"][[1]]
  f2 <- df2[df2["Instance"] == instance,]["Fitness"][[1]]

  if (length(f1) < 20 || length(f2) < 20) {
    next
  }

  # Comply with annoying data format required in ggplot2
  dataHist <- data.frame(
    value=c(f1,f2),
    type=c(rep("PLEDA", length(f1)), rep("gradient",  length(f2)))
  )



  # Histogram
  fig <- ggplot(data=dataHist, aes(x=value, fill=type)) +
    geom_histogram(alpha=0.65, position = 'identity') +
    scale_fill_manual(values=c("#1f77b4", "#ff7f0e")) +
    ggplot2::xlab('objective value') +
    ggplot2::ylab('count') +
    ggplot2::theme_minimal() +
    labs(fill="")

  ggsave(paste(figsave_dir, "pleda_gradient_",instance_name_for_savce,"_histogram.pdf", sep=""), plot=fig,  width = 4, height = 2, device="pdf")

  # It must be a minimization problem, therefore in the case of the QAP, it should
  # be a positive cost, as 0 is the optimal cost.
  samplesA <- f1
  samplesB <- f2




  estimated_X_prima_AB_bounds <- get_X_prima_AB_bounds_bootstrap(samplesA, samplesB, alpha = 0.1, ignoreUniqueValuesCheck = TRUE)
  fig <- plot_X_prima_AB(estimated_X_prima_AB_bounds, labels=c("PLEDA", "gradient"),  plotDifference = TRUE)
  ggsave(paste(figsave_dir, "pleda_gradient_",instance_name_for_savce,"_xprimaABDiff.pdf", sep=""), plot=fig,  width = 4, height = 3, device="pdf")
  fig <- plot_X_prima_AB(estimated_X_prima_AB_bounds, labels=c("PLEDA", "gradient"), plotDifference = FALSE)
  ggsave(paste(figsave_dir, "pleda_gradient_",instance_name_for_savce,"_xprimaAB_raw.pdf", sep=""), plot=fig,  width = 4, height = 3, device="pdf")


}








