library(dplyr)

# change time to 1000 as service can be very slow
to <- getOption("timeout")
options(timeout = 10000)

download.file(
  "https://sdi.eea.europa.eu/datastore/public/eea_v_4326_100_k_europe-seas_p_2010-2018_v01_r00/EuropeSeas_GPKG/MSFD_Publication_20181129_EuropeSeas.gpkg",
  "MSFD_Publication_20181129_EuropeSeas.gpkg",
  mode = "wb"
)

# reset timeout
options(timeout = to)
