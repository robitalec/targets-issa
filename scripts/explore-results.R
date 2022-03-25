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
summary(as.factor(stepID$description))
stepID[,forest := ifelse(description=='forest',1,0)]
stepID[description == 'forest', lc_adj := 'forest']
stepID[description %in% c('cultivated', 'developed'), lc_adj := 'disturbed']
stepID[description %in% c('barren', 'herbaceous', 'shrubland', 'water'), lc_adj := 'open']
stepID[description == 'wetlands', lc_adj := 'wetlands']
summary(as.factor(stepID$lc_adj))

stepID[, lc := as.factor(lc)]
stepID[, lc_adj := as.factor(lc_adj)]
stepID[, indiv_step_id := as.factor(indiv_step_id)]
stepID[, id := as.factor(id)]
stepID[, distto_water := units::drop_units(distto_water)]
summary(stepID$id)


mod.1 <- glmmTMB(case_ ~ -1 + I(log(sl_)) +
								 	I(log(sl_)):tod_start_ +
								 	I(log(distto_water+1)) +
								 	I(log(distto_water+1)):I(log(sl_)) +
					(1|indiv_step_id) +
					(0+ I(log(sl_))|id) +
					(0+ I(log(sl_)):tod_start_|id) +
					(0+ I(log(distto_water+1))|id) +
					(0+ I(log(distto_water+1)):I(log(sl_))|id),
					 data = stepID, family= poisson(),
				map= list(theta = factor(c(NA,1:6))),
				start = list(theta =c(log(1000), seq(0,0, length.out = 6)))
					)
summary(mod.1)

# can't estimate error --- why?
stepID[case_ == T, range(distto_water)]
stepID[case_ == F, quantile(distto_water)]

stepID[case_ == F, quantile(sl_)]

summary(stepID$tod_start_)

# try simplifying -- rm intx sl X distto
mod.2 <- glmmTMB(case_ ~ -1 + I(log(sl_)) +
								 	I(log(sl_)):tod_start_ +
								 	I(log(distto_water+1)) +
								 	(1|indiv_step_id) +
								 	(0+ I(log(sl_))|id) +
								 	(0+ I(log(sl_)):tod_start_|id) +
								 	(0+ I(log(distto_water+1))|id),
								 data = stepID, family= poisson(),
								 map= list(theta = factor(c(NA,1:5))),
								 start = list(theta =c(log(1000), seq(0,0, length.out = 5)))
)
summary(mod.2)

### forest model
mod.a <- glmmTMB(case_ ~ -1 + I(log(sl_)) +
								 	#I(log(sl_)):tod_start_ +
								 	I(log(sl_)):forest +
								 	forest +
								 	I(log(distto_water+1)) +
								 	I(log(distto_water+1)):I(log(sl_)) +
								 	(1|indiv_step_id) +
								 	(0+ I(log(sl_))|id) +
								 	#(0+ I(log(sl_)):tod_start_|id) +
								 	(0+ I(log(sl_)):forest|id) +
								 	(0+ forest|id) +
								 	(0+ I(log(distto_water+1))|id) +
								 	(0+ I(log(distto_water+1)):I(log(sl_))|id),
								 data = stepID, family= poisson(),
								 map= list(theta = factor(c(NA,1:5))),
								 start = list(theta =c(log(1000), seq(0,0, length.out = 5)))
)
summary(mod.a)

DT <- stepID[case_=='FALSE', n_by_case  := .N, by = .(lc_adj)]
unique(DT[, n_by_case / .N, by = lc_adj])
unique(stepID[case_=='FALSE', n_by_case  :=  .N, by = .(lc_adj)][,  n_by_case / .N, by = .(lc_adj)]
)
