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


### landcover model
mod.a <- glmmTMB(case_ ~ -1 + I(log(sl_)) +
								 	I(log(sl_)):lc_adj +
								 	lc_adj +
								 	I(log(distto_water+1)) +
								 	I(log(distto_water+1)):I(log(sl_)) +
								 	(1|indiv_step_id) +
								 	(0+ I(log(sl_))|id) +
								 	(0+ I(log(sl_)):lc_adj|id) +
								 	(0+ lc_adj|id) +
								 	(0+ I(log(distto_water+1))|id) +
								 	(0+ I(log(distto_water+1)):I(log(sl_))|id),
								 data = stepID, family= poisson(),
								 map= list(theta = factor(c(NA,1:23))),
								 start = list(theta =c(log(1000), seq(0,0, length.out = 23)))
)
summary(mod.a)

## Doesn't converge, let's check out
# DT <- stepID[case_=='FALSE', n_by_case  := .N, by = .(lc_adj)]
# unique(DT[, n_by_case / .N, by = lc_adj])
unique(stepID[case_=='FALSE', n_by_case  :=  .N, by = .(lc_adj)][,  n_by_case / .N, by = .(lc_adj)]
)
stepID[case_=='FALSE',quantile(distto_water)]

# issue could be too many levels for amount of data
# so lets simplify to just the lc varibales that I decided were interesting to our pretend question
stepID[,forest := ifelse(description=='forest',1,0)]
stepID[,disturbed := ifelse(lc_adj=='disturbed',1,0)]

### forest model
mod.b <- glmmTMB(case_ ~ -1 + I(log(sl_)) +
								 	I(log(sl_)):forest +
								 	forest +
								 	I(log(sl_)):disturbed +
								 	disturbed +
								 	I(log(distto_water+1)) +
								 	I(log(distto_water+1)):I(log(sl_)) +
								 	(1|indiv_step_id) +
								 	(0+ I(log(sl_))|id) +
								 	(0+ I(log(sl_)):disturbed|id) +
								 	(0+ I(log(sl_)):forest|id) +
								 	(0+ forest|id) +
								 	(0+ disturbed|id) +
								 	(0+ I(log(distto_water+1))|id) +
								 	(0+ I(log(distto_water+1)):I(log(sl_))|id),
								 data = stepID, family= poisson(),
								 map= list(theta = factor(c(NA,1:7))),
								 start = list(theta =c(log(1000), seq(0,0, length.out = 7)))
)
summary(mod.b)


