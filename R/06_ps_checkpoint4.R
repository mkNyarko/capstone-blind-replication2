# ---- Step 06: primary suspect (Figure 1 "Primary Suspect (PS)") ------------
# role_cod comes from the single semaglutide drug row kept for each case.
cohort <- cohort %>% filter(toupper(role_cod) == "PS")
table(cohort$role_cod)
table(cohort$age_group)

checkpoint(4, "Primary Suspect (PS)", nrow(cohort))

# End of the cleaning half: drop the (unused) dates and save the cleaned file.
# The analysis half reads this CSV back in, as the original did.
cohort <- cohort %>% select(-event_dt, -rept_dt)
fwrite(cohort, file.path(data_dir, "faers_sema_cleaned_steps1to4.csv"))
dim(cohort)

cat("\n*** PAUSED at checkpoint 4 (cleaning complete). Waiting for the go-ahead before the outcome step. ***\n")
