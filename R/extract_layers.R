#' @title Extract layers
#' @export
#' @author Alec L. Robitaille, Julie W. Turner
extract_layers <- function(DT, crs, lc, legend, elev, popdens, water) {
	setDT(DT)

	start <- c('x1_', 'y1_')
	end <- c('x2_', 'y2_')

	extract_pt(DT, lc, end)
	DT[legend, lc_description := description, on = .(pt_lc = Value)]

	extract_pt(DT, elev, end)
	extract_pt(DT, popdens, end)

	extract_distance_to(DT, water, end, crs)
}
