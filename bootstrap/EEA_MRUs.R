library(dplyr)

# change time to 1000 as service can be very slow
to <- getOption("timeout")
options(timeout = 10000)

download.file(
  "https://sdi.eea.europa.eu/datashare/s/H46FqeKNacXzJoR/download?path=%2FEuropeSeas_GPKG&files=MSFD_Publication_20181129_EuropeSeas.gpkg&downloadStartSecret=qpdy3m88r9l",
  "MSFD_Publication_20181129_EuropeSeas.gpkg",
  mode = "wb"
)

# reset timeout
options(timeout = to)
