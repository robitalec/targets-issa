#' @title Plot boxplot
#' @export
#' @author Julie W. Turner
plot_box <- function(model, theme) {

	ggplot(data = model[term !='(Intercept)'],
				 aes(term, estimate)) +
		geom_boxplot() +
		geom_jitter() +
		geom_hline(yintercept = 0, lty = 'dashed') +
		coord_flip() +
		plot_theme()
}
