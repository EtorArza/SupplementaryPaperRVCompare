
# Install and load dependencies
if (!require("pacman")) install.packages("pacman")
pacman::p_load(RVCompare, ggplot2, scmamp, MCMCpack, devtools, geometry)



# if (!require("devtools")) {
#   install.packages("devtools")
# }

# devtools::install_github("b0rxa/scmamp")
# library(scmamp)

csv_path1 <- "data/pleda_gradient/results/pleda_results.csv"
csv_path2 <- "data/pleda_gradient/results/gradient_results.csv"
figsave_dir <- "figures/"

sampleSizes <- c(10, 20, 1000)


df1 <- read.csv(csv_path1, sep = ";", header = FALSE)
df2 <- read.csv(csv_path2, sep = ";", header = FALSE)


names(df1) <- c("Instance", "Fitness")
names(df2) <- c("Instance", "Fitness")

instance_names <- as.character(unique(df1[,1]))

print(instance_names)

for (sampleSize in sampleSizes){
  for (instance in instance_names) {

    instance_name_for_save <- tail(strsplit(instance, "/")[[1]],1)






    f1 <- df1[df1["Instance"] == instance,]["Fitness"][[1]]
    f2 <- df2[df2["Instance"] == instance,]["Fitness"][[1]]

    bk <- 52704
    f1 <- (bk - f1)/bk
    f2 <- (bk - f2)/bk


    # choose sampleSize samples
    f1 <- f1[1:sampleSize]
    f2 <- f2[1:sampleSize]


    test_res <- wilcox.test(f1,f2)

    cat("\nWith a sample size of n =", sampleSize, "\n")
    cat("The p-value of the Mann-Withney test was p =", test_res$p.value, "\n")


    # print the medians
    cat("Median of PL-EDA =",median(f1),"\n")
    cat("Median of PL-GS =",median(f2),"\n")
    print("---")
    # Comply with annoying data format required in ggplot2
    dataHist <- data.frame(
      value=c(f1,f2),
      type=c(rep("PL-EDA", length(f1)), rep("PL-GS",  length(f2)))
    )

    breaks <- c(min(c(f1,f2)), (min(c(f1,f2)) + max(c(f1,f2))) / 2, max(c(f1,f2)))

    # Histogram
    fig <- ggplot(data=dataHist, aes(x=value, fill=type)) +
      geom_histogram(alpha=0.70, position = 'identity') +
      scale_fill_manual(values=c("grey20", "grey60")) + theme_bw() +
      scale_x_continuous(labels= function(x) format(x, scientific=TRUE), breaks = breaks) +
      ggplot2::xlab('score') +
      ggplot2::ylab('count') +
      ggplot2::theme_minimal() +
      labs(fill="")

    ggsave(paste(figsave_dir, "pleda_gradient_", instance_name_for_save,"_samplesize_", sampleSize, "_histogram.pdf", sep=""), plot=fig,  width = 4, height = 2, device="pdf")



    # box plot
    fig <- ggplot(dataHist, aes(x = type, y = value, fill=type)) +
      geom_boxplot(width=0.1, fill="white", outlier.shape = 4) +
      ggplot2::theme_minimal() +
      theme(legend.position = "none") +
      ggplot2::xlab(' ') +
      ggplot2::ylab('score')

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
      ggplot2::xlab(' ') +
      ggplot2::ylab('score') +
      theme(legend.position = "none")



    ggsave(paste(figsave_dir, "pleda_gradient_", instance_name_for_save,"_samplesize_", sampleSize, "_violin.pdf", sep=""), plot=fig,  width = 4, height = 2, device="pdf")


    # simplex plot
    testRes <- bSignedRankTest(f1, f2, rope = c(-1e-4,1e-4))
    testRes$posterior.probabilities
    fig<-plotSimplex(testRes, plot.density=TRUE, A='PL-EDA',B="PL-GS", plot.points=TRUE, posterior.label=FALSE, alpha=0.5, point.size=2,font.size = 5)
    print(fig)
    ggsave(paste(figsave_dir, "pleda_gradient_", instance_name_for_save,"_samplesize_", sampleSize, "_simplex.png", sep=""), plot=fig,  width = 3, height = 3, device="png", dpi = 400)







    # cat("EDA", median(samplesA))
    # cat("PL-GS", median(samplesB))

    print("---")


    # produce X'_A X'_B and difference graph
    estimated_Y_AB_bounds <- get_Y_AB_bounds_bootstrap(f1, f2, alpha = 0.05, nOfBootstrapSamples = 1e4, ignoreMinimumLengthCheck=TRUE)
    fig <- plot_Y_AB(estimated_Y_AB_bounds, labels=c("PL-EDA", "PL-GS"),  plotDifference = TRUE)
    ggsave(paste(figsave_dir, "pleda_gradient_",instance_name_for_save, "_samplesize_", sampleSize, "_xprimaABDiff.pdf", sep=""), plot=fig,  width = 4, height = 3, device="pdf")
    print(fig)
    fig <- plot_Y_AB(estimated_Y_AB_bounds, labels=c("PL-EDA", "PL-GS"), plotDifference = FALSE)
    ggsave(paste(figsave_dir, "pleda_gradient_",instance_name_for_save, "_samplesize_", sampleSize, "_xprimaAB_raw.pdf", sep=""), plot=fig,  width = 4, height = 3, device="pdf")
  }
}


