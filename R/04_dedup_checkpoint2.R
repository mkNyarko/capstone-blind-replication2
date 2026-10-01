# ---- Step 04: deduplicate (Figure 1 "After deduplication") -----------------
# Keep each case's row from the LATEST quarter it appears in.
# quarter is compared as a character string; caseversion is not used.

# How many cases appear in more than one quarter?
table(table(stacked$caseid))

dedup <- stacked %>%
  group_by(caseid) %>%
  slice_max(quarter, n = 1, with_ties = FALSE) %>%
  ungroup()

nrow(stacked) - nrow(dedup)            # rows removed as duplicates
length(unique(dedup$caseid)) == nrow(dedup)
table(dedup$quarter)

# Keep only the columns the spec lists
keep_cols <- c("caseid", "caseversion", "age", "age_cod", "sex", "wt", "wt_cod",
               "reporter_country", "occr_country", "drugname", "prod_ai",
               "dose_amt", "dose_unit", "role_cod", "pt", "outc_cod",
               "event_dt", "rept_dt", "quarter")
dedup <- dedup %>% select(all_of(keep_cols))
dim(dedup)

checkpoint(2, "After deduplication", nrow(dedup))
cat("\n*** PAUSED at checkpoint 2. Waiting for the go-ahead before the age step. ***\n")
