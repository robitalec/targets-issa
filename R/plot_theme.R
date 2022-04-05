plot_theme <- function() {
	theme_bw()  + theme(
		panel.border = element_blank(),
		panel.grid.major = element_blank(),
		panel.grid.minor = element_blank(),
		axis.line = element_line(colour = "black", size = .7)
	) +
		theme(
			plot.title = element_text(size = 12, hjust = 0.05),
			axis.text.x = element_text(size = 12),
			axis.title = element_text(size = 15),
			axis.text.y = element_text(size = 12)
		) +
		theme(axis.text.x = element_text(margin = margin(10, 10, 10, 10, "pt")),
					axis.text.y = element_text(margin = margin(10, 10, 10, 10, "pt"))) + theme(axis.ticks.length = unit(-0.25, "cm"))
}
