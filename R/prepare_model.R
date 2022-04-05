prepare_model <- function(DT) {
	DT[, indiv_step_id := paste(id, step_id_, sep = '_')]

	DT[description == 'forest', lc_adj := 'forest']
	DT[description %in% c('cultivated', 'developed'), lc_adj := 'disturbed']
	DT[description %in% c('barren', 'herbaceous', 'shrubland', 'water'), lc_adj := 'open']
	DT[description == 'wetlands', lc_adj := 'wetlands']


	DT[, lc := as.factor(lc)]
	DT[, lc_adj := as.factor(lc_adj)]
	DT[, indiv_step_id := as.factor(indiv_step_id)]
	DT[, id := as.factor(id)]
	DT[, distto_water := units::drop_units(distto_water)]
}
