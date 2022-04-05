extract_distance_to <- function(DT, layer, coords, crs) {
	distance_to(
		st_as_sf(DT[, .SD, .SDcols = c(coords)], coords = coords, crs = crs),
		layer
	)
}
