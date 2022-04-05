plot_distributions <- function(DT) {
	ggplot(DT, aes(sl_)) +
		geom_density(alpha = 0.4)
}
