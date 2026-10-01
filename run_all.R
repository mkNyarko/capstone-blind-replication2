# Re-runs the whole step-by-step replication in one R session, in order,
# echoing each step's code and output (same as the live run).
# From this folder:  LC_ALL=en_US.UTF-8 Rscript run_all.R
# Or in RStudio: setwd() to this folder, then source("run_all.R").
options(width = 120, warn = 1)
Sys.setlocale("LC_COLLATE", "en_US.UTF-8")
Sys.setenv(TZ = "America/New_York")
for (f in sort(list.files("R", pattern = "^[0-9]{2}_.*\\.R$", full.names = TRUE))) {
  cat("\n\n==================== ", basename(f), " ====================\n", sep = "")
  source(f, echo = TRUE, max.deparse.length = Inf, spaced = TRUE, keep.source = TRUE)
}
