# ---- Step 07: outcome (Figure 1 "After outcome cleaning") ------------------
# Start of the analysis half: read the cleaned file back in (CSV round-trip).
dat <- fread(file.path(data_dir, "faers_sema_cleaned_steps1to4.csv"))
nrow(dat)

# After the round-trip, "no OUTC record" comes back as "" rather than NA:
table(dat$outc_cod, useNA = "ifany")
c(empty_string = sum(dat$outc_cod == "", na.rm = TRUE), true_NA = sum(is.na(dat$outc_cod)))

# Spec: no OUTC record (non-serious report) -> "NR". Treat "" and NA alike.
dat <- dat %>%
  mutate(outc_cod = ifelse(is.na(outc_cod) | outc_cod == "", "NR", outc_cod),
         sex = factor(sex, levels = c("M", "F", "UNK")),
         age_group = factor(age_group, levels = c("Younger Adults (18–64)",
                                                  "Older Adults (≥65)")))
table(dat$outc_cod)

# Drop NR (and "Other", which never occurs). OT is kept.
dat <- dat %>% filter(!outc_cod %in% c("NR", "Other"))
table(dat$outc_cod)

checkpoint(5, "After outcome cleaning", nrow(dat))
cat("\n*** PAUSED at checkpoint 5. Waiting for the go-ahead before the congenital-anomaly step. ***\n")
