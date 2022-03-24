library(targets)
library(glmmTMB)
library(data.table)

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
## making lc a factor
stepID[, lc := as.factor(lc)]
stepID[, indiv_step_id := as.factor(indiv_step_id)]


mod.1 <- glmmTMB(case_ ~ I(log(sl_)) + I(log(sl_)):tod_start_ + I(cos(ta_))+ distto + distto:I(log(sl_)) +
					(1|indiv_step_id) +
					(0+ I(log(sl_))|id) +
					(0+ I(log(sl_)):tod_start_|id) +
						(0+ I(cos(ta_))|id) +
					(0+ distto|id) +
					(0+ distto:I(log(sl_))|id),
					 data = stepID, family= poisson(),
				map= list(theta = factor(c(NA,1:7))),
				start = list(theta =c(log(1000), seq(0,0, length.out = 7)))
					)
summary(mod.1)

# can't estimate error --- why?
stepID[case_ == T, range(distto)]
stepID[case_ == F, quantile(distto)]

stepID[case_ == F, quantile(sl_)]

summary(stepID$tod_start_)

# try simplifying -- rm intx sl X distto
mod.2 <- glmmTMB(case_ ~ I(log(sl_)) + I(log(sl_)):tod_start_ + distto +
							 	(1|indiv_step_id) +
							 	(0+ I(log(sl_))|id) +
							 	(0+ I(log(sl_)):tod_start_|id) +
							 	(0+ distto|id) ,
							 data = stepID, family= poisson(),
							 map= list(theta = factor(c(NA,1:5))),
							 start = list(theta =c(log(1000), seq(0,0, length.out = 5)))
)
summary(mod.2)

### popden model
mod.a <- glmmTMB(case_ ~ I(log(sl_)) +
								 	I(log(sl_)):tod_start_ +
								 	elev +
								 #	popdens +
								 	(1|indiv_step_id) +
								 	(0+ I(log(sl_))|id) +
								 	(0+ I(log(sl_)):tod_start_|id) +
								 	(0+ elev|id), # +
								 #	(0+ popdens|id) ,
								 data = stepID, family= poisson(),
								 map= list(theta = factor(c(NA,1:5))),
								 start = list(theta =c(log(1000), seq(0,0, length.out = 5)))
)
summary(mod.a)

