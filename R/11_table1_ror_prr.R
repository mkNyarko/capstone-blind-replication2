# ---- Step 11: Table 1 and ROR/PRR --------------------------------------------

# Table 1: by age group plus overall, n (%) with column percentages, missing = "no"
tbl1 <- dat %>%
  select(age_group, sex, wt_cat, dose_cat, drug_standardized, quarter,
         event_category, outc_cod_full) %>%
  tbl_summary(
    by = age_group,
    statistic = all_categorical() ~ "{n} ({p}%)",
    missing = "no",
    label = list(sex ~ "Sex", wt_cat ~ "Weight category", dose_cat ~ "Dose category",
                 drug_standardized ~ "Drug (standardized)", quarter ~ "Quarter of report",
                 event_category ~ "Adverse event category",
                 outc_cod_full ~ "Outcome category")) %>%
  add_overall()
tbl1_df <- as_tibble(tbl1, col_labels = FALSE)
print(tbl1_df, n = Inf, width = 120)

gt::gtsave(as_gt(tbl1), file.path(tab_dir, "table1_descriptives.html"))
flextable::save_as_docx(as_flex_table(tbl1), path = file.path(tab_dir, "table1_descriptives.docx"))
fwrite(tbl1_df, file.path(tab_dir, "table1_descriptives.csv"))

# ROR and PRR: one 2x2 table per exposure x event.
# a = exposed with event, b = exposed without, c = unexposed with, d = unexposed without.
# Wald 95% CI on log ROR, no continuity correction; PRR is a point estimate only.
ror_prr <- function(exposure, event) {
  tab <- table(factor(exposure, levels = c(1, 0)), factor(event, levels = c(1, 0)))
  if (!all(dim(tab) == c(2, 2))) return(NULL)
  a <- tab[1, 1]; b <- tab[1, 2]; c <- tab[2, 1]; d <- tab[2, 2]
  ror <- (a * d) / (b * c)
  se  <- sqrt(1 / a + 1 / b + 1 / c + 1 / d)
  data.frame(a = a, b = b, c = c, d = d, ROR = ror,
             ROR_lower = exp(log(ror) - 1.96 * se),
             ROR_upper = exp(log(ror) + 1.96 * se),
             PRR = (a / (a + b)) / (c / (c + d)))
}

exposures <- list(
  "Age (Older vs Younger)" = as.integer(dat$age_group == "Older Adults (≥65)"),
  "Sex (Female vs Male)"   = as.integer(dat$sex == "Female"))
events <- c("Gastro-Intestinal and Metabolic", "Cardiovascular", "Psychiatric-related")

# Each event is compared against ALL other categories, including Others
ror_tab <- bind_rows(lapply(names(exposures), function(ex)
  bind_rows(lapply(events, function(ev)
    cbind(comparison = ex, event_category = ev,
          ror_prr(exposures[[ex]], as.integer(dat$event_category == ev))))))) %>%
  mutate(notable = ROR_lower > 1 | ROR_upper < 1)   # notable = CI excludes 1

ror_tab %>% mutate(across(ROR:PRR, ~ round(.x, 2)))
fwrite(ror_tab, file.path(tab_dir, "ror_prr.csv"))

cat("\n*** PAUSED after Table 1 and ROR/PRR. Next: main multinomial model, fit, interaction test. ***\n")
