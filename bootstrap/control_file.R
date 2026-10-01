# -------------------------------------
#
# process supplied control file
#
# -------------------------------------

library(icesTAF)

control_file <- read.taf(taf.data.path("Overview_of_surveys_to_be_used.csv"), check.names = TRUE)

write.taf(control_file, quote = TRUE)
