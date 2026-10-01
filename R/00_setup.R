# ---- Step 00: setup --------------------------------------------------------
# Packages (versions must match the spec), paths, and a checkpoint tracker.
suppressPackageStartupMessages({
  library(data.table); library(dplyr); library(stringr); library(lubridate)
  library(tidyr); library(ggplot2); library(nnet); library(broom)
  library(pscl); library(gtsummary); library(gt); library(flextable)
})
pkgs <- c("data.table", "dplyr", "nnet", "broom", "ggplot2", "gtsummary", "pscl")
sapply(pkgs, function(p) as.character(packageVersion(p)))

proj_dir  <- getwd()
faers_dir <- file.path(dirname(proj_dir), "FAERS_DATA_2024")
int_dir   <- file.path(proj_dir, "output", "intermediate")
data_dir  <- file.path(proj_dir, "output", "data")
tab_dir   <- file.path(proj_dir, "output", "tables")
fig_dir   <- file.path(proj_dir, "output", "figures")
log_dir   <- file.path(proj_dir, "output", "logs")
list.files(faers_dir)

checkpoints <- data.frame(step = integer(), figure1_box = character(), n = integer())
checkpoint <- function(step, box, n) {
  checkpoints <<- rbind(checkpoints, data.frame(step = step, figure1_box = box, n = n))
  fwrite(checkpoints, file.path(log_dir, "checkpoints.csv"))
  cat(sprintf("\n>>> CHECKPOINT %d | %s | n = %s\n", step, box, format(n, big.mark = ",")))
}

# Locate a quarter's table regardless of folder-name case (q1 vs Q4)
quarter_file <- function(q, tbl) {
  qdir <- list.files(faers_dir, pattern = paste0("^faers_ascii_2024", q, "$"),
                     ignore.case = TRUE, full.names = TRUE)
  file.path(qdir, "ASCII", sprintf("%s24%s.txt", tbl, q))
}
quarter_file("Q1", "DRUG")
