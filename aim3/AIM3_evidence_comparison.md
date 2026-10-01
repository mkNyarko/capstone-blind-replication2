# Aim 3: FAERS age findings compared with label and trial evidence

New work, as set out in the replication spec. There is no original result to match. Sources were accessed on 2026-10-01.

**What can be compared.** FAERS gives reporting ratios *within semaglutide reports* (adults ≥65 vs 18–64). Trials give incidence against placebo. Only the **direction** of a finding and whether a signal is present can be compared, not its size. The FAERS cardiovascular category is a list of preferred terms (arrhythmia, heart failure, BP, stroke, syncope and others). It is **not** MACE, which is what SUSTAIN-6, PIONEER 6 and SELECT measure.

## FAERS inputs (from this replication, final analytic sample n = 2,427)

**Product mix by age group** (`faers_product_mix_by_age.csv`). This stands in for indication, since Ozempic and Rybelsus are for type 2 diabetes and Wegovy is for obesity.

| Product | Older ≥65 (n=967) | Younger 18–64 (n=1,460) |
|---|---|---|
| Ozempic (T2D) | 83.5% | 58.2% |
| Wegovy (obesity) | 5.5% | 27.3% |
| Rybelsus (T2D) | 5.5% | 3.6% |
| Semaglutide (unspecified) | 5.3% | 9.3% |
| Combination product | 0.3% | 1.6% |

The older group is almost entirely the type 2 diabetes indication. More than a quarter of the younger group is obesity (Wegovy). The age contrast is therefore partly an indication contrast, so the T2D trials (SUSTAIN, PIONEER) are the closer comparator for the older group.

**Age findings by category** (older vs younger):

| Category | ROR (95% CI) | Multinomial OR (95% CI), adjusted |
|---|---|---|
| Gastro-Intestinal and Metabolic | 0.71 (0.59–0.85) | 0.71 (0.58–0.86) |
| Cardiovascular | 1.54 (1.03–2.29) | 1.15 (0.76–1.74) |
| Psychiatric-related | 0.40 (0.26–0.62) | 0.47 (0.30–0.75) |
| Others | not computed (spec) | reference outcome |

**Key PT groups** (ROR, older vs younger; `faers_key_pt_age_rors.csv`; a = older reports with the PT):

| PT group | a / c | ROR (95% CI) |
|---|---|---|
| Pancreatitis (incl. acute, necrotising) | 38 / 73 | 0.78 (0.52–1.16) |
| Gallbladder (cholelithiasis, cholecystitis) | 8 / 29 | 0.41 (0.19–0.90) |
| Hypoglycaemia / blood glucose decreased | 6 / 11 | 0.82 (0.30–2.23) |
| Ileus / intestinal obstruction / impaired gastric emptying | 25 / 90 | 0.40 (0.26–0.63) |
| Nausea / vomiting / diarrhoea / constipation | 90 / 159 | 0.84 (0.64–1.10) |
| Suicidal ideation / behaviour | 3 / 33 | 0.13 (0.04–0.44) |
| Heart rate increased / tachycardia | 3 / 5 | 0.91 (0.22–3.80) |
| Dehydration | 14 / 19 | 1.11 (0.56–2.23) |
| Diabetic ketoacidosis | 3 / 6 | 0.75 (0.19–3.02) |

Each report carries a single PT (the first REAC row, per the spec), so PT counts are small and undercount events.

## Evidence table

| Row | In label (section) | Trial incidence vs placebo | Age-subgroup finding (trials) | FAERS age finding (ROR / OR) | Class |
|---|---|---|---|---|---|
| **GI and metabolic (category)** | All three labels: 5.6/5.7 severe GI reactions; 6.1 most common ARs | ↑ (e.g. Ozempic nausea 15.8–20.3% vs 6.1%; Wegovy 44% vs 16%; GI discontinuation ↑ in SUSTAIN-6, PIONEER 6, STEP 1–3, SELECT) | Serious GI AEs similar across age quartiles (SUSTAIN-6 + PIONEER 6 post hoc); ≥65 rates similar to overall (PIONEER/SUSTAIN/STEP pool) | ↓ in older (ROR 0.71; OR 0.71, both CI <1) | **Concordant.** Known labelled and trial event. Note: trials show no age gradient, while FAERS shows *relatively less* GI reporting in older adults. |
| **Cardiovascular (category)** | Wegovy 5.9 heart rate increase; hypotension 1.3% vs 0.4% and syncope 0.8% vs 0.2% (6.1). Ozempic/Rybelsus 6.1: HR +1–3 bpm | MACE ↓ (SUSTAIN-6 HR 0.74; PIONEER 6 HR 0.79, non-inferior; SELECT HR 0.80). Heart rate ↑ | MACE effect consistent across age (p-interaction 0.33); cardiac SAEs no age difference (SUSTAIN-6 + PIONEER 6 post hoc). SELECT: MACE benefit consistent at 65–74 and ≥75 | ↑ in older, crude ROR 1.54 (CI >1). Not significant after adjustment (OR 1.15, CI 0.76–1.74) | **Concordant.** Labelled CV-type events (HR increase, hypotension, syncope). The crude age excess disappears after adjustment, consistent with trials. MACE ≠ FAERS CV PTs. |
| **Psychiatric-related (category)** | Not in any current label. Wegovy's suicidal behaviour and ideation warning was **removed 02/2026**. The diabetes labels never had one | No increase: FDA meta-analysis of 91 placebo-controlled GLP-1 RA trials (n = 107,910) | None reported | ↓ in older (ROR 0.40; OR 0.47, both CI <1) | **Novel** (by the spec's rule: notable and absent from labels/AE tables). The direction is *less* reporting in older adults, not an excess risk. |
| **Others (category)** | n/a | n/a | n/a | Reference category; no ROR per spec | **Indeterminate** |
| Pancreatitis | All labels 5.2; 6.2 necrotising pancreatitis | Rare; Ozempic 0.3 vs 0.2 per 100 PY; Rybelsus 0.1 vs <0.1 | Not reported by age | No difference (0.78, CI spans 1) | **Concordant** (labelled) |
| Gallbladder events | All labels 5.8/5.9/5.3 | ↑ (Wegovy cholelithiasis 1.6% vs 0.7%; Ozempic 1.5% vs 0%; PIONEER 6 cholecystitis 1.1% vs 0.7%) | Not reported by age | ↓ in older (0.41, CI <1) | **Concordant** (labelled); age direction has no trial counterpart |
| Hypoglycaemia | All labels 5.4/5.5 (with insulin or secretagogues) | ↑ only with insulin/SU; Wegovy T2D 6% vs 2% | Severe hypoglycaemia on semaglutide 1.1–2.4% across age quartiles, no age gradient (post hoc) | No difference (0.82, CI spans 1) | **Concordant** (same: no age difference) |
| Ileus / obstruction / delayed gastric emptying | 6.2 postmarketing ileus, intestinal obstruction (Ozempic, Rybelsus, Wegovy); 5.6/5.7 not recommended in severe gastroparesis | Not quantified in pivotal trials | Not reported by age | ↓ in older (0.40, CI <1) | **Concordant** (labelled); age direction has no trial counterpart |
| Nausea / vomiting / diarrhoea / constipation | 6.1 most common ARs | ↑ (see GI row) | ≥65 rates similar to overall population | No difference (0.84, CI spans 1) | **Concordant** (same direction: no age gradient) |
| Suicidal ideation / behaviour | Wegovy warning removed 02/2026; not in diabetes labels | No increase (FDA meta-analysis, 91 trials) | None | ↓ in older (0.13, CI <1; only 3 older reports) | **Novel** (by rule; see note) |
| Heart rate increase / tachycardia | Wegovy 5.9; Ozempic/Rybelsus 6.1 | ↑ 1–4 bpm; Wegovy ≥20 bpm rise 26% vs 16% | Not reported by age | No difference (0.91, CI spans 1; 3 older reports) | **Concordant** (labelled) |
| Dehydration (AKI) | All labels 5.5/5.6 AKI due to volume depletion | Postmarketing | Not reported by age | No difference (1.11) | **Concordant** (labelled) |
| Diabetic ketoacidosis | Not in label | Not reported | None | No difference (0.75) | **Indeterminate** (not notable, no age data) |

**FDA Sentinel.** One published Sentinel assessment applies, to the psychiatric rows only. FDA's January 2026 communication cites a Sentinel cohort of 2,243,138 users (GLP-1 RA vs SGLT2 inhibitors, 2015–2023) that found no increased risk of intentional self-harm. It is a class-level analysis, not specific to semaglutide, and FDA reported no age-subgroup results. I found no Sentinel assessment covering the GI, cardiovascular or gallbladder outcomes for semaglutide, so Sentinel does not apply to those rows.

## Rows needing follow-up

- **Psychiatric-related (category and suicidal ideation/behaviour): "Novel" by rule.** FAERS shows significantly *less* psychiatric reporting in older adults (adjusted OR 0.47). This is not a new risk signal. The FDA trial meta-analysis and the Sentinel self-harm study found no excess psychiatric risk for GLP-1 RAs overall, and no source reports by age. The most likely explanations are indication and background prevalence: younger reporters are more often Wegovy/obesity users (27% vs 5.5%), and both obesity-treatment populations and younger adults have higher background rates of depression and anxiety. Media attention to GLP-1 suicidality in 2023–24 may also have driven stimulated reporting. Suggested follow-up: stratify by product (Wegovy vs Ozempic/Rybelsus) to see whether the age difference persists within indication.
- **No divergent rows.** No FAERS age direction contradicts a trial age-subgroup finding. Where trials report by age (serious GI AEs, severe hypoglycaemia, cardiac SAEs, MACE), they find no age gradient. FAERS also finds none for hypoglycaemia or for cardiovascular after adjustment. FAERS does show *less* GI reporting in older adults where the trials found no difference. That is a weak inconsistency, not an opposite direction, so it is noted under GI rather than classed as divergent. Likely reasons: tolerance-driven reporting in younger, higher-dose obesity users; Wegovy's 2.4 mg dose versus 0.5–2 mg for Ozempic; and different reporter behaviour.
- **Gallbladder and ileus/obstruction** are labelled events with lower reporting in older adults, and no trial reports them by age. They are worth checking within indication, because Wegovy's rapid weight loss is a known gallstone risk factor.

## Sources (accessed 2026-10-01)

1. Ozempic (semaglutide) injection, US Prescribing Information, revised 5/2026. DailyMed. https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=adec4fd2-6858-4c99-91d4-531f5f2a2d79
2. Rybelsus / oral semaglutide tablets, US Prescribing Information, revised 1/2026. DailyMed. https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=27f15fac-7d98-4114-a2ec-92494a91da98
3. Wegovy (semaglutide) injection and tablets, US Prescribing Information, revised 6/2026 (suicidal behaviour and ideation warning removed 02/2026). DailyMed. https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ee06186f-2aa3-4990-a760-757579d8f77b
4. Marso SP et al. Semaglutide and cardiovascular outcomes in patients with type 2 diabetes (SUSTAIN-6). N Engl J Med 2016;375:1834–44. doi:10.1056/NEJMoa1607141. PMID 27633186
5. Husain M et al. Oral semaglutide and cardiovascular outcomes in patients with type 2 diabetes (PIONEER 6). N Engl J Med 2019;381:841–51. doi:10.1056/NEJMoa1901118. PMID 31185157
6. Wilding JPH et al. Once-weekly semaglutide in adults with overweight or obesity (STEP 1). N Engl J Med 2021;384:989–1002. doi:10.1056/NEJMoa2032183. PMID 33567185
7. Davies M et al. Semaglutide 2.4 mg once a week in adults with overweight or obesity, and type 2 diabetes (STEP 2). Lancet 2021;397:971–84. doi:10.1016/S0140-6736(21)00213-0. PMID 33667417
8. Wadden TA et al. Effect of subcutaneous semaglutide vs placebo as an adjunct to intensive behavioral therapy (STEP 3). JAMA 2021;325:1403–13. doi:10.1001/jama.2021.1831. PMID 33625476
9. Rubino D et al. Effect of continued weekly subcutaneous semaglutide vs placebo on weight loss maintenance (STEP 4). JAMA 2021;325:1414–25. doi:10.1001/jama.2021.3224. PMID 33755728
10. Lincoff AM et al. Semaglutide and cardiovascular outcomes in obesity without diabetes (SELECT). N Engl J Med 2023;389:2221–32. doi:10.1056/NEJMoa2307563. PMID 37952131
11. Bain SC et al. Cardiovascular, metabolic, and safety outcomes with semaglutide by baseline age: post hoc analysis of SUSTAIN 6 and PIONEER 6. Diabetes Ther 2025;16:15–28. doi:10.1007/s13300-024-01659-7. PMID 39520501
12. Sabbagh M et al. Safety considerations of semaglutide in the potential treatment of Alzheimer's disease: a pooled analysis of semaglutide in adults aged ≥65 years. Alzheimers Dement (N Y) 2025;11:e70076. doi:10.1002/trc2.70076. PMID 40337158
13. US FDA. FDA requests removal of suicidal behavior and ideation warning from GLP-1 RA medications (Drug Safety Communication, 13 Jan 2026; includes the 91-trial meta-analysis and the Sentinel self-harm cohort). https://www.fda.gov/drugs/drug-safety-communications/fda-requests-removal-suicidal-behavior-and-ideation-warning-glucagon-peptide-1-receptor-agonist-glp
14. SELECT age-subgroup consistency of MACE benefit (65–74, ≥75): summarised in "First study with positive cardiovascular outcome in obesity: reflections on SELECT". https://pmc.ncbi.nlm.nih.gov/articles/PMC11222733/

Abstracts for sources 4–12 were retrieved through NCBI E-utilities and saved in `pubmed_abstracts_raw.txt`.
