
library(icesTAF)
taf.library(icesFO)

load_ecoregion <-
function(ecoregion, precision = 3) {
  baseurl <- "https://gis.ices.dk/gis/rest/services/ICES_reference_layers/ICES_Ecoregions/MapServer/0/query?where=Ecoregion%3D%27Baltic%20Sea%27&geometryType=esriGeometryPolygon&geometryPrecision=2&f=geojson"
  url <- httr::parse_url(baseurl)
  url$query$where <- paste0(
    "Ecoregion='", ecoregion,
    "'"
  )
  url$query$geometryPrecision <- precision
  url <- httr::build_url(url)
  filename <- tempfile(fileext = ".geojson")
  download.file(url, destfile = filename, quiet = FALSE)
  ecoreg <- sf::read_sf(filename)
  unlink(filename)
  ecoreg
}

ecoregion <- load_ecoregion("Greater North Sea")

sf::st_write(ecoregion, "ecoregion.csv",
             layer_options = "GEOMETRY=AS_WKT",
             delete_layer = TRUE)
