require(dplyr)

# datras_fname utility:
datras.fname <- function(what, survey, year, quarter) {
  paste0(what, "_", survey, "_", year, "_", quarter, ".csv")
}

process_datras <- function(hh, hl, Gear) {
  hl %>%
    process_hl() %>%
    filter(Gear == Gear) %>%
    left_join(
      process_hh(hh) %>% filter(Gear == Gear),
      by = c("Survey", "Quarter", "Country", "Ship", "Gear", "SweepLngt",
             "GearExp", "DoorType", "StNo", "HaulNo", "Year")
    ) %>%
    select(
      Survey, Quarter, Year, StatRec, Valid_Aphia
    ) %>%
    unique()
}

process_hl <- function(hl) {
  file.path("bootstrap/data/datras", hl) %>%
    read.taf()
}

process_hh <-  function(hh) {
  file.path("bootstrap/data/datras", hh) %>%
    read.taf(colClasses = c(StatRec = "character"))
}


detachAllPackages <- function(keep = NULL) {
  basic.packages <-
    paste0("package:",
           c("stats", "graphics", "grDevices", "utils",
             "datasets", "methods", "base", keep))
  package.list <- grep("package:", search(), value = TRUE)
  # will only work if there are no dependent packages
  # could force by looping until all packages detached
  for (package in setdiff(package.list, basic.packages))
    detach(package, character.only = TRUE)
}

.bootDatasets <- list.files("bootstrap/data", full.names = TRUE, recursive = TRUE)
names(.bootDatasets) <- basename(.bootDatasets)
.bootDatasets <- as.list(.bootDatasets)



convert_page <- function(x, table_names) {
  # find column endings
  # do on all rows?...
  cols_try <-
    lapply(x, function(y) {
      matches <- gregexpr(text = y, pattern = "\\s\\s+")[[1]]
      c(1, c(matches + attr(matches, "match.length")), 1000000L)
    })

  # ncols <- as.numeric(names(sort(table(sapply(cols_try, length)), decreasing = TRUE)[1])) - 1
  ncols <- length(table_names)
  cols_try <- do.call(rbind, cols_try[sapply(cols_try, length) >= ncols + 1])
  cols <- apply(cols_try, 2, min)

  # hand calced first table col positions
  # cols <- c(1, 18, 48, 77, 106, 127, 135, 158, 165, 182, 1000000L)

  tab <- lapply(2:length(cols), function(i) trimws(substring(x, cols[i - 1], cols[i] - 1), "right"))

  if (all(tab[[1]] == "")) {
    tab <- tab[-1]
  }

  # species name is never empty - need a hack for page 4...
  tab[[2]] <- replace(tab[[2]], !nzchar(tab[[2]]), "-")

  # join multiline rows
  blanks <- sort(unique(unlist(lapply(tab, function(x) which(nchar(x) == 0)))))

  tab <-
    lapply(
      tab,
      function(col) {
        sapply(
          1:length(col),
          function(i) {
            if ((i + 1) %in% blanks) paste(col[0:1 + i], collapse = " ") else if (i %in% blanks) "" else col[i]
          }
        )
      }
    )

  # need to unhack page four hack... - remove leading "- " and trailing " -" in column 2

  names(tab) <- table_names

  tab <- data.frame(tab)

  tab <- tab[apply(tab, 1, function(y) !all(y == "")), ]
  tab[] <- lapply(tab, trimws)

  # tab <- type.convert(tab, as.is = TRUE)

  tab
}

convert_table <- function(reclaim_table, strip, table_names, debug = FALSE) {
  # remove em dash and windows '
  reclaim_table <- gsub("\u2013", "-", reclaim_table)
  reclaim_table <- gsub("\u2019", "'", reclaim_table)

  # split into lines
  reclaim_table <- strsplit(reclaim_table, "\n")

  # strip table legend
  reclaim_table[[1]] <- reclaim_table[[1]][-strip]

  prep <- function(x) {
    # remove foot notes
    x <- x[!grepl("^[ ]*[0-9]", x)]

    chars <- nchar(x)
    margin <- max(sort(chars, decreasing = TRUE)[-(1:2)])

    x <- substring(x, 1, margin)
    x <- trimws(x, "right")
    x <- x[nzchar(x)]
    x <- x[-(1:2)]

    x
  }

  y <- sapply(reclaim_table, prep)

  if (debug) {
    cat(sapply(y[3:4], paste, collapse = "\n"), sep = "\n\n-------------------------------------\n\n", file = "tmp.txt")
    x <- y[[1]]
  }

  # now it is ready to find the columns
  y_conv <-
    do.call(
      rbind,
      lapply(y, convert_page, table_names = table_names)
    )

  y_conv[] <- lapply(y_conv, gsub, pattern = "- ", replacement = "-")

  y_conv$scientific_name <- gsub("^- ", "", y_conv$scientific_name)
  y_conv$scientific_name <- gsub(" -$", "", y_conv$scientific_name)

  y_conv
}
