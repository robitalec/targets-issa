library(sf)
library(data.table)
library(terra)

fishers <- fread(file.path('input', 'fisher_data.csv'))
summary(as.factor(fishers$id))
# only 4 individuals in amt data, need more for glmm
# data('amt_fisher', package = 'amt')
amt_fisher <- fishers

#crs <- attr(amt_fisher, 'crs_')
crs <- st_crs(4326)
outcrs <- st_crs(32618)

sffish <- st_as_sf(amt_fisher, coords = c('x', 'y'),
									 crs = crs)

outfish <- st_transform(sffish, outcrs)
st_write(outfish, 'input/fisher.csv',
				 layer_options = "GEOMETRY=AS_XY", append = F)

DT <- fread('input/fisher.csv')
setnames(DT, c('x', 'y', 't'), c('x_', 'y_','t_'))
fwrite(DT, 'input/fisher.csv')

data("amt_fisher_covar", package = 'amt')
attr(amt_fisher_covar$landuse, 'crs')
attr(amt_fisher_covar$elev, 'crs')
attr(amt_fisher_covar$popden, 'crs')

#lc <- rast(amt_fisher_covar$landuse)
lc <- rast(file.path('input', 'landuse_study_area.tif'))
elev <- rast(amt_fisher_covar$elev)
popden <- rast(amt_fisher_covar$popden)

lcout <- project(lc, outcrs$wkt, method = 'near')
elevout <- project(elev, outcrs$wkt)
popdensout <- project(popden, outcrs$wkt)

writeRaster(lcout, 'input/lc.tif', overwrite= T)
writeRaster(elevout, 'input/elev.tif', overwrite= T)
writeRaster(popdensout, 'input/popdens.tif', overwrite= T)
