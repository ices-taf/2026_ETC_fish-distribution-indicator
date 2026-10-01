
source("utilities.R")
detachAllPackages()

library(icesTAF)
library(ncdf4)
library(raster)
library(chron)
library(dplyr)
library(sf)
library(tidyverse)

# read control file
ctrl <- read.taf("bootstrap/data/control_file/control_file.csv")

# read in ICES areas shapes
areas <- sf::read_sf("bootstrap/data/ICES-areas/ICES_Areas_20160601_cut_dense_3857.shp")

# subset to areas of interest
areas$subarea.div <- paste(areas$SubArea, areas$Division, sep = ".")

# group 3.b and c
areas.3bc <- areas[which(areas$subarea.div %in% c("3.b", "3.c")),]
areas.3bc <- sf::st_union(areas.3bc)
areas$subarea.div[areas$subarea.div == "3.b"] <- "3.b, c"
areas$geometry[areas$subarea.div == "3.b, c"] <- areas.3bc

areas <- areas[which(areas$subarea.div %in% ctrl$Division),]

# simplify anc combine
areas <-
  areas %>%
  st_simplify(FALSE, 1e3) %>%
  group_by(subarea.div) %>%
  summarise(geog = st_union(geometry)) %>%
  ungroup()

# odd, but need to
areas <-
  areas[1:nrow(areas),] %>%
  st_simplify(FALSE, 3e4)

#plot(areas)

# read sst nc as raster
b <- raster::brick("bootstrap/data/hadley-sst/HadSST.4.2.0.0_median.nc")

areas <- st_transform(areas, crs(b))

b <- crop(b, extent(areas), snap = "out")
b[b > 100] <- NA


# filter for years of interest (1963 to allow for 2 year lag)
b <- b[[which(year(b@z$time) %in% 1963:2025)]]
yrs <- year(b@z$time)

# group accross years
b <- stackApply(b, yrs, fun = mean)
#yrs <- as.numeric(levels(yrs))
yrs <- sort(unique(yrs))
names(b) <- paste(yrs)

#image(b[["X2018"]])
#plot(areas, add = TRUE, col = "transparent")

# calculate number of cells and means
means <- raster::extract(b, areas, mean)

# package into a data.frame
sst <-
  data.frame(
    F_CODE = rep(areas$subarea.div, ncol(means)),
    Year = rep(yrs, each = nrow(means)),
    sst = c(means)
  )

sst <-
  do.call(
    rbind,
    by(
      sst,
      sst$F_CODE,
      function(x) {
        # calculate lags at 1 and 2 years
        x$sst1 <- c(NA, x$sst[-nrow(x)])
        x$sst2 <- c(NA, x$sst1[-nrow(x)])
        x
      }
    )
  )
row.names(sst) <- NULL

sst <- sst[sst$Year >= 1965,]

write.taf(sst, dir = "data", quote = TRUE)

#library(ggplot2)
#ggplot(sst, aes(x = year, y = sst, col = area)) +
#  geom_line()
