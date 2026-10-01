## Preprocess data, write TAF data tables

## Before:
## After:

library(icesTAF)
library(pdftools)
source("utilities.R")

mkdir("data")

reclaim_file <- list.files("bootstrap/data", pattern = "[.]pdf$", full.names = TRUE)

extraction <- pdf_text(reclaim_file)

# annex 1
grep("^[ ]*Annex 1", extraction)
table_names <- c(
  "family", "scientific_name", "common_name",
  "affinity", "reproductive_mode", "Lmax",
  "trophic_guild", "trophic_level",
  "habitat_horizontal", "habitat_vertical", "source"
)

reclaim_table <- extraction[311:320]

annex1_northsea_species <-
  convert_table(reclaim_table, strip = 1:5, table_names = table_names)
annex1_northsea_species <-
  cbind(
    table = "northsea",
    annex1_northsea_species
  )

# annex 2
grep("^[ ]*Annex 2", extraction)
table_names <- c(
  "family", "scientific_name", "common_name",
  "reproductive_mode", "Lmax",
  "trophic_guild", "trophic_level",
  "habitat_horizontal"
)

reclaim_table <- extraction[321:322]
# baltic has no affinity
annex2_baltic_species <-
  convert_table(reclaim_table, strip = 1:5, table_names = table_names)
annex2_baltic_species <-
  cbind(
    table = "baltic",
    annex2_baltic_species[1:3],
    affinity = NA,
    annex2_baltic_species[4:8],
    habitat_vertical = annex2_baltic_species[[8]]
  )


# annex 3
grep("^[ ]*Annex 3", extraction)
table_names <- c(
  "family", "scientific_name", "common_name",
  "affinity", "reproductive_mode", "Lmax",
  "trophic_guild", "trophic_level",
  "habitat_horizontal", "habitat_vertical", "source"
)

reclaim_table <- extraction[323:329]

annex3_irishsea_species <-
  convert_table(reclaim_table, strip = 1:5, table_names = table_names)
annex3_irishsea_species <-
  cbind(
    table = "irishsea",
    annex3_irishsea_species
  )



# annex 4
grep("^[ ]*Annex 4", extraction)
table_names <- c(
  "family", "scientific_name", "common_name",
  "affinity", "reproductive_mode", "Lmax",
  "trophic_guild", "trophic_level",
  "habitat_horizontal", "habitat_vertical"
)

reclaim_table <- extraction[330:377]

annex4_european_species <-
  convert_table(reclaim_table, strip = 1:9, table_names = table_names)
annex4_european_species <-
  cbind(
    table = "european",
    annex4_european_species
  )

annex4_european_species$scientific_name <-
  gsub("^[-]", "", annex4_european_species$scientific_name)

# join together

affinity <-
  rbind(
    annex1_northsea_species,
    cbind(annex2_baltic_species, source = NA),
    annex3_irishsea_species,
    cbind(annex4_european_species, source = NA)
  )

write.taf(affinity, dir = "data", quote = TRUE)

# some odd doubling up happening - then good I think
