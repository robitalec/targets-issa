prepare_locs <- function(DT, id, datetime, tz, x, y, split_by) {
	stopifnot(is.character(datetime))

	DT[, (datetime) := parse_date(datetime_char, default_tz = tz),
		 env = list(datetime_char = datetime)]

	# Make unique and complete
	unique_DT <- unique(DT, by = c(id, datetime))
	na_omit_DT <- na.omit(unique_DT, cols = c(x, y, datetime))

	# Make splits
	DT[, tar_group := .GRP, by = c(split_by)]

	return(na_omit_DT)
}
