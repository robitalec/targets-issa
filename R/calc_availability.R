calc_availability <- function(DT, col, type, split_by) {
	DT_avail <- DT[!(case_)]

	if (type == 'proportion') {
		DT[, n_split_by := .N, c(split_by)]
		DT[, (paste0('prop_', col)) := .N / n_split_by, c(col, split_by)]
	} else if (type == 'mean') {
		DT[, (paste0('mean_', col)) := mean(x), c(split_by), env = list(x = col)]
	} else if (type == 'median') {
		DT[, (paste0('median_', col)) := median(x), c(split_by), env = list(x = col)]
	}

}






calc_availability <- function(DT, params) {
	if (is.null(DT)) return()
	sum.DT <- data.table()
	lapply(params,function(){
		if(is.factor(DT[,.(params)]))
			sum.DT[,paste('availavility', params, sep = '_') := DT[,sum(.SD[,.N])]]
	})

}



# habitat avail to individual
# s
