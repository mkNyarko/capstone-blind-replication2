# ---- Step 13: sensitivity analyses and Figures 2-4 --------------------------
# Same formula and reference levels as the main model.
# ORs and Wald CIs from broom::tidy(exponentiate = TRUE, conf.int = TRUE).
# do.call() stores the data inside the model call so broom can re-evaluate it.
sens_fit <- function(d, label) {
  m <- do.call("multinom", list(formula = f_main, data = d, trace = FALSE))
  broom::tidy(m, exponentiate = TRUE, conf.int = TRUE) %>% mutate(model = label, n = nrow(d))
}

sens <- bind_rows(
  main_tab %>% transmute(y.level, term, estimate = OR, conf.low = OR_lower,
                         conf.high = OR_upper, p.value, model = "Main", n = nrow(dat)),
  sens_fit(filter(dat, dose_cat != "Missing"), "S1: exclude missing dose"),
  sens_fit(filter(dat, wt_cat != "Missing"), "S2: exclude missing weight"),
  sens_fit(filter(dat, dose_cat != "Missing" & wt_cat != "Missing"), "S3: exclude both")
)
fwrite(sens, file.path(tab_dir, "sensitivity_all_terms.csv"))

# Compare the age_group ORs across models
sens_age <- sens %>% filter(grepl("^age_group", term)) %>%
  select(model, n, y.level, estimate, conf.low, conf.high, p.value)
fwrite(sens_age, file.path(tab_dir, "sensitivity_age_group.csv"))
sens_age %>% transmute(model, n, y.level, OR = round(estimate, 2),
                       CI = sprintf("%.2f-%.2f", conf.low, conf.high), p = signif(p.value, 2))

# S4: alternative dose labels, same cut-points (printed, not tabulated)
levels(as.factor(dat$dose_cat_alt))   # new default reference level
m_alt <- multinom(event_category ~ age_group + sex + quarter + dose_cat_alt + wt_cat,
                  data = dat, trace = FALSE)
round(exp(coef(m_alt)), 2)
capture.output(summary(m_alt), file = file.path(tab_dir, "sensitivity4_alt_dose_labels.txt"))

# Figures: ggplot2, theme_minimal, dashed line at 1 on the forest plots
forest <- function(d, title) {
  ggplot(d, aes(x = ROR, y = event_category, colour = comparison)) +
    geom_point(position = position_dodge(width = 0.5), size = 2.5) +
    geom_errorbar(aes(xmin = ROR_lower, xmax = ROR_upper), orientation = "y",
                  position = position_dodge(width = 0.5), width = 0.2) +
    geom_vline(xintercept = 1, linetype = "dashed") +
    labs(title = title, x = "Reporting odds ratio (95% CI)", y = NULL, colour = NULL) +
    theme_minimal() + theme(legend.position = "bottom")
}
p2 <- forest(filter(ror_tab, grepl("^Age", comparison)),
             "Figure 2. ROR by adverse event category: older vs younger adults")
p3 <- forest(ror_tab, "Figure 3. ROR by adverse event category: age and sex")
p4 <- ggplot(dat, aes(x = event_category)) + geom_bar() +
  geom_text(stat = "count", aes(label = after_stat(count)), vjust = -0.4) +
  labs(title = "Figure 4. Reports per adverse event category", x = NULL, y = "Number of reports") +
  theme_minimal()
ggsave(file.path(fig_dir, "figure2_forest_age.png"), p2, width = 8, height = 4.5, dpi = 300)
ggsave(file.path(fig_dir, "figure3_forest_age_sex.png"), p3, width = 8, height = 5, dpi = 300)
ggsave(file.path(fig_dir, "figure4_event_counts.png"), p4, width = 8, height = 5, dpi = 300)
list.files(fig_dir)

writeLines(capture.output(sessionInfo()), file.path(log_dir, "sessionInfo.txt"))
cat("\n*** Analysis complete. ***\n")
