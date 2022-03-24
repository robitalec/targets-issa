library(targets)

## Run the full workflow
tar_make()

## Inspect output with tar_read or tar_load
# *Read* one branch (individual in this case)
tar_read(tracks, 1)
tar_read(tracks, 2)

# Or all combined
tar_read(tracks)

# Plot all distributions
tar_read(distributions)

# *Load* all random steps and extracted landscape value
tar_load(mergelc)


glmmtmb(case_ ~ I(log(sl_)) + I(log(sl_)):tod_start + distto + distto:I(log(sl_)) +
					(1|indiv_step_id) + ## NEED TO MAKE THIS
					(0+ I(log(sl_))|id) +
					(0+))
