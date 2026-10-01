# ---- Step 02: Q2-Q4 per-quarter case files ----------------------------------
# Same operations as step 01, wrapped in a function. Spec step 6: in Q4 only,
# semaglutide DRUG rows are cut to the first row per caseid before the join.
process_quarter <- function(q) {
  drug <- fread(quarter_file(q, "DRUG"), sep = "$")
  demo <- fread(quarter_file(q, "DEMO"), sep = "$")
  reac <- fread(quarter_file(q, "REAC"), sep = "$")
  outc <- fread(quarter_file(q, "OUTC"), sep = "$")
  sema <- drug[grepl("SEMAGLUTIDE|OZEMPIC|WEGOVY|RYBELSUS", drugname, ignore.case = TRUE) |
               grepl("SEMAGLUTIDE", prod_ai, ignore.case = TRUE)]
  ids  <- unique(sema$caseid)
  demo_us <- demo[caseid %in% ids][reporter_country == "US"]
  reac <- reac[caseid %in% ids]
  outc <- outc[caseid %in% ids]
  if (q == "Q4") sema <- sema[!duplicated(caseid)]
  m <- merge(demo_us, outc, by = "caseid", all.x = TRUE)
  m <- merge(m, reac, by = "caseid", all.x = TRUE)
  m <- suppressWarnings(merge(m, sema, by = "caseid", all.x = TRUE))  # duplicate primaryid names, expected
  names(m) <- make.unique(names(m))
  m <- as.data.frame(m)
  m <- m[, setdiff(names(m), c("primaryid.x.1", "primaryid.y.1"))]
  out <- m %>%
    mutate(rank = unname(outc_rank[outc_cod])) %>%
    group_by(caseid) %>%
    slice_min(rank, n = 1, with_ties = FALSE) %>%
    ungroup()
  fwrite(out, file.path(int_dir, sprintf("faers_sema_2024%s.csv", q)))
  cat(sprintf("2024%s: %s semaglutide drug rows | %s cases | %s US case rows (one per case: %s)\n",
              q, format(nrow(sema), big.mark = ","), format(length(ids), big.mark = ","),
              format(nrow(out), big.mark = ","), length(unique(out$caseid)) == nrow(out)))
  invisible(out)
}

# Check: the function reproduces the step-01 Q1 result
nrow(process_quarter("Q1")) == nrow(q1)

for (q in c("Q2", "Q3", "Q4")) process_quarter(q)
rm(drug, demo, reac, outc, sema, m); invisible(gc())
