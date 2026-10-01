# ---- Step 03: read quarters back and stack (Figure 1 "Raw data") -----------
# CSV round-trip (fwrite -> fread) re-infers column types, as in the original.
quarters <- c("Q1", "Q2", "Q3", "Q4")
stacked <- rbindlist(lapply(quarters, function(q) {
  d <- fread(file.path(int_dir, sprintf("faers_sema_2024%s.csv", q)))
  d[, quarter := paste0("2024", q)]
  d
}), use.names = TRUE, fill = TRUE)

table(stacked$quarter)
sapply(stacked[, .(age, wt, dose_amt, sex, outc_cod)], class)   # types after round-trip

checkpoint(1, "Raw data (4 quarters combined)", nrow(stacked))
cat("\n*** PAUSED at checkpoint 1. Waiting for the go-ahead before deduplication. ***\n")
