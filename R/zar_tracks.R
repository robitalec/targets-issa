zar_tracks <- function(crs_sp, rate, tolerance) {
	# sym_file <- as.symbol(name_file)
	# command_data <- substitute(read_data(file), env = list(file = sym_file))

	c(
		tar_target(
			tracks,
			make_track(prep_locs, x_, y_, t_, all_cols = TRUE, crs = crs_sp)
		),
		# tar_target_raw(
		# 	'tracks',
		# 	substitute(
		# 		make_track(DT_sym, x_, y_, t_, all_cols = TRUE, crs = crs_sp),
		# 		env = list(DT_sym = deparse(substitute(name)))
		# 	)
		# ),
		tar_target(
			resamples,
			resample_tracks(tracks, rate = rate, tolerance = tolerance),
			pattern = map(tracks)
		)
	)
}
