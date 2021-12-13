# Prep AONB
library(sf)
library(tmap)
library(dplyr)
library(tidyr)
library(piggyback)
tmap_mode("view")

dir.create("data/flooding")
download.file(url = "https://environment.data.gov.uk/UserDownloads/interactive/14d8e927c20149589d6e068351e924a373092/EA_FloodMapForPlanningRiversAndSeaFloodZone2_GeoJSON_Full.zip",
              destfile = "data/flooding/floodzone2.zip")
download.file(url = "https://environment.data.gov.uk/UserDownloads/interactive/9b8c69809ce044b1bf9388c7d5bc028259864/EA_FloodMapForPlanningRiversAndSeaFloodZone3_GeoJSON_Full.zip",
              destfile = "data/flooding/floodzone3.zip")

dir.create("tmp")
unzip("data/flooding/floodzone2.zip",
      exdir = "tmp")
flood2 <- st_read("tmp/data/Flood_Map_for_Planning_Rivers_and_Sea_Flood_Zone_2.json")
unlink("tmp", recursive = TRUE)

dir.create("tmp")
unzip("data/flooding/floodzone3.zip",
      exdir = "tmp")
flood3 <- st_read("tmp/data/Flood_Map_for_Planning_Rivers_and_Sea_Flood_Zone_3.json")
unlink("tmp", recursive = TRUE)

# dir.create("tmp")
# unzip("data/flooding/National_Flood_Risk_Wales.zip",
#       exdir = "tmp")
# wales <- st_read("tmp/")
# unlink("tmp", recursive = TRUE)


flood2 <- st_transform(flood2, 4326)
flood3 <- st_transform(flood3, 4326)

flood2 <- flood2$geometry
flood3 <- flood3$geometry

head(flood2)
summary(st_is_valid(flood2))
summary(st_is_valid(flood3))

flood2_cast <- st_cast(flood2, "POLYGON")
flood3_cast <- st_cast(flood3, "POLYGON")


flood2_cast <- data.frame(type = 2, geometry = flood2_cast)
flood3_cast <- data.frame(type = 3, geometry = flood3_cast)

flood2_cast <- st_as_sf(flood2_cast)
flood3_cast <- st_as_sf(flood3_cast)

grid <- st_make_grid(flood2_cast)
inter2 <- st_intersects(flood2_cast[1:10,], grid)

head(flood2_cast)

flood_all <- rbind(flood2_cast,flood3_cast)

st_write(flood_all,"data/flooding/floodzones.geojson")

zip::zip("data/floodzones.geojson.zip", 
         files = "data/flooding/floodzones.geojson", 
         include_directories = FALSE,
         mode = "cherry-pick")

pb_upload("data/floodzones.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")


flood_all$area <- as.numeric(st_area(flood_all))

flood_large <- flood_all[flood_all$area > 1,]
foo <- flood_all[flood_all$area > 1e7,]
