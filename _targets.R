# === Targets workflow: iSSA with amt -------------------------------------
# Alec L. Robitaille


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
tar_option_set(format = 'qs')


# Variables ---------------------------------------------------------------
path <- file.path('input', 'test.csv')
id <- 'id'
datetime <- 'datetime'
long <- 'long'
lat <- 'lat'
crs <- CRS(st_crs(4326)$wkt)


# Split by: within which column or set of columns (eg. c(id, yr))
#  do we want to split our analysis?
splitBy <- id


# Resampling rate (hours)
rate <- 5

# Tolerance (minutes)
tolerance <- 30


# Targets -----------------------------------------------------------------
list(
	# Read input data
	tar_target(
		input,
		fread(path)
	),

	# Remove duplicated id*datetime rows
	tar_target(
		mkunique,
		unique(input, by = c(id, datetime))
	),

	# Set up split -- these are our iteration units
	tar_target(
		splits,
		mkunique[, tar_group := .GRP, by = splitBy],
		iteration = 'group'
	),
	tar_target(
		splitsnames,
		unique(mkunique[, .(path = path), by = splitBy])
	),

	# Make tracks. Note from here on, when we want to iterate use pattern = map(x)
	#  where x is the upstream target name
	tar_target(
		tracks,
		make_track(splits, long, lat, datetime, crs = crs, id = id),
		pattern = map(splits)
	),

	# Resample sampling rate
	tar_target(
		resamples,
		track_resample(tracks, rate = hours(rate), tolerance = minutes(tolerance)) %>%
			filter_min_n_burst() %>% steps_by_burst(., lonlat = T),
		pattern = map(tracks)
	),

	# Check step distributions
	tar_target(
		distributions,
		ggplot(resamples, aes(sl_, fill = factor(id))) + geom_density(alpha = 0.4),
		pattern = map(resamples)
	)
)
