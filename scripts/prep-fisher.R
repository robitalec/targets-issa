library(sf)
library(data.table)
library(terra)

# lc <- read_stars('../caribou_WBI_iSSA/data/raw-data/CanLCC.tif')
data('amt_fisher', package = 'amt')


crs <- attr(amt_fisher, 'crs_')
# lccrs <- st_crs(lc)
outcrs <- st_crs(32618)

sffish <- st_as_sf(amt_fisher, coords = c('x_', 'y_'),
									 crs = crs)

# lcfish <- st_transform(sffish, lccrs)
# lcfish$lc <- st_extract(lc, at = lcfish)[['CanLCC.tif']]

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

lcout <- project(lc, outcrs$wkt)
elevout <- project(elev, outcrs$wkt)
popdensout <- project(popden, outcrs$wkt)

writeRaster(lcout, 'input/lc.tif')
writeRaster(elevout, 'input/elev.tif')
writeRaster(popdensout, 'input/popdens.tif')
