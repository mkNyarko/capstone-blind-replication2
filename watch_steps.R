# Live R session for the step-by-step replication.
# Runs each step file dropped into queue/ (in name order) with its code echoed,
# keeps all objects in memory between steps, then files the step under R/.
# Start from this folder:  LC_ALL=en_US.UTF-8 Rscript watch_steps.R
# Stop with Ctrl-C.

options(width = 120, warn = 1)
Sys.setlocale("LC_COLLATE", "en_US.UTF-8")
Sys.setenv(TZ = "America/New_York")
dir.create("queue", showWarnings = FALSE)
dir.create("R", showWarnings = FALSE)

cat("R", R.version$major, ".", R.version$minor, " | collation: ",
    Sys.getlocale("LC_COLLATE"), "\n", sep = "")
cat("Live R session ready. Waiting for steps...\n")

repeat {
  steps <- sort(list.files("queue", pattern = "\\.R$", full.names = TRUE))
  for (f in steps) {
    cat("\n\n==================== ", basename(f), " ====================\n", sep = "")
    t0 <- Sys.time()
    tryCatch(
      source(f, echo = TRUE, max.deparse.length = Inf, spaced = TRUE,
             keep.source = TRUE, local = globalenv()),
      error = function(e) cat("\n*** ERROR:", conditionMessage(e), "\n")
    )
    file.rename(f, file.path("R", basename(f)))
    cat(sprintf("\n---- finished %s in %.1f s ----\n", basename(f),
                as.numeric(difftime(Sys.time(), t0, units = "secs"))))
  }
  Sys.sleep(1)
}
