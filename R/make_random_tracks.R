# Make random tracks ------------------------------------------------------
make_random_steps <- function(DT, lc, elev, popdens) {
	if (is.null(DT)) return()
	if (nrow(DT) == 0) return()
	random_steps(DT, n = 10) %>%
		extract_covariates(lc, where = "end") %>%
		extract_covariates(elev, where = "end") %>%
		extract_covariates(popdens, where = "end") %>%
		time_of_day(where = 'start')
}
