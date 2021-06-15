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

# Targets -----------------------------------------------------------------
list(
	tar_target(
		input,
		fread(path)
	),
	tar_target(
		mkunique,
		unique(input, by = c(id, datetime))
	)
)
