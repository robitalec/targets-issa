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
id_col <- 'id'
datetime_col <- 't_'
x_col <- 'x_'
y_col <- 'y_'
epsg <- 32618
crs <- st_crs(epsg)
crs_sp <- CRS(crs$wkt)
tz <- 'America/New_York'

# Targets: tracks
# Split by: within which column or set of columns (eg. c(id, yr))
#  do we want to split our analysis?
split_by <- id_col

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
		prepare_locs(locs_raw, id_col, datetime_col, tz, x_col, y_col, split_by),
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
		make_track(locs_prep, x_, y_, t_, all_cols = TRUE, crs = epsg),
		pattern = map(locs_prep)
	),
	tar_target(
		tracks_resampled,
		resample_tracks(tracks, rate = rate, tolerance = tolerance),
		pattern = map(tracks)
	),
	tar_target(
		seq_n_random,
		{x <- rep(c(5, 100, 250), each = 5); x; setNames(x, seq_along(x))}
	),
	tar_target(
		tracks_random,
		{r <- random_steps(tracks_resampled, n = seq_n_random)
		 r$n_random <- seq_n_random
		 r$id_random <- names(seq_n_random)
		 r},
		pattern = cross(tracks_resampled, seq_n_random)
	)
)



# Targets: extract --------------------------------------------------------
targets_extract <- c(
	tar_target(
		tracks_extract,
		extract_layers(
			tracks_random,
			crs,
			lc,
			legend,
			elev,
			popdens,
			water
		)
	),
	tar_target(
		avail_lc,
		calc_availability(tracks_extract, 'lc_description', 'proportion', split_by)
	)
)



# Targets: distributions --------------------------------------------------
targets_distributions <- c(
	tar_target(
		dist_parameters,
		calc_distribution_parameters(tracks_random),
		pattern = map(tracks_random)
	),
	tar_target(
		dist_sl_plots,
		plot_distributions(tracks_resampled, 'sl_'),
		pattern = map(tracks_resampled),
		iteration = 'list'
	),
	tar_target(
		dist_ta_plots,
		plot_distributions(tracks_resampled, 'ta_'),
		pattern = map(tracks_resampled),
		iteration = 'list'
	)
)




# Targets: model ----------------------------------------------------------
targets_model <- c(
	tar_target(
		model_prep,
		prepare_model(tracks_extract[
			tracks_extract$n_random == seq_n_random &
				tracks_extract$id_random == names(seq_n_random),]),
		pattern = map(seq_n_random)
	),
	tar_target(
		model_lc,
		model_land_cover(model_prep),
		pattern = map(model_prep),
		iteration = 'list'
	),
	tar_target(
		model_forest,
		model_forest_bin(model_prep),
		pattern = map(model_prep),
		iteration = 'list'
	),
	tar_target(
		model_check_lc,
		model_check(model_lc),
		pattern = map(model_lc)
	),
	tar_target(
		model_check_forest,
		model_check(model_forest),
		pattern = map(model_forest)
	)
)


# Targets: fixed effects -------------------------------------------------------
targets_fixed <- c(
	tar_target(
		fixef_summary,
		data.table(estimate = fixef(model_forest)$cond,
							 term = names(fixef(model_forest)$cond),
							 n_random = seq_n_random),
		pattern = map(model_forest, seq_n_random)
	),
	tar_target(
		plot_box_fixef,
		plot_box(fixef_summary, plot_theme())
	)
)

# Targets: output and effects ------------------------------------------------------------
targets_effects <- c(
	tar_target(
		indiv_summary,
		indiv_estimates(model_forest)
	),
	tar_target(
		plot_boxplot,
		plot_box_horiz(indiv_summary, plot_theme())
	)
)

# Targets: speed ------------------------------------------------------------
targets_speed <- c(
	tar_target(
		prep_speed,
		prepare_speed(
			DT  = model_prep,
			summary = indiv_summary,
			params = dist_parameters
		)
	),
	tar_target(
		calc_speed_disturbed,
		calc_speed(prep_speed, 'disturbed', seq = 0:1)
	),
	tar_target(
		plot_speed_disturbed,
		plot_box(calc_speed_disturbed, plot_theme()) +
			labs(x = 'Not disturbed vs disturbed', y = 'Speed (m/30mins)')
	)
)

# Targets: RSS ------------------------------------------------------------
targets_rss <- c(
	tar_target(
		pred_h1_water,
		predict_h1_water(model_prep, model_forest)
	),
	tar_target(
		pred_h1_forest,
		predict_h1_forest(model_prep, model_forest)
	),
	tar_target(
		pred_h2,
		predict_h2(model_prep, model_forest)
	),
	tar_target(
		rss_forest,
		calc_rss(pred_h1_forest, 'h1_forest', pred_h2, 'h2')
	),
	tar_target(
		rss_water,
		calc_rss(pred_h1_water, 'h1_water', pred_h2, 'h2')
	),
	tar_target(
		plot_rss_forest,
		plot_rss(rss_forest, plot_theme()) +
			labs(x = 'Forest', y = 'logRSS',
					 title = 'RSS compared to 0 forest')
	),
	tar_target(
		plot_rss_water,
		plot_rss(rss_water, plot_theme()) +
			labs(x = 'Water', y = 'logRSS',
					 title = 'RSS compared to mean distance from water')
	)
)



# Targets: all ------------------------------------------------------------
# Automatically grab and combine all the "targets_*" lists above
lapply(grep('targets', ls(), value = TRUE), get)
