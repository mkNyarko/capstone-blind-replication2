# ---- Step 01: 2024Q1 per-quarter case file, one operation at a time -------
# Spec: "Per-quarter case file". Q2-Q4 repeat the same logic in step 02.

# Import the four tables used (fread, sep = "$", all other defaults)
drug <- fread(quarter_file("Q1", "DRUG"), sep = "$")
demo <- fread(quarter_file("Q1", "DEMO"), sep = "$")
reac <- fread(quarter_file("Q1", "REAC"), sep = "$")
outc <- fread(quarter_file("Q1", "OUTC"), sep = "$")
sapply(list(DRUG = drug, DEMO = demo, REAC = reac, OUTC = outc), nrow)

# 1. Semaglutide drug rows: drugname regex OR prod_ai regex, no role filter
sema <- drug[grepl("SEMAGLUTIDE|OZEMPIC|WEGOVY|RYBELSUS", drugname, ignore.case = TRUE) |
             grepl("SEMAGLUTIDE", prod_ai, ignore.case = TRUE)]
nrow(sema)
head(sort(table(sema$drugname), decreasing = TRUE), 10)
table(sema$role_cod)

# 2. Case list
ids <- unique(sema$caseid)
length(ids)

# 3. Restrict DEMO, REAC, OUTC to those cases
demo <- demo[caseid %in% ids]
reac <- reac[caseid %in% ids]
outc <- outc[caseid %in% ids]
sapply(list(DEMO = demo, REAC = reac, OUTC = outc), nrow)

# 4. US only: reporter_country == "US" (exact)
demo_us <- demo[reporter_country == "US"]
nrow(demo_us)

# 5. Joins in order, all left joins on caseid
m <- merge(demo_us, outc, by = "caseid", all.x = TRUE)
nrow(m)
m <- merge(m, reac, by = "caseid", all.x = TRUE)
nrow(m)
m <- merge(m, sema, by = "caseid", all.x = TRUE)   # warns about duplicate primaryid names (expected)
nrow(m)

# 7. Duplicate column names -> make.unique, drop primaryid.x.1 / primaryid.y.1
names(m) <- make.unique(names(m))
grep("primaryid", names(m), value = TRUE)
m <- as.data.frame(m)
m <- m[, setdiff(names(m), c("primaryid.x.1", "primaryid.y.1"))]

# 8. Collapse to one row per case: most severe outcome wins
outc_rank <- c(DE = 1, LT = 2, HO = 3, DS = 4, CA = 5, RI = 6, OT = 7)
q1 <- m %>%
  mutate(rank = unname(outc_rank[outc_cod])) %>%
  group_by(caseid) %>%
  slice_min(rank, n = 1, with_ties = FALSE) %>%
  ungroup()
nrow(q1)
length(unique(q1$caseid)) == nrow(q1)   # one row per case?
table(q1$outc_cod, useNA = "ifany")

# 9. Write the quarter
fwrite(q1, file.path(int_dir, "faers_sema_2024Q1.csv"))
