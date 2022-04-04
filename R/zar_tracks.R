#' zar_tracks
#'
#' @return
#' @export
#'
#' @examples
zar_tracks <-
	function(data,
					 crs,
					 rate,
					 tolerance,
					 packages = targets::tar_option_get("packages"),
					 library = targets::tar_option_get("library"),
					 format = "qs",
					 error = targets::tar_option_get("error"),
					 memory = targets::tar_option_get("memory"),
					 garbage_collection = targets::tar_option_get("garbage_collection"),
					 deployment = targets::tar_option_get("deployment"),
					 priority = targets::tar_option_get("priority"),
					 cue = targets::tar_option_get("cue")) {
		name <- 'locs'

		name_tracks_raw <- paste(name, 'tracks', 'raw', sep = '_')
		name_tracks <- paste(name, 'tracks', sep = '_')
		name_resample <- paste(name, 'resample', sep = '_')
		name_random <- paste(name, 'random', sep = '_')


		command_tracks_raw <- substitute(data)
		command_tracks <- substitute(make_track(tracks, x_, y_, t_, all_cols = TRUE, crs = crs_sp),
																 env = list(tracks = as.symbol(name_tracks_raw)))
		# command_resample <- substitute(brms::brmsformula(formula))
		# command_random <- substitute(priors)


		target_tracks_raw <- tar_target_raw(
			name = name_tracks_raw,
			command = command_tracks_raw,
			packages = packages,
			library = library,
			format = format,
			error = error,
			memory = memory,
			garbage_collection = garbage_collection,
			deployment = deployment,
			priority = priority,
			cue = cue
		)
		target_tracks <- tar_target_raw(
			name = name_tracks,
			command = command_tracks,
			packages = packages,
			library = library,
			format = format,
			error = error,
			memory = memory,
			garbage_collection = garbage_collection,
			deployment = deployment,
			priority = priority,
			cue = cue
		)

		return(list(target_tracks_raw,
								target_tracks
								# target_data,
								# target_sample_tracks,
								# target_stancode,
								# target_sample))
		))
								}
