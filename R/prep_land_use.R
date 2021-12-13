library(stars)
library(sf)

r <- read_stars("D:/OneDrive - University of Leeds/Data/Corine Land Cover/83684d24c50f069b613e0dc8e12529b893dc172f/u2018_clc2018_v2020_20u1_raster100m/u2018_clc2018_v2020_20u1_raster100m/DATA/U2018_CLC2018_V2020_20u1.tif")
bounds <- st_read("../../ITSleeds/NTEM2OD/data/MSOA/regions.gpkg")
bounds <- st_combine(bounds)
bounds <- st_transform(bounds, 27700)
bounds <- st_buffer(bounds, 10000)
bounds <- st_transform(bounds, st_crs(r))

bb <- st_bbox(bounds)

r2 <- st_crop(r, bb)
write_stars(r2, "data/land_use_3035.tif")


# r4326 <- st_warp(r2, crs = st_crs(4326))
# 
# 
# 
# r3 <- st_transform(r2, 4326)
# 
# bounds <- st_transform(bounds, 4326)
# bb <- st_bbox(bounds)
# r4 <- st_crop(r3, bb)
# plot(r4)
# 
# vals <- unique(r3)
# stars:::is_regular_grid(r4)
# 
# r5 <- st_warp(r4, crs = st_crs(bounds))
# plot(r5)
# write_stars(r5, "data/land_use.tif")
