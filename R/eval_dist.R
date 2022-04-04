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
