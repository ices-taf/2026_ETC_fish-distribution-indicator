## Run analysis, write model results

## Before:
## After:

source("utilities.R")
detachAllPackages()

library(icesTAF)
library(Kendall)
library(dplyr)

# read annual data for ices divisions
annual_results_ices <-
  read.taf(
    "model/annual_results_ices.csv"
  )

# run a Kendall test
sst_regressions_ices <-
  annual_results_ices %>%
    mutate(
      ratio = ifelse(ratio == Inf, 30, ratio)
    ) %>%
    group_by(
      Survey, Quarter, F_CODE
    ) %>%
    summarise(
      pval = Kendall::Kendall(sst, ratio)$sl,
      pval1 = Kendall::Kendall(sst1, ratio)$sl,
      pval2 = Kendall::Kendall(sst2, ratio)$sl
    ) %>%
    ungroup() %>%
    arrange(F_CODE) %>%
    select(-Survey, -Quarter)

write.taf(sst_regressions_ices, dir = "model", quote = TRUE)


# read annual data for msfd regions
annual_results_msfd <-
  read.taf(
    "model/annual_results_msfd.csv"
  )

# run a Kendall test
sst_regressions_msfd <-
  annual_results_msfd %>%
    mutate(
      ratio = ifelse(ratio == Inf, 30, ratio)
    ) %>%
    group_by(
      msfd
    ) %>%
    summarise(
      pval = Kendall::Kendall(sst, ratio)$sl,
      pval1 = Kendall::Kendall(sst1, ratio)$sl,
      pval2 = Kendall::Kendall(sst2, ratio)$sl
    ) %>%
    ungroup() %>%
    arrange(msfd)

write.taf(sst_regressions_msfd, dir = "model", quote = TRUE)



# read annual data for msfd regions
annual_results_msfd <-
  read.taf(
    "model/annual_results_msfd.csv"
  )

# run a Kendall test for trends
trend_regressions_msfd <-
  annual_results_msfd %>%
  mutate(
    ratio = ifelse(ratio == Inf, 30, ratio)
  ) %>%
  group_by(
    msfd
  ) %>%
  summarise(
    pval = Kendall::MannKendall(ratio)$sl
  ) %>%
  ungroup() %>%
  arrange(msfd)

write.taf(sst_regressions_msfd, dir = "model", quote = TRUE)
