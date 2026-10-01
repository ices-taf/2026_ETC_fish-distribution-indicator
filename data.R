## Preprocess data, write TAF data tables

## Before:
## After:

library(icesTAF)

mkdir("data")

# processing
sourceTAF("data-reclaim-affinity.R")
sourceTAF("data-sst-icesareas.R")
sourceTAF("data-sst-eeamru.R")
sourceTAF("data-statrecs.R")
sourceTAF("data-species.R")

# joining together
sourceTAF("data-datras.R")
sourceTAF("data-datras-eeamru.R")
