# Calculate availability ---------------------------------------
#TODO ***
calc_availability <- function(DT, params) {
	if (is.null(DT)) return()
	sum.DT <- data.table()
	lapply(params,function(){
		if(is.factor(DT[,.(params)]))
			sum.DT[,paste('availavility', params, sep = '_') := DT[,sum(.SD[,.N])]]
	})

}
