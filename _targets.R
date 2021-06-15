# === Targets workflow: iSSA with amt -------------------------------------
# Alec L. Robitaille


# Packages ----------------------------------------------------------------
library(targets)

library(amt)
library(data.table)

# Functions ---------------------------------------------------------------
source('R/functions.R')


# Options -----------------------------------------------------------------
tar_option_set(format = 'qs')


# Variables ---------------------------------------------------------------
path <- file.path('input', 'test.csv')
id <- 'id'
datetime <- 'datetime'

# Split by: within which column or set of columns (eg. c(id, yr))
#  do we want to split our analysis?
splitBy <- id


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
)
