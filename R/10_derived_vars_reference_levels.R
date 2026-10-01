# ---- Step 10: derived variables and model reference levels ------------------

# Event category from the single PT kept per report.
# PTs are sentence case in FAERS ("Nausea"), so toupper() before exact matching.
head(dat$pt, 5)

psych_pts <- c("ANXIETY", "DEPRESSION", "DEPRESSED MOOD", "MAJOR DEPRESSION",
  "SUICIDAL IDEATION", "SUICIDE ATTEMPT", "COMPLETED SUICIDE", "PANIC ATTACK",
  "INSOMNIA", "SLEEP DISORDER", "NIGHTMARE", "HALLUCINATION",
  "HALLUCINATION, AUDITORY", "DELUSION", "AGITATION", "IRRITABILITY",
  "MOOD ALTERED", "MOOD SWINGS", "APATHY", "ANHEDONIA", "CONFUSIONAL STATE",
  "MEMORY IMPAIRMENT", "DISTURBANCE IN ATTENTION", "MENTAL DISORDER",
  "NERVOUSNESS", "STRESS", "SELF-INJURIOUS IDEATION", "PSYCHOTIC BEHAVIOUR",
  "EUPHORIC MOOD", "HYPOMANIA")
cv_pts <- c("CARDIAC ARREST", "CARDIAC FAILURE", "CARDIAC FAILURE CONGESTIVE",
  "ATRIAL FIBRILLATION", "ARRHYTHMIA", "TACHYCARDIA", "BRADYCARDIA",
  "SINUS TACHYCARDIA", "MYOCARDIAL INFARCTION", "PALPITATIONS",
  "HYPERTENSION", "HYPOTENSION", "CEREBROVASCULAR ACCIDENT",
  "ISCHAEMIC STROKE", "EMBOLIC STROKE", "TRANSIENT ISCHAEMIC ATTACK",
  "DEEP VEIN THROMBOSIS", "PULMONARY EMBOLISM", "CORONARY ARTERY OCCLUSION",
  "HEART RATE INCREASED", "HEART RATE DECREASED", "SYNCOPE", "PRESYNCOPE")
gi_pts <- c("NAUSEA", "VOMITING", "DIARRHOEA", "CONSTIPATION",
  "ABDOMINAL PAIN", "ABDOMINAL PAIN UPPER", "ABDOMINAL PAIN LOWER",
  "DYSPEPSIA", "GASTROOESOPHAGEAL REFLUX DISEASE", "ILEUS",
  "INTESTINAL OBSTRUCTION", "IMPAIRED GASTRIC EMPTYING", "PANCREATITIS",
  "PANCREATITIS ACUTE", "PANCREATITIS NECROTISING", "CHOLELITHIASIS",
  "CHOLECYSTITIS", "DECREASED APPETITE", "INCREASED APPETITE",
  "WEIGHT DECREASED", "ABNORMAL LOSS OF WEIGHT", "HYPOGLYCAEMIA",
  "HYPERGLYCAEMIA", "DIABETIC KETOACIDOSIS",
  "EUGLYCAEMIC DIABETIC KETOACIDOSIS", "BLOOD GLUCOSE INCREASED",
  "BLOOD GLUCOSE DECREASED", "HEPATIC ENZYME INCREASED",
  "DRUG-INDUCED LIVER INJURY", "MALNUTRITION", "DEHYDRATION")
ev_levels <- c("Others", "Gastro-Intestinal and Metabolic", "Cardiovascular",
               "Psychiatric-related")

dat <- dat %>%
  mutate(
    pt_upper = toupper(pt),
    # First match wins: Psychiatric, then Cardiovascular, then GI/Metabolic
    event_category = case_when(
      pt_upper %in% psych_pts ~ "Psychiatric-related",
      pt_upper %in% cv_pts    ~ "Cardiovascular",
      pt_upper %in% gi_pts    ~ "Gastro-Intestinal and Metabolic",
      TRUE                    ~ "Others"),
    event_category = factor(event_category, levels = ev_levels),
    # Weight and dose as reported (wt_cod and dose_unit ignored), missing -> "Missing"
    wt_cat = case_when(is.na(wt) ~ "Missing", wt < 80 ~ "<80 kg",
                       wt < 100 ~ "80–99 kg", TRUE ~ "≥100 kg"),
    dose_cat = case_when(is.na(dose_amt) ~ "Missing", dose_amt < 0.5 ~ "<0.5 mg",
                         dose_amt < 1 ~ "0.5–0.99 mg", TRUE ~ "≥1 mg"),
    dose_cat_alt = case_when(dose_amt < 0.5 ~ "Low dose",
                             dose_amt >= 0.5 & dose_amt < 1 ~ "Medium dose",
                             dose_amt >= 1 ~ "High dose", TRUE ~ "Missing"),
    quarter = factor(quarter, levels = c("2024Q1", "2024Q2", "2024Q3", "2024Q4")),
    outc_cod_full = factor(outc_cod, levels = c("DE", "LT", "HO", "DS", "RI", "OT"),
      labels = c("Death", "Life-threatening", "Hospitalization", "Disability",
                 "Required intervention", "Other serious outcome")),
    # Descriptive only (Table 1): first matching rule wins, then Title Case
    drug_upper = toupper(drugname),
    drug_standardized = str_to_title(case_when(
      str_detect(drug_upper, "SEMAGLUTIDE") &
        str_detect(drug_upper, "CYANOCOBALAMIN|\\+|/|\\\\") ~ "COMBINATION PRODUCT",
      str_detect(drug_upper, "OZEMPIC")     ~ "OZEMPIC",
      str_detect(drug_upper, "WEGOVY")      ~ "WEGOVY",
      str_detect(drug_upper, "RYBELSUS")    ~ "RYBELSUS",
      str_detect(drug_upper, "SEMAGLUTIDE") ~ "SEMAGLUTIDE (UNSPECIFIED)",
      TRUE                                  ~ "OTHER"))
  )

table(dat$event_category)
table(dat$wt_cat)
table(dat$dose_cat)
table(dat$drug_standardized)

fwrite(dat %>% select(-pt_upper, -drug_upper), file.path(data_dir, "faers_sema_analytic.csv"))

# CHECKPOINT: reference levels. dose_cat and wt_cat stay character and become
# factors inside the model, so as.factor() (collation-dependent) picks the reference.
Sys.getlocale("LC_COLLATE")
ref_levels <- data.frame(
  variable  = c("event_category (outcome)", "age_group", "sex", "quarter", "dose_cat", "wt_cat"),
  reference = c(levels(dat$event_category)[1], levels(dat$age_group)[1], levels(dat$sex)[1],
                levels(dat$quarter)[1], levels(as.factor(dat$dose_cat))[1],
                levels(as.factor(dat$wt_cat))[1]))
ref_levels
levels(as.factor(dat$dose_cat))
levels(as.factor(dat$wt_cat))
fwrite(ref_levels, file.path(log_dir, "reference_levels.csv"))

cat("\n*** PAUSED at the reference-level checkpoint. Next: Table 1 and ROR/PRR. ***\n")
