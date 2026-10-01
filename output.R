## Extract results of interest, write TAF output tables

## Before:
## After:

source("utilities.R")
detachAllPackages()

library(icesTAF)
library(dplyr)
library(tidyr)

mkdir("output")

# read in model results
annual_results_statsq <- read.taf("model/annual_results_statsq.csv")
annual_results_ices <- read.taf("model/annual_results_ices.csv")
annual_results_msfd <- read.taf("model/annual_results_msfd.csv")

# Fig 1 requires

# per stat sq -
# * StatRec - 28F1
# * Survey - NS_IBTS
# * F_CODE - i.e 27.4.c
# * Quarter
# * year
# * Lusitanian  - count
# * Boreal - count
# * ratio - Lusitanian / Boreal
# * Lat - latitude
# * Lon - longitude

fig1_data <-
  annual_results_statsq %>%
  select(
    StatRec, Survey, Quarter, Year,
    Lusitanian, Boreal, ratio, Lat, Lon, WKT
  )

head(fig1_data)

write.taf(fig1_data, dir = "output", quote = TRUE)

# convert to sf object and save as geojson file
fig1_data_sf <- sf::st_as_sf(fig1_data, wkt = "WKT", crs = 4326)
fig1_data_sf <- sf::st_centroid(fig1_data_sf)
fig1_data_sf$Year <- as.Date(ISOdate(fig1_data_sf$Year, 1, 1))

sf::write_sf(fig1_data_sf, "output/fig1_data_esri.shp")
files <- dir("output", pattern = "*_esri", full = TRUE)
if (file.exists("output/fig1_data.zip")) file.remove("output/fig1_data.zip")
zip("output/fig1_data.zip", files, extras = "-j")
file.remove(files)


# Figure 2 requires

# * Year
# * Atlantic species
# * Boreal species
# * Lusitanian species
# * Unknown Biological affinity
# * Area

fig2_data_ices <-
  annual_results_ices %>%
  mutate(
    F_CODE = paste0(27, ".", F_CODE),
  ) %>%
  select(
    Year, Atlantic, Boreal, Lusitanian, Unknown, F_CODE
  ) %>%
  arrange(F_CODE, Year)

write.taf(fig2_data_ices, dir = "output", quote = TRUE)


fig2_data_msfd <-
  annual_results_msfd %>%
  select(
    Year, Atlantic, Boreal, Lusitanian, Unknown, msfd
  ) %>%
  arrange(msfd, Year)

write.taf(fig2_data_msfd, dir = "output", quote = TRUE)


# Figure 3 requires

# * Year
# * L/B Ratio
# * Temp - ?
# * Temperature - this is whats plotted
# * Temp2 - ?
# * Area

fig3_data_ices <-
  annual_results_ices %>%
  mutate(
    F_CODE = paste0(27, ".", F_CODE),
  ) %>%
  select(
    Year, ratio, sst, sst1, sst2, F_CODE
  ) %>%
  arrange(F_CODE, Year)

write.taf(fig3_data_ices, dir = "output", quote = TRUE)

fig3_data_msfd <-
  annual_results_msfd %>%
  select(
    Year, ratio, sst, sst1, sst2, msfd
  ) %>%
  arrange(msfd, Year)

write.taf(fig3_data_msfd, dir = "output", quote = TRUE)
