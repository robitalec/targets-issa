# === Targets workflow: iSSA with amt -------------------------------------
# Alec L. Robitaille, Julie W. Turner



# Packages ----------------------------------------------------------------
library(targets)

library(amt)
library(data.table)
library(sf)
library(ggplot2)
library(raster)

library(parsedate)

# Functions ---------------------------------------------------------------
source('R/functions.R')


# Options -----------------------------------------------------------------
tar_option_set(format = 'qs',
							 error = 'workspace')


# Data --------------------------------------------------------------------
# Fisher
fish_path <- 'input/fisher.csv'

# Land cover
lc <- raster('input/lc.tif')
legend <- fread('input/fisher_legend.csv')

# Elevation
elev <- raster('input/elev.tif')

# Population density
popdens <-  raster('input/popdens.tif')

# Variables ---------------------------------------------------------------
id <- 'id'
datetime <- 't_'
x <- 'x_'
y <- 'y_'
crs <- st_crs(32618)
spcrs <- CRS(crs$wkt)
tz <- grep('Montreal', OlsonNames(), value = TRUE)

# Split by: within which column or set of columns (eg. c(id, yr))
#  do we want to split our analysis?
splitBy <- id


# Resampling rate
rate <- minutes(30)

# Tolerance
tolerance <- minutes(5)

# Number of random steps
nrandom <- 10

# Targets -----------------------------------------------------------------
list(
	# Read input data
	tar_target(
		input,
		fread(fish_path)[, t_ := parse_date(t_, default_tz = tz)]
	),

	# Remove duplicated and incomplete observations
	tar_target(
		mkunique,
		make_unique_complete(input, id, datetime, x, y)
	),

	# Set up split -- these are our iteration units
	tar_target(
		splits,
		mkunique[, tar_group := .GRP, by = splitBy],
		iteration = 'group'
	),

	tar_target(
		splitsnames,
		unique(mkunique, by = splitBy)
	),

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
	tar_target(
		tracks,
		make_track(distto, x_, y_, t_, all_cols = TRUE, crs = spcrs),
		pattern = map(distto)
	),

	# Resample sampling rate
	tar_target(
		resamples,
		resample_tracks(tracks, rate = rate, tolerance = tolerance),
		pattern = map(tracks)
	),

	# Check step distributions
	#  iteration = 'list' used for returning a list of ggplots,
	#  instead of the usual combination with vctrs::vec_c()
	tar_target(
		distributions,
		ggplot(resamples, aes(sl_)) + geom_density(alpha = 0.4),
		pattern = map(resamples),
		iteration = 'list'
	),



	# Create random steps and extract covariates
	tar_target(
		randsteps,
		make_random_steps(resamples, lc, elev, popdens),
		pattern = map(resamples)
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
	),

	# Make unique step ID per individual
	tar_target(
		stepID,
		make_step_id(mergelc)
	)

)
