#' @title Check glmmTMB model
#' @export
#' @author Alec L. Robitaille, Julie W. Turner
check_model <- function(model) {
	model$sdr$pdHess
}
