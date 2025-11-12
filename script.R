# Analysis script for the manuscript
# "Beyond chronological age: Biological age is associated with performance in 
# throwing-related tests in youth track and field throwing athletes"
#
# written by Simon Nolte
# 
# script released under an MIT license

# load packages
library(readxl)  # data import
library(ggplot2) # visualization
library(lme4)    # multilevel modeling
library(purrr)   # functional programming

# read data
d <- read_excel("data/data.xlsx")
# rename columns
colnames(d)[7] <- "dAPHV"
colnames(d)[9:13] <- c("0-10m", "10-30m", "0-30m", "30-60m", "0-60m")
# convert from tibble to data.frame
d <- as.data.frame(d)

## PART 1: exploratory analysis-------------------------------------------------

# check relationship between chronological and biological age
ggplot(d, aes(CA, dAPHV)) +
  geom_point(aes(color = Sex)) +
  geom_smooth()
# ggsave("plots/CA-BA.png", width = 6, height = 5, dpi = 300, bg = "white")
# linear relationship with different intercepts for sex seems reasonable

# check relationship between age and performance
ggplot(d, aes(CA, BOST)) +
  geom_point() +
  geom_smooth(aes(color = Sex))
# ggsave("plots/CA-BOST.png", width = 6, height = 5, dpi = 300, bg = "white")
# some variables have no apparent relationship between chronological age and
# performance, others have one. We'll assume a linear relationship with
# different slopes and intercepts per Sex (so include a sex*CA interaction)

## PART 2: modeling-------------------------------------------------------------

# calculate residuals for biological age
d$dAPHV_resid <- resid(lm(dAPHV ~ CA + Sex, data = d))

# function to get model estimates
run_mod <- function(param, data = d, plot = FALSE) {
  # get parameter of interest
  data$out <- data[[param]]
  
  ##calculate expected performance
  mod_perf <- lm(out ~ CA * Sex, data = data)
  xpt <- predict(mod_perf)
  data$expected <- NA
  data$expected[!is.na(data$out)] <- xpt
  # percent difference from expected performance
  data$out_pct <- (data$out - data$expected) / data$expected
  #o <- lmerTest::lmer(out_pct ~ CA * Sex + dAPHV_resid + (1|ID), data = data)
  # do not use percentage performance as an outcome, as this leads to boundary 
  # fit. Instead transform model results to percentage later (should give
  # similar results)
  o <- lmerTest::lmer(out ~ CA * Sex + dAPHV_resid + (1|ID), data = data)
  es <- summary(o)$coefficients
  ci <- confint(o)
  # calculate standardized coefficients
  bs <- effectsize::standardize_parameters(o, method = "basic")
  b <- bs[4,2] # Parameter for dAPHV resid
  
  # get reference value to transform to percentages
  m <- mean(data$out, na.rm = TRUE)
  df <- data.frame(
    name = param,
    es = es["dAPHV_resid", "Estimate"] / m,
    ci_low = ci["dAPHV_resid",1] / m,
    ci_up = ci["dAPHV_resid",2] / m,
    beta = b
  )
  
  # option to create scatter plot
  if (plot) {
    ggplot(aes(dAPHV_resid, out_pct), data = data) +
      geom_hline(yintercept = 0, color = "grey40") +
      geom_vline(xintercept = 0, color = "grey40") +
      geom_point() +
      geom_smooth(aes(color = Sex)) +
      scale_y_continuous(
        name = "Overperformance for biological age", 
        labels = scales::label_percent()
      ) +
      scale_x_continuous(
        name = "Difference from predicted biological age (y)"
      ) +
      scale_color_manual(values = c("maroon4", "seagreen4")) +
      theme_classic() +
      theme(
        panel.grid.major = element_line()
      )
    #ggsave(
    #  paste0("plots/scatter_", param, ".png"), 
    #  width = 6, height = 5, dpi = 300, bg = "white"
    #)
    ggsave(
      paste0("plots/scatter_sex_", param, ".png"), 
      width = 6, height = 5, dpi = 300, bg = "white"
    )
  }
  
  attr(df, "mod") <- o
  df
}

# get variables
vs <- colnames(d)[9:20]

# get all model estimates
l <- lapply(vs, run_mod) |> purrr::list_rbind()

# reverse signs for scales on which lower values mean better performance
l[l$name %in% c("0-10m", "10-30m", "0-30m", "30-60m", "0-60m"), 2:5] <- -1 * l[l$name %in% c("0-10m", "10-30m", "0-30m", "30-60m", "0-60m"), 2:5]
l[l$name %in% c("0-10m", "10-30m", "0-30m", "30-60m", "0-60m"), 3:4] <- l[l$name %in% c("0-10m", "10-30m", "0-30m", "30-60m", "0-60m"), c(4,3)]

# write.csv(l, "effects.csv", row.names = FALSE)

# set signs for beta thresholds
l$beta_label <- ifelse(abs(l$beta) > 0.3, "◊◊", ifelse(abs(l$beta) > 0.1, "◊", ""))

# plot all model estimates
ggplot(l, aes(x = reorder(name, es, decreasing = TRUE), y = es)) +
  geom_hline(yintercept = 0, color = "grey40") +
  geom_point(size = 2) +
  geom_errorbar(aes(ymin = ci_low, ymax = ci_up), width = 0.2, linewidth = 0.7) +
  geom_text(aes(y = ci_up + 0.013, label = beta_label), size = 6) +
  scale_x_discrete(name = "Variable") +
  scale_y_continuous(
    name = "Performance difference per additional\n year of biological age", 
    labels = scales::label_percent(),
    breaks = seq(from = -0.05, to = 0.15, by = 0.05)) +
  theme_classic(base_size = 14) +
  theme(
    panel.grid.major.y = element_line(),
    #panel.grid.minor.y = element_line()
  )

# save plot
ggsave("plots/effects.jpg", width = 7, height = 4.6, dpi = 300, bg = "white")

# create individual scatter plots for variables
run_mod("BOST", plot = TRUE)
