
source("utilities.R")
detachAllPackages()

library(icesTAF)
library(ncdf4)
library(raster)
library(chron)
library(dplyr)
library(sf)
library(tidyverse)

# read in EEA areas
msfd <- sf::read_sf(taf.data.path("EEA_MRUs/MSFD_Publication_20181129_EuropeSeas.gpkg"))
# msfd$name

regions <-
  c(
    "Baltic",
    "Celtic Seas",
    "Greater North Sea, incl. the Kattegat and the English Channel",
    "Bay of Biscay and the Iberian Coast"
  )

msfd <-
  msfd %>%
  filter(name %in% regions)

# would be good to simplify...

# plot(areas)

# read sst nc as raster
b <- brick("bootstrap/data/hadley-sst/HadSST.4.2.0.0_median.nc")

msfd <- st_transform(msfd, crs(b))

b <- crop(b, extent(msfd), snap = "out")
b[b > 100] <- NA


# filter for years of interest (1963 to allow for 2 year lag)
b <- b[[which(year(b@z$time) %in% 1963:2025)]]
yrs <- year(b@z$time)

# group accross years
b <- stackApply(b, yrs, fun = mean)
yrs <- sort(unique(yrs))
names(b) <- paste(yrs)

if (FALSE) {
  image(b[["X2018"]])
  plot(msfd, add = TRUE, col = "transparent")
}

# calculate number of cells and means
means <- raster::extract(b, msfd, mean)

# package into a data.frame
sst <-
  data.frame(
    name = rep(msfd$name, ncol(means)),
    Year = rep(yrs, each = nrow(means)),
    sst = c(means)
  )

sst <-
  do.call(
    rbind,
    by(
      sst,
      sst$name,
      function(x) {
        # calculate lags at 1 and 2 years
        x$sst1 <- c(NA, x$sst[-nrow(x)])
        x$sst2 <- c(NA, x$sst1[-nrow(x)])
        x
      }
    )
  )
row.names(sst) <- NULL

sst_msfd <- sst[sst$Year >= 1965, ]

write.taf(sst_msfd, dir = "data", quote = TRUE)

if (FALSE) {
  library(ggplot2)
  ggplot(sst_msfd, aes(x = Year, y = sst, col = name)) +
  geom_line()
}