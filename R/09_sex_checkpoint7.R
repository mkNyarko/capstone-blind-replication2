# ---- Step 09: sex (Figure 1 "Final analytic sample") ------------------------
# sex was set to factor(levels = M, F, UNK) in step 07, so "" became NA.
table(dat$sex, useNA = "ifany")

dat <- dat %>% filter(!is.na(sex) & sex != "UNK")

# Relabel after unknowns are removed; Male is the reference
dat <- dat %>% mutate(sex = factor(as.character(sex), levels = c("M", "F"),
                                   labels = c("Male", "Female")))
table(dat$sex)
table(dat$age_group, dat$sex)

checkpoint(7, "Final analytic sample", nrow(dat))
checkpoints
cat("\n*** PAUSED at checkpoint 7 (final sample). Next: derived variables and model reference levels. ***\n")
