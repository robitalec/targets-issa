# === Targets workflow: iSSA with amt -------------------------------------
# Alec L. Robitaille, Julie W. Turner



# Packages ----------------------------------------------------------------
library(targets)

library(amt)
library(data.table)
library(sf)
library(ggplot2)
library(raster)

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
legend <- fread('input/legend.csv')

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
		data.table(amt_fisher)
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

	# Make tracks. Note from here on, when we want to iterate use pattern = map(x)
	#  where x is the upstream target name
	tar_target(
		tracks,
		make_track(splits, x_, y_, t_, crs = CRS(crs$wkt), id = id),
		pattern = map(splits)
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

	tar_target(
		urban,
		polygonize_lc_class(lc, class = 190)
	),

	# Sample distance to urban
	tar_target(
		distto,
		eval_dist(tracks, urban, coords = c(x, y), crs = crs),
		pattern = map(tracks)
	),

	# Create random steps and extract covariates
	tar_target(
		randsteps,
		make_random_steps(resamples, lc),
		pattern = map(resamples)
	),

	# Distribution parameters
	tar_target(
		sldist,
		calc_distribution_parameters(randsteps),
		pattern = map(randsteps)
	),

	# Merge covariate legend
	tar_target(
		mergelc,
		merge(
			randsteps,
			legend,
			by.x = 'landuse',
			by.y = 'Value',
			all.x = TRUE
		),
		pattern = map(randsteps)
	)

)
