#' @title Plot boxplot
#' @export
#' @author Julie W. Turner
plot_box <- function(model, theme) {
	temp <- setDT(coef(model)$cond$id %>% rownames_to_column("id") %>%
															pivot_longer(-id, names_to = "term", values_to = "estimate") %>%
															mutate(method = "ME"))

	ggplot(data = temp[term !='(Intercept)'],
				 aes(term, estimate)) +
		geom_boxplot() +
		geom_jitter() +
		geom_hline(yintercept = 0, lty = 'dashed') +
		coord_flip() +
		plot_theme()
}
