# Make unique step ID across individuals -----------------------------------
make_step_id <- function(DT) {
	if (is.null(DT)) return()
	if (nrow(DT) == 0) return()

	setDT(DT)[,indiv_step_id := paste(id, step_id_, sep = '_')]
}
