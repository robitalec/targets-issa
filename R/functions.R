# === Functions -----------------------------------------------------------
# Alec L. Robitaille




# Make unique and complete ------------------------------------------------
make_unique_complete <- function(DT, id, datetime, long, lat) {
	na.omit(unique(DT, by = c(id, datetime)),
					cols = c(long, lat, datetime))
}




# Resample with cancel check ---------------------------------------------------------
resample_tracks <- function(tracks, rate, tolerance) {
	t <- track_resample(tracks, rate = rate, tolerance = tolerance) %>%
		filter_min_n_burst()

	# Cancel if there are not at least three rows after resample
	if (nrow(t) < 3) return()

	t %>% steps_by_burst(.)
}


# Make random tracks ------------------------------------------------------
make_random_steps <- function(DT, lc, elev, popdens) {
	if (is.null(DT)) return()
	if (nrow(DT) == 0) return()
	random_steps(DT, n = 10) %>%
		extract_covariates(lc, where = "end") %>%
		extract_covariates(elev, where = "end") %>%
		extract_covariates(popdens, where = "end") %>%
		time_of_day(where = 'start')
}


# Calculate distribution parameters ---------------------------------------
calc_distribution_parameters <- function(steps) {
	if (is.null(steps)) return()
	c(ta_distr_params(steps), sl_distr_params(steps))
}



#' Evaluate distance-to ---------------------------------------------------
polygonize_lc_class <- function(lc, class) {
	lc[lc != class] <- NA
	pol <- as.polygons(lc)
	st_as_sf(pol)
}

#' Evaluates locations in x by measuring the distance to the nearest feature in layer.
#'
#' To avoid the large overhead of creating distance to rasters for small/medium number of sample points, this vector-based distance to determines the nearest feature (layer) to each x then calculates the distance between each pair.
#'
#' @param layer object of class sfg, sfc or sf.
#' @param crs coordinate reference system of the coordinates in x, if x is a data.table. Either an integer with the EPSG code, or character with proj4string (see the 'crs' argument in \link[sf]{st_sf}).
#' @param x data.table.
#' @param coords columns in `x` indicating names of coordinate columns of focal point. Expects length = 2 e.g.: c('X', 'Y').
#'
#' @return Vector of distances between x and the nearest feature in layer.
#'
#' @export
#'
#' @examples
#' DT[, distWater := eval_dist(.SD, water, coords = c('X', 'Y'), direction = 'positive', crs = sf::st_crs(water))]
eval_dist <-
	function(x,
					 layer,
					 coords = NULL,
					 crs = NULL) {
		if (missing(x) || missing(layer) || is.null(x) || is.null(layer)) {
			stop('please provide both x and layer')
		}

		if (truelength(x) == 0) {
			setDT(x)
		}

		check_coords(x, coords)

		if (is.null(crs)) {
			stop('crs must be provided')
		}

		xsf <- sf::st_as_sf(x, coords = coords, crs = crs)

		sf::st_distance(xsf,
										layer[sf::st_nearest_feature(xsf, layer), ],
										by_element = TRUE)
}

check_coords <- function(x, coords) {
	if (is.null(coords)) {
		stop('coords must be provided')
	}

	if (length(coords) != 2) {
		stop('coords must be a character vector of length 2')
	}

	if (any(!(coords %in% colnames(x)))) {
		stop('coords columns not found in x')
	}

	if (!all(vapply(x[, .SD, .SDcols = coords], is.numeric, TRUE))) {
		stop('coords provided must be numeric')
	}
}

