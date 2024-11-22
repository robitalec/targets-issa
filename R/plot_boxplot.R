#' @title Plot boxplot
#' @export
#' @author Julie W. Turner
plot_box<- function(DT, theme) {

	ggplot(data = DT,
				 aes(n_random, estimate, group = n_random)) +
		geom_boxplot() +
		geom_jitter() +
		scale_color_colorblind()  +
		scale_fill_colorblind() +
		plot_theme() +
		facet_wrap(~term)
}
