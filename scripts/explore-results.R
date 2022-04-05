library(targets)
library(glmmTMB)
library(data.table)
library(ggplot2)
library(ggthemes)

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
stepID[, dist_to_water := units::drop_units(dist_to_water)]
summary(stepID$id)


### landcover model
mod.a <- glmmTMB(case_ ~ -1 + I(log(sl_)) +
								 	I(log(sl_)):lc_adj +
								 	lc_adj +
								 	I(log(dist_to_water+1)) +
								 	I(log(dist_to_water+1)):I(log(sl_)) +
								 	(1|indiv_step_id) +
								 	(0+ I(log(sl_))|id) +
								 	(0+ I(log(sl_)):lc_adj|id) +
								 	(0+ lc_adj|id) +
								 	(0+ I(log(dist_to_water+1))|id) +
								 	(0+ I(log(dist_to_water+1)):I(log(sl_))|id),
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
stepID[case_=='FALSE',quantile(dist_to_water)]

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
								 	I(log(dist_to_water+1)) +
								 	I(log(dist_to_water+1)):I(log(sl_)) +
								 	(1|indiv_step_id) +
								 	(0+ I(log(sl_))|id) +
								 	(0+ I(log(sl_)):disturbed|id) +
								 	(0+ I(log(sl_)):forest|id) +
								 	(0+ forest|id) +
								 	(0+ disturbed|id) +
								 	(0+ I(log(dist_to_water+1))|id) +
								 	(0+ I(log(dist_to_water+1)):I(log(sl_))|id),
								 data = stepID, family= poisson(),
								 map= list(theta = factor(c(NA,1:7))),
								 start = list(theta =c(log(1000), seq(0,0, length.out = 7)))
)
summary(mod.b)



#### RSS ####
### predict method
p.h2.indiv <- function(ids, DT, mod){
	lapply(ids, function(i) {
		unique(
			DT[
				,.(h2 = predict(
					mod,
					newdata = .SD[, .(
						sl_ = mean(sl_),
						forest =0,
						disturbed =0,
						dist_to_water= median(dist_to_water, na.rm = T),
						indiv_step_id = NA,
						id = i
					)],
					type = "link",
					re.form = NULL
				), id = i)]
		)
	})}


p.h1.indiv.forest <- function(ids, DT, mod){
	lapply(ids, function(i) {
		#unique(
		DT[
			,.(h1 = predict(
				mod,
				newdata = .SD[, .(
					sl_ = mean(sl_),
					forest = seq(from = 0, to = 1, length.out = 100),
					disturbed =0,
					dist_to_water= median(dist_to_water, na.rm = T),
					indiv_step_id = NA,
					id = i
				)],
				type = "link",
				re.form = NULL
			), id = i)]
		# )
	})
}

p.h1.indiv.dist <- function(ids, DT, mod){
	lapply(ids, function(i) {
		#unique(
		DT[
			,.(h1 = predict(
				mod,
				newdata = .SD[, .(
					sl_ = mean(sl_),
					forest = 0,
					disturbed =0,
					dist_to_water= seq(from = 0, to = 1500, length.out = 100),
					indiv_step_id = NA,
					id = i
				)],
				type = "link",
				re.form = NULL
			), id = i)]
		# )
	})
}

ids <- unique(stepID$id)

# h2 for RSS
h2.indiv <- rbindlist(p.h2.indiv(ids = ids, DT = stepID, mod = mod.b)
)

# h1 for forest
h1.indiv.forest <-p.h1.indiv.forest(ids = ids, DT = stepID, mod = mod.b)

# forest
h1.indiv.forest <- data.table(rbindlist(h1.indiv.forest), x = seq(from = 0, to = 1, length.out = 100))
#h2.indiv <- rbindlist(h2.indiv)

logRSS.forest <- merge(h1.indiv.forest, h2.indiv, by = c('id'), all.x = T)
logRSS.forest[,'rss'] <- logRSS.forest$h1 - logRSS.forest$h2

forest.rss <- ggplot(data=logRSS.forest, aes(x, rss)) +
	geom_line(aes(group = id ,alpha = .0001), linetype ='twodash', show.legend = F) +
	geom_smooth(size = 1.5, method = 'glm') +
	geom_hline(yintercept = 0,colour = "black",lty = 2, size = .7) +
	ylab("logRSS") + xlab("Forest") +
	ggtitle("RSS compared to 0 forest") + theme(plot.title = element_text(hjust = 0.5)) +
	theme_bw()  + theme(
		panel.border = element_blank(),
		panel.grid.major = element_blank(),
		panel.grid.minor = element_blank(),
		axis.line = element_line(colour = "black", size = .7)) +
	theme(plot.title=element_text(size=12,hjust = 0.05),axis.text.x = element_text(size=12), axis.title = element_text(size=15),axis.text.y = element_text(size=12)) +
	theme(axis.text.x = element_text(margin=margin(10,10,10,10,"pt")),
				axis.text.y = element_text(margin=margin(10,10,10,10,"pt")))+ theme(axis.ticks.length = unit(-0.25, "cm")) +
	scale_color_colorblind()  +
	scale_fill_colorblind()

forest.rss


### h1 for dist_to_water ----
h1.indiv.water <-p.h1.indiv.dist(ids = ids, DT = stepID, mod = mod.b)

# forest
h1.indiv.water <- data.table(rbindlist(h1.indiv.water), x = seq(from = 0, to = 1500, length.out = 100))

logRSS.water <- merge(h1.indiv.water, h2.indiv, by = c('id'), all.x = T)
logRSS.water[,'rss'] <- logRSS.water$h1 - logRSS.water$h2

water.rss <- ggplot(data=logRSS.water, aes(x, rss)) +
	geom_line(aes(group = id ,alpha = .0001), linetype ='twodash', show.legend = F) +
	geom_smooth(size = 1.5, method = 'loess') +
	geom_hline(yintercept = 0,colour = "black",lty = 2, size = .7) +
	ylab("logRSS") + xlab("Distance to Water (m)") +
	ggtitle("RSS compared to median distance") + theme(plot.title = element_text(hjust = 0.5)) +
	theme_bw()  + theme(
		panel.border = element_blank(),
		panel.grid.major = element_blank(),
		panel.grid.minor = element_blank(),
		axis.line = element_line(colour = "black", size = .7)) +
	theme(plot.title=element_text(size=12,hjust = 0.05),axis.text.x = element_text(size=12), axis.title = element_text(size=15),axis.text.y = element_text(size=12)) +
	theme(axis.text.x = element_text(margin=margin(10,10,10,10,"pt")),
				axis.text.y = element_text(margin=margin(10,10,10,10,"pt")))+ theme(axis.ticks.length = unit(-0.25, "cm")) +
	scale_color_colorblind()  +
	scale_fill_colorblind()

water.rss
