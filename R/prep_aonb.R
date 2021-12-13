# Prep AONB
library(sf)
library(tmap)
library(dplyr)
library(tidyr)
tmap_mode("view")

dir.create("tmp")

unzip("D:/OneDrive - University of Leeds/Data/Areas of Oustanding Natural Beauty/NE_AreasOfOutstandingNaturalBeautyEngland_SHP_Full.zip",
      exdir = "tmp")

aonb <- read_sf("tmp/data/Areas_of_Outstanding_Natural_Beauty_England.shp")
aonb <- aonb$geometry
unlink("tmp", recursive = TRUE)
qtm(aonb)

aonb <- st_transform(aonb, 4326)

st_write(aonb, "data/aonb.geojson", delete_dsn = TRUE)

zip::zip("data/aonb.geojson.zip", 
         files = "data/aonb.geojson", 
         include_directories = FALSE,
         mode = "cherry-pick")

pb_upload("data/aonb.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")

unlink("data/aonb.geojson")


