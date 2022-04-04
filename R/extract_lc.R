# Extract land cover ------------------------------------------------------
extract_lc <- function(DT, lcpath, x, y, lcvalues) {
	if (is.null(DT)) return()
	if (nrow(DT) == 0) return()
	lc <- rast(lcpath)
	merge(
		DT[, value := terra::extract(lc, do.call(cbind, .SD)),
			 .SDcols = c(x, y)],
		lcvalues,
		by = 'value',
		all.x = TRUE)
}
