## Run analysis, write model results

## Before:
## After:

source("utilities.R")
detachAllPackages()

library(icesTAF)
library(dplyr)
library(tidyr)

mkdir("model")

# read in data
lusitanian <-
  read.taf(
    "data/lusitanian.csv",
    colClasses = c("StatRec" = "character")
  )

lusitanian_msfd <-
  read.taf(
    "data/lusitanian_msfd.csv",
    colClasses = c("StatRec" = "character")
  )


if (FALSE) {
  # investigate unknown species
  lusitanian %>%
    filter(Biogeo.affinity == "Unknown") %>%
    select(Valid_Aphia, Biogeo.affinity, Species) %>%
    unique()

  # check
  lusitanian %>%
    filter(is.na(Biogeo.affinity)) %>%
    select(Valid_Aphia, Species) %>%
    unique()


  lusitanian %>%
    filter(
      F_CODE == "4.c"
    ) %>%
    select(
      Survey, Year, Quarter, F_CODE
    ) %>%
    unique()

}

# Compute stat square summaries
annual_results_statsq <-
  lusitanian %>%
  group_by(
    Survey, Quarter, Year, StatRec, F_CODE, Lat, Lon, WKT, Biogeo.affinity
  ) %>%
  summarise(
    count = n()
  ) %>%
  ungroup() %>%
  pivot_wider(
    names_from = Biogeo.affinity,
    values_from = count,
    values_fill = list(count = 0)
  ) %>%
  mutate(
    ratio = ifelse(Boreal > 0, Lusitanian / Boreal, 99)
  )

# check
annual_results_statsq %>% filter(StatRec == "41E8" & Year == 2011)

write.taf(annual_results_statsq, dir = "model", quote = TRUE)

# compute annual summaries for ices divisions
annual_results_ices <-
  lusitanian %>%
  select(
    Year, Survey, Quarter, F_CODE, Valid_Aphia, sst, sst1, sst2, Biogeo.affinity
  ) %>%
  unique() %>%
  group_by(
    Year, Survey, Quarter, F_CODE, sst, sst1, sst2,, Biogeo.affinity
  ) %>%
  summarise(
    count = n()
  ) %>%
  ungroup() %>%
  pivot_wider(
    names_from = Biogeo.affinity,
    values_from = count,
    values_fill = list(count = 0)
  ) %>%
  mutate(
    ratio = ifelse(Boreal > 0, Lusitanian / Boreal, 99)
  )

# checks
annual_results_ices %>% filter(grepl("4[.]", F_CODE) & Year == 2011)

write.taf(annual_results_ices, dir = "model", quote = TRUE)


# compute annual summaries for msfd regions
annual_results_msfd <-
  lusitanian_msfd %>%
  select(
    Year, msfd, Valid_Aphia, sst, sst1, sst2, Biogeo.affinity
  ) %>%
  unique() %>%
  group_by(
    Year, msfd, sst, sst1, sst2, Biogeo.affinity
  ) %>%
  summarise(
    count = n()
  ) %>%
  ungroup() %>%
  pivot_wider(
    names_from = Biogeo.affinity,
    values_from = count,
    values_fill = list(count = 0)
  ) %>%
  mutate(
    ratio = ifelse(Boreal > 0, Lusitanian / Boreal, 99)
  ) %>%
  arrange(msfd, Year)

# checks
annual_results_msfd %>% filter(grepl("North", msfd) & Year == 2011)

write.taf(annual_results_msfd, dir = "model", quote = TRUE)
