# ---- Step 08: congenital anomaly (Figure 1 "After excluding congenital anomaly")
# Keep only DE, HO, LT, DS, OT, RI -- this drops CA.
dat %>% filter(outc_cod == "CA") %>% select(caseid, age, sex, pt, drugname)

dat <- dat %>% filter(outc_cod %in% c("DE", "HO", "LT", "DS", "OT", "RI"))
table(dat$outc_cod)

checkpoint(6, "After excluding congenital anomaly", nrow(dat))
cat("\n*** PAUSED at checkpoint 6. Waiting for the go-ahead before the sex step (final sample). ***\n")
