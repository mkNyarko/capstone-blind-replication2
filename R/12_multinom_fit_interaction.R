# ---- Step 12: main multinomial model, fit, interaction test -----------------
# Outcome: event_category (reference = Others). Package defaults: maxit = 100, no decay.
f_main <- event_category ~ age_group + sex + quarter + dose_cat + wt_cat
m_main <- multinom(f_main, data = dat)          # trace shows the iterations
m_main$convergence                              # 0 = converged

# ORs = exp(coef); Wald CI = exp(coef +/- 1.96 x SE); p-values from broom::tidy (Wald z)
tidy_multinom <- function(m) {
  co <- summary(m)$coefficients
  se <- summary(m)$standard.errors
  p  <- broom::tidy(m) %>% select(y.level, term, p.value)
  as.data.frame(as.table(co)) %>% setNames(c("y.level", "term", "coef")) %>%
    left_join(as.data.frame(as.table(se)) %>% setNames(c("y.level", "term", "se")),
              by = c("y.level", "term")) %>%
    mutate(across(c(y.level, term), as.character)) %>%
    left_join(p, by = c("y.level", "term")) %>%
    mutate(OR = exp(coef), OR_lower = exp(coef - 1.96 * se), OR_upper = exp(coef + 1.96 * se)) %>%
    arrange(factor(y.level, levels = ev_levels[-1]))
}
main_tab <- tidy_multinom(m_main)
fwrite(main_tab, file.path(tab_dir, "multinom_main_all_terms.csv"))

# All terms, rounded for reading
main_tab %>% transmute(y.level, term, OR = round(OR, 2), CI = sprintf("%.2f-%.2f", OR_lower, OR_upper),
                       p = signif(p.value, 2))

# The reported result: age_group rows
age_rows <- main_tab %>% filter(grepl("^age_group", term))
fwrite(age_rows, file.path(tab_dir, "multinom_main_age_group.csv"))
age_rows %>% transmute(y.level, OR = round(OR, 2), CI = sprintf("%.2f-%.2f", OR_lower, OR_upper),
                       p = signif(p.value, 3))

# Model fit: McFadden pseudo-R2 and G2 (pscl::pR2)
fit <- pscl::pR2(m_main)
round(fit, 4)
fwrite(data.frame(statistic = names(fit), value = unname(fit)),
       file.path(tab_dir, "multinom_main_fit_pR2.csv"))

# Interaction: add age_group:sex, compare with a likelihood ratio test
m_int <- multinom(update(f_main, . ~ . + age_group:sex), data = dat, trace = FALSE)
lrt <- anova(m_main, m_int, test = "Chisq")
lrt
fwrite(as.data.frame(lrt), file.path(tab_dir, "interaction_lrt.csv"))
fwrite(tidy_multinom(m_int), file.path(tab_dir, "multinom_interaction_all_terms.csv"))

cat("\n*** PAUSED after the main model and interaction test. Next: sensitivity analyses and figures. ***\n")
