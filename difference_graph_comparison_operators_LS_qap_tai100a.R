library(RVCompare)
library(ggplot2)

setwd("~/Dropbox/BCAM/06_comparing_optimization_algorithms/code")
csv_path <- "data/comparison_operators_LS_qap_tai100a.csv"
figsave_dir <- "~/Dropbox/BCAM/06_comparing_optimization_algorithms/paper/images/Rfigures/"

df <- read.csv(csv_path)



# Comply with annoying data format required in ggplot2
dataHist <- data.frame(
  value=c(df$insert,df$swap),
  type=c(rep("insert", length(df$insert)), rep("swap",  length(df$swap)))
)


# Histogram
fig <- ggplot(data=dataHist, aes(x=value, fill=type)) +
  geom_histogram(alpha=0.65, position = 'identity') +
  scale_fill_manual(values=c("#1f77b4", "#ff7f0e")) +
  ggplot2::xlab('objective value') +
  ggplot2::ylab('count') +
  ggplot2::theme_minimal() +
  labs(fill="")

ggsave(paste(figsave_dir, "swap_insert_","histogram.pdf", sep=""), plot=fig,  width = 4, height = 2, device="pdf")

# It must be a minimization problem, therefore in the case of the QAP, it should
# be a positive cost, as 0 is the optimal cost.
samplesA <- df$insert
samplesB <- df$swap




estimated_X_prima_AB_bounds <- get_X_prima_AB_bounds_bootstrap(samplesA, samplesB, alpha = 0.1)
fig <- plot_X_prima_AB(estimated_X_prima_AB_bounds, labels=c("insert", "swap"),  plotDifference = TRUE)
ggsave(paste(figsave_dir, "swap_insert_","xprimaABDiff.pdf", sep=""), plot=fig,  width = 4, height = 3, device="pdf")
fig <- plot_X_prima_AB(estimated_X_prima_AB_bounds, labels=c("insert", "swap"), plotDifference = FALSE)
ggsave(paste(figsave_dir, "swap_insert_","xprimaAB_raw.pdf", sep=""), plot=fig,  width = 4, height = 3, device="pdf")




