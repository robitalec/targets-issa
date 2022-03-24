library(targets)
library(glmmTMB)

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
tar_load(stepID)


mod.1 <- glmmTMB(case_ ~ I(log(sl_)) + I(log(sl_)):tod_start_ + distto + distto:I(log(sl_)) +
					(1|indiv_step_id) +
					(0+ I(log(sl_))|id) +
					(0+ I(log(sl_)):tod_start_|id) +
					(0+ distto) +
					(0+ distto + distto:I(log(sl_))),
					 data = stepID, family= poisson(),
				map= list(theta = factor(c(NA,1:4))),
				start = list(theta =c(log(1000), seq(0,0, length.out = 4)))
					)
summary(mod.1)

# convergence problem --- why?
stepID[case_ == T, range(distto)]
stepID[case_ == F, quantile(distto)]

stepID[case_ == F, quantile(sl_)]

summary(stepID$tod_start_)

# try simplifying -- rm intx sl X distto
mod.2 <- glmmTMB(case_ ~ I(log(sl_)) + I(log(sl_)):tod_start_ + distto +
							 	(1|indiv_step_id) +
							 	(0+ I(log(sl_))|id) +
							 	(0+ I(log(sl_)):tod_start_|id) +
							 	(0+ distto) ,
							 data = stepID, family= poisson(),
							 map= list(theta = factor(c(NA,1:4))),
							 start = list(theta =c(log(1000), seq(0,0, length.out = 4)))
)
summary(mod.2)

