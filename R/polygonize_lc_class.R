polygonize_lc_class <- function(lc, class) {
	lc[lc != class] <- NA
	pol <- rasterToPolygons(lc, dissolve = TRUE)
	st_as_sf(pol)
}
