library(RVCompare)
library(ggplot2)
library(scmamp)

setwd("~/Dropbox/BCAM/06_comparing_optimization_algorithms/code")
csv_path1 <- "data/pleda_gradient/results/pleda_results.csv"
csv_path2 <- "data/pleda_gradient/results/gradient_results.csv"
figsave_dir <- "/home/paran/Dropbox/BCAM/06_comparing_optimization_algorithms/paper/images/Rfigures/case_study_eda_pl/"

sampleSizes <- c(1000)


df1 <- read.csv(csv_path1, sep = ";")
df2 <- read.csv(csv_path2, sep = ";")


names(df1) <- c("Instance", "Fitness")
names(df2) <- c("Instance", "Fitness")

instance_names <- as.character(unique(df1[,1]))

print(instance_names)

for (sampleSize in sampleSizes){
  for (instance in instance_names) {

    instance_name_for_save <- tail(strsplit(instance, "/")[[1]],1)

    f1 <- df1[df1["Instance"] == instance,]["Fitness"][[1]]
    f2 <- df2[df2["Instance"] == instance,]["Fitness"][[1]]



    # choose sampleSize samples
    f1 <- f1[1:sampleSize]
    f2 <- f2[1:sampleSize]


    test_res <- wilcox.test(f1,f2)

    cat("The p-value of the Mann-Withney test was p =", test_res$p.value, "\n")


    # print the medians
    cat("Median of EDA =",median(f1),"\n")
    cat("Median of gradient =",median(f2),"\n")

    # Comply with annoying data format required in ggplot2
    dataHist <- data.frame(
      value=c(f1,f2),
      type=c(rep("PLEDA", length(f1)), rep("gradient",  length(f2)))
    )

    breaks <- c(min(c(f1,f2)), (min(c(f1,f2)) + max(c(f1,f2))) / 2, max(c(f1,f2)))

    # Histogram
    fig <- ggplot(data=dataHist, aes(x=value, fill=type)) +
      geom_histogram(alpha=0.65, position = 'identity') +
      scale_fill_manual(values=c("#1f77b4", "#ff7f0e")) +
      scale_x_continuous(labels= function(x) format(x, scientific=TRUE), breaks = breaks) +
      ggplot2::xlab('objective value') +
      ggplot2::ylab('count') +
      ggplot2::theme_minimal() +
      labs(fill="")

    ggsave(paste(figsave_dir, "pleda_gradient_", instance_name_for_save,"_samplesize_", sampleSize, "_histogram.pdf", sep=""), plot=fig,  width = 4, height = 2, device="pdf")



    # box plot
    fig <- ggplot(dataHist, aes(x = type, y = value, fill=type)) +
      geom_boxplot(width=0.1, fill="white", outlier.shape = 4) +
      ggplot2::theme_minimal() +
      theme(legend.position = "none") +
      ggplot2::xlab('algorithm') +
      ggplot2::ylab('objective value')

      ggsave(paste(figsave_dir, "pleda_gradient_", instance_name_for_save,"_samplesize_", sampleSize, "_boxplot.pdf", sep=""), plot=fig,  width = 4, height = 2, device="pdf")



    # Violin plot
    fig <- ggplot(dataHist, aes(x = type, y = value, fill=type)) +

      geom_violin(trim = FALSE) +
      stat_summary(
        fun.data = "mean_sdl",  fun.args = list(mult = 1),
        geom = "pointrange", color = "black", shape = 4
      ) +
      geom_violin(fill="grey", trim = FALSE) +
      geom_boxplot(width=0.1, fill="white", outlier.shape = 4) +
      ggplot2::theme_minimal() +
      ggplot2::xlab('algorithm') +
      ggplot2::ylab('objective value') +
      theme(legend.position = "none")



    ggsave(paste(figsave_dir, "pleda_gradient_", instance_name_for_save,"_samplesize_", sampleSize, "_violin.pdf", sep=""), plot=fig,  width = 4, height = 2, device="pdf")



    # simplex plot
    bk <- 52704
    testRes <- bSignedRankTest(-(bk - f1)/bk, -(bk - f2)/bk, rope = c(-1e-4,1e-4))
    testRes$posterior.probabilities
    fig<-plotSimplex(testRes, plot.density=TRUE, A='PLEDA',B="gradient", plot.points=TRUE, posterior.label=FALSE, alpha=0.5, point.size=2,font.size = 5)
    print(fig)
    ggsave(paste(figsave_dir, "pleda_gradient_", instance_name_for_save,"_samplesize_", sampleSize, "_simplex.png", sep=""), plot=fig,  width = 3, height = 3, device="png", dpi = 400)






    # The difference graph requires a minimization context, therefore in the
    # case of the LOP, we need to transform it into a minimization problem by
    # multiplying it by -1
    samplesA <- -f1
    samplesB <- -f2

    # cat("EDA", median(samplesA))
    # cat("gradient", median(samplesB))


    # produce X'_A X'_B and difference graph
    estimated_X_prima_AB_bounds <- get_X_prima_AB_bounds_bootstrap(samplesA, samplesB, alpha = 0.1, nOfEstimationPoints = 200, nOfBootstrapSamples = 1e5)
    fig <- plot_X_prima_AB(estimated_X_prima_AB_bounds, labels=c("PLEDA", "gradient"),  plotDifference = TRUE)
    ggsave(paste(figsave_dir, "pleda_gradient_",instance_name_for_save,"_samplesize_", sampleSize,"_xprimaABDiff.pdf", sep=""), plot=fig,  width = 4, height = 3, device="pdf")
    fig <- plot_X_prima_AB(estimated_X_prima_AB_bounds, labels=c("PLEDA", "gradient"), plotDifference = FALSE)
    ggsave(paste(figsave_dir, "pleda_gradient_",instance_name_for_save,"_samplesize_", sampleSize,"_xprimaAB_raw.pdf", sep=""), plot=fig,  width = 4, height = 3, device="pdf")
  }
}


