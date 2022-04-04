prepare_locs <- function(DT, id, datetime, tz, long, lat) {
	stopifnot(is.character(datetime))

	DT[, (datetime) := parse_date(datetime_char, default_tz = tz),
		 env = list(datetime_char = datetime)]

	# Make unique and complete
	unique_DT <- unique(DT, by = c(id, datetime))
	na_omit_DT <- na.omit(unique_DT, cols = c(long, lat, datetime))

	return(na_omit_DT)
}
