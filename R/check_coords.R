check_coords <- function(x, coords) {
	if (is.null(coords)) {
		stop('coords must be provided')
	}

	if (length(coords) != 2) {
		stop('coords must be a character vector of length 2')
	}

	if (any(!(coords %in% colnames(x)))) {
		stop('coords columns not found in x')
	}

	if (!all(vapply(x[, .SD, .SDcols = coords], is.numeric, TRUE))) {
		stop('coords provided must be numeric')
	}
}
