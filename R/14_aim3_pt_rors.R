# ---- Step 14: Aim 3 support (new work) --------------------------------------
# Age RORs (older vs younger) for key PT groups named in the spec, using the
# same 2x2 method, plus the FAERS product mix by age (indication proxy).
dat$pt_upper <- toupper(dat$pt)
older <- as.integer(dat$age_group == "Older Adults (≥65)")

pt_groups <- list(
  "Pancreatitis" = c("PANCREATITIS", "PANCREATITIS ACUTE", "PANCREATITIS NECROTISING"),
  "Gallbladder" = c("CHOLELITHIASIS", "CHOLECYSTITIS"),
  "Hypoglycaemia" = c("HYPOGLYCAEMIA", "BLOOD GLUCOSE DECREASED"),
  "Ileus/obstruction/gastric emptying" = c("ILEUS", "INTESTINAL OBSTRUCTION", "IMPAIRED GASTRIC EMPTYING"),
  "Nausea/vomiting/diarrhoea/constipation" = c("NAUSEA", "VOMITING", "DIARRHOEA", "CONSTIPATION"),
  "Suicidal ideation/behaviour" = c("SUICIDAL IDEATION", "SUICIDE ATTEMPT", "COMPLETED SUICIDE",
                                    "SELF-INJURIOUS IDEATION"),
  "Heart rate increased/tachycardia" = c("HEART RATE INCREASED", "TACHYCARDIA", "SINUS TACHYCARDIA"),
  "Dehydration" = "DEHYDRATION",
  "Diabetic ketoacidosis" = c("DIABETIC KETOACIDOSIS", "EUGLYCAEMIC DIABETIC KETOACIDOSIS"))

pt_rors <- bind_rows(lapply(names(pt_groups), function(g)
  cbind(pt_group = g, ror_prr(older, as.integer(dat$pt_upper %in% pt_groups[[g]]))))) %>%
  mutate(notable = ROR_lower > 1 | ROR_upper < 1)
pt_rors %>% transmute(pt_group, a, c, ROR = round(ROR, 2),
                      CI = sprintf("%.2f-%.2f", ROR_lower, ROR_upper), notable)
fwrite(pt_rors, file.path(proj_dir, "aim3", "faers_key_pt_age_rors.csv"))

mix <- as.data.table(dat)[, .N, by = .(age_group, drug_standardized)][
  , pct := round(100 * N / sum(N), 1), by = age_group][order(age_group, -N)]
mix
fwrite(mix, file.path(proj_dir, "aim3", "faers_product_mix_by_age.csv"))
cat("\n*** All steps finished. ***\n")
