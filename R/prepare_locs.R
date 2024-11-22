#' @title Prepare locs
#' @export
#' @author Alec L. Robitaille, Julie W. Turner
prepare_locs <- function(DT, id, datetime, tz, x, y, split_by) {
	stopifnot(is.character(datetime))

	DT[, (datetime) := parse_date(datetime_char, default_tz = tz),
		 env = list(datetime_char = datetime)]
	
	# Cast any IDate columns as Date
	is_idate <- vapply(DT, function(x) 'IDate' %in% class(x), FUN.VALUE = TRUE)
	DT[, (names(is_idate)) := lapply(.SD, as.Date), .SDcols = names(is_idate)]
		   
	# Make unique and complete
	unique_DT <- unique(DT, by = c(id, datetime))
	na_omit_DT <- na.omit(unique_DT, cols = c(x, y, datetime))

	# Make splits
	na_omit_DT[, tar_group := .GRP, by = c(split_by)]

	# Rename columns
	setnames(na_omit_DT, c(x, y, datetime), c('x_', 'y_', 't_'))

	return(na_omit_DT)
}
