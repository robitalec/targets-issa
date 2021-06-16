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
	tar_cancel(nrow(t) < 3)

	t %>% steps_by_burst(.)
}
