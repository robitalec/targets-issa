#' @title Predict H1 distance to water
#' @export
#' @author Julie W. Turner, Alec L. Robitaille
predict_h1_water <- function(DT, model) {
	new_data <- DT[, .(
		sl_ = mean(sl_),
		forest = 0,
		disturbed = 0,
		dist_to_water = seq(from = 0, to = 1500, length.out = 100),
		indiv_step_id = NA
	), by = id]

	new_data[, h1_water := predict(model, .SD, type = 'link', re.form = NULL)]

	# TODO: check
	new_data[, x :=  seq(from = 0, to = 1500, length.out = 100)]
}
