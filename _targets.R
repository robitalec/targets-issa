# === Targets workflow: iSSA with amt -------------------------------------
# Alec L. Robitaille, Julie W. Turner



# Packages ----------------------------------------------------------------
library(targets)

library(amt)
library(data.table)
library(sf)
library(sp)
library(ggplot2)

# Functions ---------------------------------------------------------------
source('R/functions.R')


# Options -----------------------------------------------------------------
tar_option_set(format = 'qs',
							 error = 'workspace')


# Variables ---------------------------------------------------------------
id <- 'id'
datetime <- 't_'
x <- 'x_'
y <- 'y_'
crs <- CRS(st_crs(31467)$wkt)


# Split by: within which column or set of columns (eg. c(id, yr))
#  do we want to split our analysis?
splitBy <- id


# Resampling rate
rate <- minutes(30)

# Tolerance
tolerance <- minutes(5)

# Fisher
data("amt_fisher", package = 'amt')

# Land cover
data("amt_fisher_covar", package = 'amt')
lc <- amt_fisher_covar$landuse

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
		make_track(splits, x, y, datetime, crs = crs, id = id),
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

	# create random steps and extract covariates
	tar_target(
		randsteps,
		amt::random_steps(n=10) %>%
			amt::extract_covariates(inputland, where = "end") %>%
			amt::time_of_day(where = 'start'),
		pattern = map(resamples)
	)

)
