extract_pt <- function(DT, layer, coords) {
	object_name <- deparse(substitute(layer))

	DT[, (object_name) := extract(layer, cbind(.SD)), .SDcols = c(coords)]
}
