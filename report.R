## Prepare plots and tables for report

## Before:
## After:

library(icesTAF)

mkdir("report")

source("report-plots-and-tables.R")

rmarkdown::render("MAR011_Changes in fish distribution_2026.Rmd", output_dir = "report")

# create a readme for the zip
cat(
"README

The contents of this zip file contains several csv files and images.
There are results for both ICES divisions and MSFD european sea
regions, indicated by a suffix on the file name.

The results in this zip file are a rerun of the same procedure
as last year, using data up to 2025.


",
  file = "report/README.txt"
)

# create upload zip
files <-
  c(
    file.path("model", dir("model")),
    file.path("output", dir("output")),
    file.path("report", dir("report")),
    dir("report", pattern = "*.docx")
  )

zip("report/MAR011_rerun_2026.zip", files, extras = "-j")
