# Builds report/Replication2_Process_Report.docx from the run-2 outputs.
# From the BLIND_REPLICATION_2 folder:  LC_ALL=en_US.UTF-8 Rscript report/make_process_report.R
suppressPackageStartupMessages({
  library(officer); library(flextable); library(data.table); library(dplyr)
})

out_file <- file.path("report", "Replication2_Process_Report.docx")
tab <- function(f) fread(file.path("output", "tables", f))

# ---- Styling helpers ----------------------------------------------------------
font <- "Arial"
set_flextable_defaults(font.family = font, font.size = 9.5, padding = 3,
                       border.color = "#BFBFBF")
ft <- function(df, widths = NULL, header_fill = "#1F3864") {
  x <- flextable(as.data.frame(df)) %>%
    theme_vanilla() %>%
    bg(part = "header", bg = header_fill) %>%
    color(part = "header", color = "white") %>%
    bold(part = "header") %>%
    align(align = "left", part = "all") %>%
    valign(valign = "top", part = "all")
  if (!is.null(widths)) x <- width(x, width = widths) else x <- autofit(x)
  x
}
p_txt <- function(..., bold_lead = NULL) {
  runs <- list()
  if (!is.null(bold_lead))
    runs <- c(runs, list(ftext(bold_lead, fp_text(bold = TRUE, font.family = font, font.size = 11))))
  runs <- c(runs, list(ftext(paste0(...), fp_text(font.family = font, font.size = 11))))
  do.call(fpar, c(runs, list(fp_p = fp_par(padding.bottom = 6, line_spacing = 1.1))))
}
add_p   <- function(doc, ..., bold_lead = NULL) body_add_fpar(doc, p_txt(..., bold_lead = bold_lead))
add_h1  <- function(doc, x) body_add_par(doc, x, style = "heading 1")
add_h2  <- function(doc, x) body_add_par(doc, x, style = "heading 2")
add_cap <- function(doc, x) body_add_fpar(doc, fpar(ftext(x, fp_text(italic = TRUE, font.size = 9,
                                          font.family = font, color = "#595959")),
                                          fp_p = fp_par(padding.bottom = 10)))
add_code <- function(doc, x) body_add_fpar(doc, fpar(ftext(x, fp_text(font.family = "Courier New",
                                           font.size = 9)), fp_p = fp_par(padding.left = 12,
                                           padding.bottom = 8, shading.color = "#F2F2F2")))
fmt_ci <- function(est, lo, hi) sprintf("%.2f (%.2f–%.2f)", est, lo, hi)

# ---- Data from the run --------------------------------------------------------
cp   <- fread(file.path("output", "logs", "checkpoints.csv"))
refl <- fread(file.path("output", "logs", "reference_levels.csv"))
ror  <- tab("ror_prr.csv")
age  <- tab("multinom_main_age_group.csv")
fit  <- tab("multinom_main_fit_pR2.csv")
lrt  <- tab("interaction_lrt.csv")
sens <- tab("sensitivity_age_group.csv")
t1   <- tab("table1_descriptives.csv")
ptr  <- fread(file.path("aim3", "faers_key_pt_age_rors.csv"))
fitv <- setNames(fit$value, fit$statistic)

# ---- Document -----------------------------------------------------------------
footer <- block_list(fpar(ftext("FAERS Semaglutide Blind Replication 2 · page ",
                                fp_text(font.size = 8, color = "#7F7F7F", font.family = font)),
                          run_word_field("PAGE", prop = fp_text(font.size = 8, color = "#7F7F7F")),
                          fp_p = fp_par(text.align = "right")))
sect <- prop_section(page_size = page_size(width = 8.5, height = 11, orient = "portrait"),
                     page_margins = page_mar(top = 1, bottom = 1, left = 1, right = 1,
                                             header = 0.5, footer = 0.5),
                     footer_default = footer)
doc <- read_docx() %>% body_set_default_section(sect)

# Title block
doc <- doc %>%
  body_add_fpar(fpar(ftext("FAERS 2024 Semaglutide Capstone",
                           fp_text(font.size = 22, bold = TRUE, color = "#1F3864", font.family = font)))) %>%
  body_add_fpar(fpar(ftext("Blind Replication 2: step-by-step process record",
                           fp_text(font.size = 15, color = "#2E75B6", font.family = font)),
                     fp_p = fp_par(padding.bottom = 4))) %>%
  body_add_fpar(fpar(ftext("Prepared for Maxwell Nyarko · Run date 1 October 2026 · R 4.4.1",
                           fp_text(font.size = 10, color = "#595959", font.family = font)),
                     fp_p = fp_par(padding.bottom = 14)))

# 1. Summary
doc <- add_h1(doc, "Summary")
doc <- add_p(doc, "This document records how the FAERS 2024 semaglutide analysis was rebuilt a second time ",
             "from the raw FDA quarterly files, one step at a time, in an R session you could watch in the ",
             "Terminal panel. The run paused at every checkpoint the replication spec defines, so each ",
             "row count and the model reference levels could be reviewed before the next step began.")
doc <- add_p(doc, "Final analytic sample: 2,427 US reports in which semaglutide was the primary suspect drug. ",
             "Every checkpoint count and every estimate is identical to the first blind replication ",
             "(Blind Replication 1), and the analytic dataset is byte-for-byte identical. The pipeline ",
             "therefore gives the same answer when built twice from the spec.", bold_lead = "Result. ")
key <- data.frame(
  Item = c("Final analytic sample", "Older vs younger: GI and metabolic (adjusted OR)",
           "Older vs younger: Cardiovascular (adjusted OR)", "Older vs younger: Psychiatric (adjusted OR)",
           "Age × sex interaction (LRT)", "Model fit (McFadden pseudo-R²)"),
  Value = c("n = 2,427",
            fmt_ci(age$OR[1], age$OR_lower[1], age$OR_upper[1]),
            fmt_ci(age$OR[2], age$OR_lower[2], age$OR_upper[2]),
            fmt_ci(age$OR[3], age$OR_lower[3], age$OR_upper[3]),
            sprintf("χ² = %.2f, df = 3, p = %.2f", lrt[[6]][2], lrt[[7]][2]),
            sprintf("%.3f", fitv["McFadden"])))
doc <- body_add_flextable(doc, ft(key, widths = c(3.8, 2.7)))
doc <- add_cap(doc, "Table 1. Headline results. Reference outcome = Others; reference age group = 18–64.")

# 2. Inputs and ground rules
doc <- add_h1(doc, "Inputs and ground rules")
doc <- add_p(doc, "Only the three items connected to the session were used: the replication spec ",
             "(FAERS_Semaglutide_Replication_Spec.pdf, 30 September 2026), the Aims and Methods extract ",
             "(for reference; the spec wins where they differ) and the FAERS_DATA_2024 folder.",
             bold_lead = "Materials. ")
doc <- add_p(doc, "The original R Markdown code, results, Figure 1 counts and the original GitHub repository ",
             "were not seen, as the spec requires. Information from earlier chats was not used. At the very ",
             "start of the session, before these ground rules were set, folder and file names under Documents ",
             "were listed to locate the project; no files were opened. After the rules were set, nothing outside ",
             "the connected items and the output folders was accessed.", bold_lead = "Blind conditions. ")
doc <- add_p(doc, "Local folder: CAPSTONE AUTOMATION/BLIND_REPLICATION_2. GitHub (private): ",
             "github.com/mkNyarko/capstone-blind-replication2. The first run is kept separately in ",
             "BLIND_REPLICATION_1 and github.com/mkNyarko/capstone-blind-replication1.",
             bold_lead = "Where outputs live. ")

# 3. Environment
doc <- add_h1(doc, "Computational environment")
env <- data.frame(
  Setting = c("R", "Platform", "Locale (collation)", "Time zone", "Key packages",
              "Package match with spec", "Seeds"),
  Value = c("4.4.1 (2024-06-14)", "x86_64-apple-darwin20, macOS 15.7.9", "en_US.UTF-8",
            "America/New_York",
            "data.table 1.17.0, dplyr 1.1.4, nnet 7.3-19, broom 1.0.11, pscl 1.5.9, gtsummary 2.4.0, ggplot2 4.0.0",
            "All 21 packages listed in the spec matched exactly",
            "None needed (multinom starts from zero weights; slice_* use with_ties = FALSE)"))
doc <- body_add_flextable(doc, ft(env, widths = c(1.9, 4.6)))
doc <- add_cap(doc, "Table 2. Environment. Full sessionInfo() is in output/logs/sessionInfo.txt.")

# 4. How the run worked
doc <- add_h1(doc, "How the step-by-step run worked")
doc <- add_p(doc, "A single R session (watch_steps.R) was started in a Terminal tab named ",
             "“R replication 2”. Each step was written as a numbered R file and placed in a queue/ ",
             "folder. The session picked it up, ran it with every line of code and its comments echoed, ",
             "printed the output, and then filed the step under R/. Data stayed in memory between steps, ",
             "so each step continued from the last.", bold_lead = "Live session. ")
doc <- add_p(doc, "The run stopped after each of the seven cohort checkpoints and after the reference-level ",
             "checkpoint, and waited for a “go” before continuing. The analysis half was run in three ",
             "further steps with a pause after each.", bold_lead = "Pauses. ")
doc <- add_p(doc, "The session was restarted once, after the setup step, because Rscript strips comments ",
             "from echoed code. Adding keep.source = TRUE made the terminal show the code exactly as ",
             "written. No data had been processed at that point.", bold_lead = "One restart. ")
doc <- add_p(doc, "The 15 step files run end to end, with the same echoed output, using:",
             bold_lead = "Replay. ")
doc <- add_code(doc, "LC_ALL=en_US.UTF-8 Rscript run_all.R")

# 5. Step log
doc <- add_h1(doc, "Step log")
steps <- data.frame(
  Step = sprintf("%02d", 0:14),
  `What ran` = c(
    "Setup: packages, paths, checkpoint tracker",
    "2024Q1 walkthrough: import DRUG/DEMO/REAC/OUTC; semaglutide rows; case list; US filter; three left joins; make.unique; collapse to one row per case (most severe outcome); write CSV",
    "Same logic as a function, checked against Q1; Q2–Q4 (Q4: first semaglutide drug row per case)",
    "Read quarters back (CSV round-trip), stack",
    "Deduplicate: latest quarter per caseid; keep 19 spec columns",
    "Age group (capital labels, relabelled); age filter 18–120; placeholder text → NA",
    "Primary suspect filter; save cleaned file",
    "Read cleaned file back; no OUTC record → NR; drop NR",
    "Drop congenital anomaly (CA)",
    "Drop missing/UNK sex; relabel Male/Female",
    "Event categories, weight/dose categories, drug_standardized; reference levels",
    "Table 1; ROR/PRR (6 pairs)",
    "Main multinomial model; pseudo-R²; age × sex likelihood ratio test",
    "Sensitivity models S1–S4; Figures 2–4",
    "Aim 3 support: key-PT age RORs; product mix by age"),
  `Key output` = c(
    "Package versions confirmed",
    "7,307 drug rows → 5,943 cases → 4,935 US cases",
    "Q2 2,101 · Q3 7,344 · Q4 2,901 US cases",
    "Checkpoint 1: 17,281",
    "Checkpoint 2: 15,971",
    "Checkpoint 3: 8,067",
    "Checkpoint 4: 5,302",
    "Checkpoint 5: 2,604",
    "Checkpoint 6: 2,601",
    "Checkpoint 7: 2,427",
    "dose_cat ref <0.5 mg; wt_cat ref <80 kg",
    "Table 1 (.html/.docx/.csv); ror_prr.csv",
    "Converged (code 0); LRT p = 0.85",
    "Sensitivity tables; 3 PNG figures",
    "faers_key_pt_age_rors.csv; product mix"),
  check.names = FALSE)
doc <- body_add_flextable(doc, ft(steps, widths = c(0.5, 3.9, 2.1)))
doc <- add_cap(doc, "Table 3. The 15 steps, as filed in R/.")

# 6. Cohort checkpoints
doc <- add_h1(doc, "Cohort checkpoints")
doc <- add_p(doc, "Before the first Figure 1 box, each quarter was already restricted to semaglutide ",
             "reports, US reporter_country, and one row per case. Counts after each spec step:")
cpt <- cp %>% mutate(Removed = c(NA, -diff(n))) %>%
  transmute(`#` = step, `Figure 1 box` = figure1_box, n = format(n, big.mark = ","),
            Removed = ifelse(is.na(Removed), "—", format(Removed, big.mark = ",")))
cpt$`What was removed` <- c(
  "Stacked per-quarter files (Q1 4,935; Q2 2,101; Q3 7,344; Q4 2,901)",
  "Cases in more than one quarter: 1,172 in two, 60 in three, 6 in four",
  "Missing age 7,867; under 18: 34; over 120: 3",
  "Concomitant 2,131; secondary suspect 631; interacting 3",
  "No OUTC record (non-serious): 2,698",
  "Congenital anomaly: 3",
  "Missing sex 171; UNK 3")
doc <- body_add_flextable(doc, ft(cpt, widths = c(0.3, 1.9, 0.7, 0.7, 2.9)))
doc <- add_cap(doc, "Table 4. Checkpoint counts, for comparison with Figure 1.")
doc <- add_p(doc, "Age was used as reported, with age_cod ignored, as the spec instructs. About 15 reports ",
             "carried decade, month, week or day codes; a value such as 6 decades is read as age 6 and ",
             "dropped. The largest raw age, 25,256, is almost certainly in days.",
             bold_lead = "Age rule in practice. ")
doc <- add_p(doc, "After the CSV round-trip, all 2,698 missing outcome codes came back as empty strings, not ",
             "NA. Both were recoded to NR and dropped at step 5. If the original code recoded only NA, its ",
             "box 5 would read 5,302 and these reports would instead drop at box 6; the final sample would ",
             "be unchanged.", bold_lead = "Checkpoint 5 note. ")

# 7. Reference levels
doc <- add_h1(doc, "Model reference levels")
rl <- refl %>% transmute(Factor = variable, Reference = reference,
                         `How set` = ifelse(variable %in% c("dose_cat", "wt_cat"),
                                            "as.factor(), en_US.UTF-8 collation", "Set explicitly"))
doc <- body_add_flextable(doc, ft(rl, widths = c(2.0, 2.0, 2.5)))
doc <- add_cap(doc, paste0("Table 5. Sort order chosen by R: dose_cat <0.5 mg, ≥1 mg, 0.5–0.99 mg, Missing; ",
                           "wt_cat <80 kg, ≥100 kg, 80–99 kg, Missing. Sensitivity 4 (relabelled dose): High dose."))

# 8. Results
doc <- add_h1(doc, "Results")
doc <- add_h2(doc, "Descriptive table (Table 1)")
t1d <- t1 %>% mutate(across(everything(), ~ ifelse(is.na(.x), "", .x)))
names(t1d) <- c("Characteristic", "Overall (n = 2,427)", "Younger 18–64 (n = 1,460)", "Older ≥65 (n = 967)")
t1f <- ft(t1d, widths = c(2.6, 1.3, 1.3, 1.3))
hdr_rows <- which(t1d[[2]] == "")
t1f <- bold(t1f, i = hdr_rows, j = 1) %>% bg(i = hdr_rows, bg = "#DEEAF6")
doc <- body_add_flextable(doc, t1f)
doc <- add_cap(doc, "Table 6. Characteristics by age group (the capstone's Table 1), n (%), column percentages.")

doc <- add_h2(doc, "Disproportionality (ROR and PRR)")
rt <- ror %>% transmute(Comparison = comparison, Event = event_category,
                        `a / c` = paste(a, "/", c),
                        `ROR (95% CI)` = fmt_ci(ROR, ROR_lower, ROR_upper),
                        PRR = sprintf("%.2f", PRR), `CI excludes 1` = ifelse(notable, "Yes", "No"))
doc <- body_add_flextable(doc, ft(rt, widths = c(1.5, 1.8, 0.8, 1.3, 0.5, 0.6)))
doc <- add_cap(doc, "Table 7. Each event vs all other categories (including Others), within semaglutide reports. Wald 95% CI, no continuity correction.")
doc <- body_add_img(doc, file.path("output", "figures", "figure3_forest_age_sex.png"), width = 6.3, height = 3.94)
doc <- add_cap(doc, "Figure 3. ROR by event category, age and sex comparisons. Figure 2 (age rows only) is in output/figures.")

doc <- add_h2(doc, "Multinomial logistic regression")
at <- age %>% transmute(`Event category` = y.level, `Adjusted OR (95% CI)` = fmt_ci(OR, OR_lower, OR_upper),
                        p = ifelse(p.value < 0.001, sprintf("%.4f", p.value), sprintf("%.3f", p.value)))
doc <- body_add_flextable(doc, ft(at, widths = c(2.6, 2.2, 1.0)))
doc <- add_cap(doc, "Table 8. Older (≥65) vs younger (18–64), adjusted for sex, quarter, dose and weight category. Reference outcome = Others.")
doc <- add_p(doc, sprintf("The model converged in about 40 iterations. McFadden pseudo-R² = %.3f; G² = %.1f; ",
                          fitv["McFadden"], fitv["G2"]),
             sprintf("log-likelihood %.1f vs %.1f for the null model. ", fitv["llh"], fitv["llhNull"]),
             sprintf("Adding age_group:sex did not improve fit (χ² = %.2f, df = 3, p = %.2f).",
                     lrt[[6]][2], lrt[[7]][2]), bold_lead = "Fit and interaction. ")
doc <- add_p(doc, "Missing weight was strongly associated with fewer psychiatric terms (OR 0.27); weight ",
             "80–99 kg with more GI terms (OR 1.65); 2024Q2 with fewer GI terms (OR 0.69); 2024Q4 with fewer ",
             "psychiatric terms (OR 0.58). Female vs male for cardiovascular terms was 0.66 (p = 0.055).",
             bold_lead = "Other terms. ")

doc <- add_h2(doc, "Sensitivity analyses")
st <- sens %>% mutate(cell = fmt_ci(estimate, conf.low, conf.high)) %>%
  select(model, n, y.level, cell) %>%
  tidyr::pivot_wider(names_from = y.level, values_from = cell) %>%
  rename(Model = model, n = n)
st$n <- format(st$n, big.mark = ",")
doc <- body_add_flextable(doc, ft(st, widths = c(1.9, 0.6, 1.4, 1.3, 1.3)))
doc <- add_cap(doc, "Table 9. Age-group ORs (older vs younger) across models. S4 (relabelled dose, same cut-points) left the age ORs unchanged.")
doc <- add_p(doc, "The GI finding holds when missing dose is excluded but not when missing weight is excluded. ",
             "The psychiatric finding holds when missing weight is excluded but not when missing dose is ",
             "excluded. With both excluded (n = 314) the intervals are too wide to interpret.")

# 9. Aim 3
doc <- add_h1(doc, "Aim 3: comparison with label and trial evidence")
doc <- add_p(doc, "FAERS gives reporting ratios within semaglutide reports; trials give incidence against ",
             "placebo, so only the direction and presence of a signal are compared. The literature review ",
             "(current DailyMed labels, SUSTAIN-6, PIONEER 6, STEP 1–4, SELECT, age-subgroup analyses, FDA ",
             "Sentinel) was carried out on 1 October 2026 during run 1; its FAERS inputs were recomputed in ",
             "step 14 and are identical, so the classifications are unchanged.")
a3 <- data.frame(
  Row = c("GI and metabolic", "Cardiovascular", "Psychiatric-related", "Others",
          "Pancreatitis", "Gallbladder", "Hypoglycaemia", "Ileus / obstruction / gastric emptying",
          "Nausea / vomiting / diarrhoea / constipation", "Suicidal ideation / behaviour",
          "Heart rate increased / tachycardia", "Dehydration", "Diabetic ketoacidosis"),
  `FAERS age finding` = c(
    "↓ older (ROR 0.71; OR 0.71)", "↑ crude (ROR 1.54); null adjusted (OR 1.15)",
    "↓ older (ROR 0.40; OR 0.47)", "Reference",
    fmt_ci(ptr$ROR[1], ptr$ROR_lower[1], ptr$ROR_upper[1]),
    fmt_ci(ptr$ROR[2], ptr$ROR_lower[2], ptr$ROR_upper[2]),
    fmt_ci(ptr$ROR[3], ptr$ROR_lower[3], ptr$ROR_upper[3]),
    fmt_ci(ptr$ROR[4], ptr$ROR_lower[4], ptr$ROR_upper[4]),
    fmt_ci(ptr$ROR[5], ptr$ROR_lower[5], ptr$ROR_upper[5]),
    fmt_ci(ptr$ROR[6], ptr$ROR_lower[6], ptr$ROR_upper[6]),
    fmt_ci(ptr$ROR[7], ptr$ROR_lower[7], ptr$ROR_upper[7]),
    fmt_ci(ptr$ROR[8], ptr$ROR_lower[8], ptr$ROR_upper[8]),
    fmt_ci(ptr$ROR[9], ptr$ROR_lower[9], ptr$ROR_upper[9])),
  `Label / trial evidence` = c(
    "Labelled; ↑ vs placebo; trials show no age gradient",
    "HR increase, hypotension, syncope labelled; MACE ↓ and consistent by age",
    "Not in current labels (Wegovy warning removed 02/2026); FDA 91-trial meta-analysis and Sentinel: no increase",
    "—", "Labelled (5.2); rare in trials", "Labelled; ↑ vs placebo",
    "Labelled; no age gradient in trials", "Labelled (postmarketing)", "Labelled; ≥65 similar to overall",
    "As psychiatric row", "Labelled", "AKI via volume depletion labelled", "Not labelled"),
  Class = c("Concordant", "Concordant", "Novel (by rule)", "Indeterminate", "Concordant", "Concordant",
            "Concordant", "Concordant", "Concordant", "Novel (by rule)", "Concordant", "Concordant",
            "Indeterminate"),
  check.names = FALSE)
a3f <- ft(a3, widths = c(1.7, 1.6, 2.3, 0.9))
doc <- body_add_flextable(doc, a3f)
doc <- add_cap(doc, "Table 10. Evidence classification. PT-level rows show age ROR (95% CI). Full table and sources: aim3/AIM3_evidence_comparison.md.")
doc <- add_p(doc, "No row is divergent. The psychiatric rows are “novel” only under the spec’s rule: the ",
             "finding is less reporting in older adults, not an excess risk. Indication is a likely confounder ",
             "(Wegovy is 27% of younger reports vs 5.5% of older), so stratifying by product is the suggested follow-up.",
             bold_lead = "Follow-up. ")

# 10. Agreement and judgement calls
doc <- add_h1(doc, "Agreement with Blind Replication 1")
doc <- add_p(doc, "Every checkpoint count, the analytic dataset (byte-identical), ROR/PRR, multinomial ORs, model ",
             "fit, interaction test, sensitivity models and key-PT RORs are identical between the two runs. ",
             "Only some label text in two output tables differs (for example “Age (Older vs Younger)”).")
doc <- add_h1(doc, "Judgement calls")
jc <- data.frame(
  Issue = c("Empty strings after CSV round-trip", "Order of placeholder clean-up",
            "Sensitivity model fitting", "Deprecated plot function"),
  `What was done` = c(
    "Missing outc_cod (\"\" or NA) treated as no OUTC record → NR, per the spec. Empty sex → NA via factor levels.",
    "Applied after the age filter and before the PS filter; either order gives the same rows.",
    "do.call() used so broom::tidy(conf.int = TRUE) can re-evaluate the model call; estimates unchanged.",
    "geom_errorbar(orientation = \"y\") in place of geom_errorbarh() (ggplot2 4.0.0); plots unchanged."),
  check.names = FALSE)
doc <- body_add_flextable(doc, ft(jc, widths = c(2.0, 4.5)))
doc <- add_cap(doc, "Table 11. Decisions where the spec left room.")

# 12. Open items
doc <- add_h1(doc, "Open items")
doc <- add_p(doc, "Compare Table 4 with the withheld Figure 1 counts, starting with box 5 (see the Checkpoint 5 note under Cohort checkpoints).",
             bold_lead = "Figure 1 comparison. ")
doc <- add_p(doc, "Repeat the age comparison within product (Wegovy vs Ozempic/Rybelsus) to separate age from indication.",
             bold_lead = "Suggested analysis. ")

print(doc, target = out_file)
cat("Wrote", out_file, "\n")
