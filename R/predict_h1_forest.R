#' @title Predict H1 forest
#' @export
#' @author Julie W. Turner, Alec L. Robitaille
predict_h1_forest <- function(DT, model) {
	new_data <- DT[, .(
		sl_ = mean(sl_),
		forest = seq(from = 0, to = 1, length.out = 100),
		disturbed = 0,
		dist_to_water= median(dist_to_water, na.rm = T),
		indiv_step_id = NA,
		id = .BY[[1]]
	), by = id]

	new_data[, h1_forest := predict(model, .SD, type = 'link', re.form = NULL)]
}

# forest
# h1.indiv.forest <- data.table(rbindlist(h1.indiv.forest), x = seq(from = 0, to = 1, length.out = 100))
