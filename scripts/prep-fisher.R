library(sf)
library(data.table)
library(terra)

data('amt_fisher', package = 'amt')


crs <- attr(amt_fisher, 'crs_')
outcrs <- st_crs(32618)

sffish <- st_as_sf(amt_fisher, coords = c('x_', 'y_'),
									 crs = crs)

outfish <- st_transform(sffish, outcrs)
st_write(outfish, 'input/fisher.csv',
				 layer_options = "GEOMETRY=AS_XY")

DT <- fread('input/fisher.csv')
setnames(DT, c('X', 'Y'), c('x_', 'y_'))
fwrite(DT, 'input/fisher.csv')

data("amt_fisher_covar", package = 'amt')
attr(amt_fisher_covar$landuse, 'crs')
attr(amt_fisher_covar$elev, 'crs')
attr(amt_fisher_covar$popden, 'crs')

lc <- rast(amt_fisher_covar$landuse)
elev <- rast(amt_fisher_covar$elev)
popden <- rast(amt_fisher_covar$popden)

lcout <- project(lc, outcrs$wkt, method = 'near')
elevout <- project(elev, outcrs$wkt)
popdensout <- project(popden, outcrs$wkt)

writeRaster(lcout, 'input/lc.tif', overwrite= T)
writeRaster(elevout, 'input/elev.tif', overwrite= T)
writeRaster(popdensout, 'input/popdens.tif', overwrite= T)
