# ---- Step 05: age (Figure 1 "After cleaning age variable") ------------------
# Age is used AS REPORTED: age_cod is ignored, so months/decades are not
# converted to years (an unusual decision the spec says to reproduce).
table(dedup$age_cod, useNA = "ifany")
summary(dedup$age)

# age_group: labels created in capitals, then relabelled by factor()
dedup <- dedup %>%
  mutate(
    age_group = case_when(
      age >= 65            ~ "OLDER ADULTS (≥65)",
      age >= 18 & age < 65 ~ "YOUNGER ADULTS (18–64)",
      TRUE                 ~ NA_character_
    ),
    age_group = factor(age_group,
                       levels = c("YOUNGER ADULTS (18–64)", "OLDER ADULTS (≥65)"),
                       labels = c("Younger Adults (18–64)", "Older Adults (≥65)")),
    # Dates parsed with %Y%m%d; dropped later, not used in the analysis
    event_dt = as.Date(as.character(event_dt), format = "%Y%m%d"),
    rept_dt  = as.Date(as.character(rept_dt),  format = "%Y%m%d")
  )

# Why rows will drop: missing, under 18, over 120
c(missing = sum(is.na(dedup$age)),
  under_18 = sum(dedup$age < 18, na.rm = TRUE),
  over_120 = sum(dedup$age > 120, na.rm = TRUE))

cohort <- dedup %>% filter(!is.na(age) & age >= 18 & age <= 120)
table(cohort$age_group, useNA = "ifany")

checkpoint(3, "After cleaning age variable", nrow(cohort))

# Placeholder text -> NA (after the age filter, factor columns only).
# "UNK" is deliberately NOT on the list.
placeholders <- c("", "NA", "N/A", "NULL", "NONE", "MISSING", "UNKNOWN", "NOT AVAILABLE")
clean_placeholder <- function(x) {
  x <- str_squish(toupper(as.character(x)))
  x[x %in% placeholders] <- NA
  x
}
cohort <- cohort %>%
  mutate(across(c(sex, reporter_country, occr_country, outc_cod, role_cod, quarter),
                clean_placeholder))
table(cohort$sex, useNA = "ifany")
table(cohort$role_cod, useNA = "ifany")

cat("\n*** PAUSED at checkpoint 3. Waiting for the go-ahead before the primary-suspect step. ***\n")
