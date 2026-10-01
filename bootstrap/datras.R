
# -------------------------------------
#
# download datras data files
#
# -------------------------------------

library(icesDatras)
library(icesTAF)
library(dplyr)

year.max <- 2025 # current year - 1

# read design table and look download all required surveys
ctab <- read.taf(taf.data.path("control_file", "control_file.csv"))

# surveys to get are:
toget <-
  ctab %>%
    select(Survey.name, Quarter, Start.year, Gear) %>%
    unique() %>%
    group_by(Survey.name, Quarter, Gear) %>%
    summarise(Start.year = min(Start.year), .groups = "keep") %>%
    as.data.frame()



# datras_fname utility from repo root:
source(taf.boot.path("..", "utilities.R"))

hh_list <- list()
hl_list <- list()

# loop over surveys and download (final year capped at year.max)
for (i in seq_len(nrow(toget))) {
  # which survey etc.
  survey <- toget[i, "Survey.name"]
  start.year <- toget[i, "Start.year"]
  end.year <- pmin(year.max, max(icesDatras::getSurveyYearList(survey)))
  quarter <- toget[i, "Quarter"]
  gear <- toget[i, "Gear"]

  for (year in start.year:end.year) {
    # within loop short-cut for file name
    fname <- function(what) {
      datras.fname(what, survey, year, quarter)
    }

    # download
    message("---- downloading HH ----")
    hh <- getDATRAS(record = "HH", survey = survey, year = year, quarter = quarter)
    if (!is.null(hh) && !identical(hh, FALSE)) {
      if (survey == "SP-PORC" & year == 2015 & quarter == 3) {
        hh$Country <- "ES"
      }
      hh <-
        hh %>%
          select(Survey, Quarter, Country, Ship, Gear, SweepLngt,
                 GearEx, DoorType, StNo, HaulNo, Year,
                 StatRec) %>%
          filter(Gear == gear)
      hh_list[[length(hh_list) + 1]] <- hh
    }
    rm(hh); gc()

#    next

    message("---- downloading HL ----")
    hl <- getDATRAS(record = "HL", survey = survey, year = year, quarter = quarter)
    if (!is.null(hl) && !identical(hl, FALSE)) {
      hl <-
        hl %>%
          select(Survey, Quarter, Country, Ship, Gear, SweepLngt,
                 GearEx, DoorType, StNo, HaulNo, Year,
                 HLNoAtLngt, Valid_Aphia) %>%
          filter(HLNoAtLngt > 0 & !is.na(Valid_Aphia) & Gear == gear) %>%
          select(-HLNoAtLngt) %>%
          unique()
      hl_list[[length(hl_list) + 1]] <- hl
    }
    rm(hl); gc()
  }
}

# summarise hh and hl data
datras_data <-
  hl_list %>%
    do.call(rbind, .) %>%
    left_join(
      do.call(rbind, hh_list),
      by = c("Survey", "Quarter", "Country", "Ship", "Gear", "SweepLngt",
             "GearEx", "DoorType", "StNo", "HaulNo", "Year")
    ) %>%
    select(
      Survey, Quarter, Year, StatRec, Valid_Aphia
    ) %>%
    unique()

head(datras_data)

write.taf(datras_data, quote = TRUE)


if (FALSE) {

  # list of countries
  hh <- do.call(rbind, hh_list)

  countries <-
    data.frame(
      Key = sort(unique(hh$Country))
    ) %>%
    left_join(
      icesVocab::getCodeList("ISO_3166"), by = "Key"
    ) %>%
    select(Key, Description)

countries


  ## testing

  left_join(
    hl_list[[1]],# %>% filter(StNo == 59),
    hh_list[[1]][1, ] %>% mutate(Country = "ES"),
    by = c(
      "Survey", "Quarter", "Country", "Ship", "Gear", "SweepLngt",
      "GearEx", "DoorType", "StNo", "HaulNo", "Year"
    )
  ) %>%
      select(
        Survey, Quarter, Year, StatRec, Valid_Aphia
      ) %>%
      unique()



  x <-
    hl_list[[1]][1, ] %>%
      left_join(
        hh_list[[1]][1,] %>% mutate(Country = "ES"),
        by = c(
          "Survey", "Quarter", "Country", "Ship", "Gear", "SweepLngt",
          "GearEx", "DoorType", "StNo", "HaulNo", "Year"
        )
      ) %>%
      select(
        Survey, Quarter, Year, StatRec, Valid_Aphia
      ) %>%
      unique()

head(x)

}