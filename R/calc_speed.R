#' @title Calculate speed
#' @export
#' @author Julie W. Turner
calc_speed <- function(DT, covariate, seq) {
	DT[, `:=` (spd = list(list((shape +`I(log(sl_))` +
																			ifelse(covariate == 'forest', `I(log(sl_)):forest`*seq, `I(log(sl_)):forest`) +
																			ifelse(covariate == 'disturbed',`I(log(sl_)):disturbed`*seq, `I(log(sl_)):disturbed`) +
																			ifelse(covariate == 'dist_to_water', `I(log(dist_to_water + 1)):I(log(sl_))`*seq,
																						 `I(log(dist_to_water + 1)):I(log(sl_))`*median.water)
															)*(scale))),
									 x = list(list(seq))),
					 by=.(id)]
	move <- DT[, .(spd = unlist(spd), x = unlist(x)), by=.(id)]

}
