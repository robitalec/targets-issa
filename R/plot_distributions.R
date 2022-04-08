#' @title Plot distributions
#' @export
#' @author Alec L. Robitaille, Julie W. Turner
plot_distributions <- function(DT) {
	ggplot(DT, aes(sl_)) +
		labs(title = paste0('ID: ', DT$id[[1]])) +
		geom_density(alpha = 0.4) +
		plot_theme()
}
