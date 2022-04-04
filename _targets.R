# === Targets: iSSA workflow ----------------------------------------------
# Alec L. Robitaille, Julie W. Turner



# Source ------------------------------------------------------------------
lapply(dir('R', '*.R', full.names = TRUE), source)



# Options -----------------------------------------------------------------
tar_option_set(format = 'qs')



# Data --------------------------------------------------------------------
# Path to fisher locs data
locs_path <- file.path('input', 'fisher.csv')

# Path to land cover, legend
lc_path <- file.path('input', 'lc.tif')
legend_path <- file.path('input', 'fisher_legend.csv')

# Path to elevation
elev_path <- file.path('input', 'elev.tif')

# Path to population density
popdens_path <- file.path('input', 'popdens.tif')

# Path to water
water_path <- file.path('input', 'water.gpkg')

# Variables ---------------------------------------------------------------
# Targets: prepare
id <- 'id'
datetime <- 't_'
x <- 'x_'
y <- 'y_'
epsg <- 32618
crs <- st_crs(epsg)
crs_sp <- CRS(crs$wkt)
tz <- 'America/New_York'

# Split by: within which column or set of columns (eg. c(id, yr))
#  do we want to split our analysis?
split_by <- id

# Resampling rate
rate <- minutes(30)

# Tolerance
tolerance <- minutes(5)

# Number of random steps
n_random_steps <- 10



# Targets: data -----------------------------------------------------------
targets_data <- c(
	tar_file_read(
		locs_raw,
		locs_path,
		fread(!!.x)
	),
	tar_file_read(
		lc,
		lc_path,
		raster(!!.x)
	),
	tar_file_read(
		legend,
		legend_path,
		fread(!!.x)
	),
	tar_file_read(
		elev,
		elev_path,
		raster(!!.x)
	),
	tar_file_read(
		popdens,
		popdens_path,
		raster(!!.x)
	),
	tar_file_read(
		water,
		water_path,
		st_read(!!.x)
	)
)




# Targets: prep -----------------------------------------------------------
targets_prep <- c(
	tar_target(
		locs_prep,
		prepare_locs(locs_raw, id, datetime, tz, x, y, split_by),
		iteration = 'group'
	),
	tar_target(
		split_key,
		unique(locs_prep[, .SD, .SDcols = c(split_by, 'tar_group')])
	)
)




# Targets: tracks ---------------------------------------------------------
targets_tracks <- c(
	tar_target(
		tracks,
		make_track(locs_prep, x_, y_, t_, all_cols = TRUE, crs = crs_sp),
		pattern = map(locs_prep)
	),
	tar_target(
		tracks_resampled,
		resample_tracks(tracks, rate = rate, tolerance = tolerance),
		pattern = map(tracks)
	),
	tar_target(
		tracks_random,
		random_steps(tracks_resampled, n = n_random_steps),
		pattern = map(tracks_resampled)
	)
)



# Targets -----------------------------------------------------------------
list(
	# Sample distance to water
	tar_target(
		water,
		polygonize_lc_class(lc, class = 11)
	),

	tar_target(
		distto,
		splits[, distto_water := eval_dist(.SD, water, coords = c(x, y), crs = crs)],
		pattern = map(splits)
	),


	# Make tracks. Note from here on, when we want to iterate use pattern = map(x)
	#  where x is the upstream target name


	# Check step distributions
	#  iteration = 'list' used for returning a list of ggplots,
	#  instead of the usual combination with vctrs::vec_c()
	tar_target(
		distributions,
		ggplot(resamples, aes(sl_)) + geom_density(alpha = 0.4),
		pattern = map(resamples),
		iteration = 'list'
	),





	# Distribution parameters
	tar_target(
		distparams,
		calc_distribution_parameters(randsteps),
		pattern = map(randsteps)
	),

	# Merge covariate legend
	tar_target(
		mergelc,
		merge(
			randsteps,
			legend,
			by.x = 'lc',
			by.y = 'Value',
			all.x = TRUE
		),
		pattern = map(randsteps)
	)



)



# Targets: all ------------------------------------------------------------
# Automatically grab all the "targets_*" lists above
lapply(grep('targets', ls(), value = TRUE), get)
