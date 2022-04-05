plot_rss <- function(pred_h1, pred_h2, theme) {
	# TODO: fix this column subsetting
	log_rss <- merge(pred_h1[, .(id, h1_forest)], pred_h2[, .(id, h2)],
									 by = 'id', all.x = TRUE)
	log_rss[, rss := h1_forest - h2]

	ggplot(data = log_rss, aes(x, rss)) +
		geom_line(aes(group = id , alpha = .0001),
							linetype = 'twodash',
							show.legend = F) +
		geom_smooth(size = 1.5, method = 'glm') +
		geom_hline(
			yintercept = 0,
			colour = "black",
			lty = 2,
			size = .7
		) +
		ylab("logRSS") + xlab("Forest") +
		ggtitle("RSS compared to 0 forest") + theme(plot.title = element_text(hjust = 0.5)) +
		scale_color_colorblind()  +
		scale_fill_colorblind() +
		plot_theme()
}
