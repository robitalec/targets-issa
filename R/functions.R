# === Functions -----------------------------------------------------------
# Alec L. Robitaille




# Make unique and complete ------------------------------------------------
make_unique_complete <- function(DT, id, datetime, long, lat) {
	na.omit(unique(DT, by = c(id, datetime)),
					cols = c(long, lat, datetime))
}




# Resample with cancel check ---------------------------------------------------------
resample_tracks <- function(tracks, rate, tolerance) {
	t <- track_resample(tracks, rate = rate, tolerance = tolerance) %>%
		filter_min_n_burst()

	# Cancel if there are not at least three rows after resample
	if (nrow(t) < 3) return()

	t %>% steps_by_burst(.)
}


# Make random tracks ------------------------------------------------------
make_random_tracks <- function(DT, lc) {
	if (is.null(DT)) return()
	if (nrow(DT) == 0) return()
	amt::random_steps(DT, n = 10) %>%
		amt::extract_covariates(lc, where = "end") %>%
		amt::time_of_day(where = 'start')
}


# Calculate distribution parameters ---------------------------------------
calc_distribution_parameters <- function(steps) {
	if (is.null(steps)) return()
	c(amt::ta_distr_params(steps), amt::sl_distr_params(steps))
}
