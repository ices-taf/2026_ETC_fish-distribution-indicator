# read in a and process statrecs shapefile

library(icesTAF)
library(dplyr)
library(sf)

# read in statsq table
statrecs <- sf::read_sf("bootstrap/data/ICES-stat-rec/StatRec_map_Areas_Full_20170124.shp")

# plot(statrecs["Area_27"])

# join on eea areas
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

# plot(msfd["name"])
sf::sf_use_s2(FALSE)
ov <- sf::st_intersects(msfd, statrecs)

statrecs$msfd <- NA_character_
for (i in seq_along(ov)) {
  statrecs$msfd[ov[[i]]] <- msfd$name[i]
}

# plot(statrecs[c("msfd", "Area_27")])

# format statsquare table
statrecs <-
  statrecs %>%
  select(
    ICESNAME, Area_27, msfd, stat_x, stat_y, geometry
  ) %>%
  rename(
    StatRec = ICESNAME,
    F_CODE = Area_27,
    Lat = stat_x,
    Lon = stat_y
  ) %>%
  filter(!is.na(F_CODE) & !is.na(msfd)) %>%
  mutate(
    F_CODE = F_CODE %>%
              strsplit("[.]") %>%
              lapply("[", 1:2) %>%
              sapply(paste0, collapse = ".")
  ) %>%
  mutate(
    F_CODE = ifelse(F_CODE %in% c("3.b", "3.c"), "3.b, c", F_CODE)
  )

# plot(statrecs[c("msfd", "F_CODE")])


# write out
sf::write_sf(
  statrecs,
  "data/statrecs.csv",
  layer_options = "GEOMETRY=AS_WKT",
  delete_dsn = file.exists("data/statrecs.csv")
)
