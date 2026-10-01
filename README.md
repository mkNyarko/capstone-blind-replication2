# FAERS 2024 Semaglutide: Blind Replication 2 (step by step)

This is a second independent rebuild of the capstone pipeline, *Real-World Adverse Event Patterns Associated with Semaglutide in Older vs. Younger U.S. Adults (FAERS 2024)*. It was run live in a visible R session, one step at a time, with a pause at every spec checkpoint for review.

It was built only from `FAERS_Semaglutide_Replication_Spec.pdf`, `Aims_and_Methods.pdf` (for reference) and the raw FDA FAERS 2024Q1–Q4 ASCII files. The original code, results and repository were not seen. Run date: 2026-10-01.

## How it was run

`watch_steps.R` kept one R session open in the terminal. Each step file was placed in `queue/`, run with its code and comments echoed, and then filed under `R/`. Objects stayed in memory between steps. To rerun everything in one go:

```bash
LC_ALL=en_US.UTF-8 Rscript run_all.R
```

| Step | File | What it does |
|---|---|---|
| 00 | `00_setup.R` | Packages, paths, checkpoint tracker |
| 01 | `01_quarter_Q1_walkthrough.R` | 2024Q1 per-quarter case file, one operation at a time |
| 02 | `02_quarters_Q2_Q4.R` | Same logic as a function (checked against Q1); Q2–Q4, with the Q4 first-drug-row rule |
| 03 | `03_stack_checkpoint1.R` | CSV round-trip and stack → **checkpoint 1** |
| 04 | `04_dedup_checkpoint2.R` | Latest quarter per caseid → **checkpoint 2** |
| 05 | `05_age_checkpoint3.R` | age_group, age filter → **checkpoint 3**; placeholder text → NA |
| 06 | `06_ps_checkpoint4.R` | Primary suspect → **checkpoint 4**; saves the cleaned file |
| 07 | `07_outcome_checkpoint5.R` | Reads the cleaned file back; no OUTC record → NR, dropped → **checkpoint 5** |
| 08 | `08_congenital_checkpoint6.R` | Drop CA → **checkpoint 6** |
| 09 | `09_sex_checkpoint7.R` | Drop NA/UNK sex → **checkpoint 7** |
| 10 | `10_derived_vars_reference_levels.R` | Event category, covariates → **reference-level checkpoint** |
| 11 | `11_table1_ror_prr.R` | Table 1, ROR/PRR |
| 12 | `12_multinom_fit_interaction.R` | Main multinomial model, pseudo-R², age × sex LRT |
| 13 | `13_sensitivity_figures.R` | Sensitivity models 1–4, Figures 2–4 |
| 14 | `14_aim3_pt_rors.R` | Aim 3 support: key-PT age RORs, product mix by age |

## Checkpoints

| # | Figure 1 box | n |
|---|---|---|
| 1 | Raw data (4 quarters combined) | 17,281 |
| 2 | After deduplication | 15,971 |
| 3 | After cleaning age variable | 8,067 |
| 4 | Primary Suspect (PS) | 5,302 |
| 5 | After outcome cleaning | 2,604 |
| 6 | After excluding congenital anomaly | 2,601 |
| 7 | Final analytic sample | 2,427 |

**Reference levels:** outcome = Others; age_group = Younger Adults (18–64); sex = Male; quarter = 2024Q1. Picked by `as.factor()` under en_US.UTF-8: dose_cat = **<0.5 mg** and wt_cat = **<80 kg**. Sensitivity 4's dose_cat_alt = High dose.

## Agreement with Blind Replication 1

Run 1 was built separately. Every checkpoint count, the analytic dataset (byte-identical), the ROR/PRR estimates, the multinomial ORs, the model fit, the interaction LRT, the sensitivity models and the key-PT RORs are identical. Only some label text in the output tables differs.

## Judgement calls (same as run 1)

1. **Empty strings after the CSV round-trip.** All 2,698 "no OUTC record" values come back as `""`, not `NA` (shown in step 07). Both are treated as NR, per the spec. Empty `sex` becomes NA through `factor(levels = c("M","F","UNK"))`.
2. **Placeholder → NA** runs after the age filter and before the PS filter. The result is the same in either order.
3. **Sensitivity models 1–3** are fitted with `do.call()` so `broom::tidy(conf.int = TRUE)` can re-evaluate the model call. Estimates are unchanged.
4. **Figures** use `geom_errorbar(orientation = "y")` in place of the deprecated `geom_errorbarh()`.

## Aim 3

`aim3/AIM3_evidence_comparison.md` is the label and trial evidence comparison. Its literature review (DailyMed labels, SUSTAIN-6, PIONEER 6, STEP 1–4, SELECT, age-subgroup analyses, FDA Sentinel) was done on 2026-10-01 during run 1. The FAERS inputs it uses (category and key-PT age RORs, multinomial ORs, product mix) were recomputed here in step 14 and are identical, so the classifications stand unchanged.
