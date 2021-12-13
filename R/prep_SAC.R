# Prep AONB
library(sf)
library(tmap)
library(dplyr)
library(tidyr)
library(piggyback)
tmap_mode("view")

dir.create("tmp")

unzip("D:/OneDrive - University of Leeds/Data/Special Areas of Conservation/NE_SpecialAreasOfConservationEngland_SHP_Full.zip",
      exdir = "tmp")

eng <- read_sf("tmp/data/Special_Areas_of_Conservation_England.shp")
unlink("tmp", recursive = TRUE)

unzip("D:/OneDrive - University of Leeds/Data/Special Areas of Conservation/SAC_SCOTLAND_ESRI.zip",
      exdir = "tmp")
scot <- read_sf("tmp/SAC_SCOTLAND.shp")
unlink("tmp", recursive = TRUE)

unzip("D:/OneDrive - University of Leeds/Data/Special Areas of Conservation/SpecialAreasOfConservationSAC.zip",
      exdir = "tmp")
wales <- read_sf("tmp/NRW_SACPolygon.shp")
unlink("tmp", recursive = TRUE)

eng <- eng$geometry
scot <- scot$geometry
wales <- wales$geometry

all <- c(eng, scot, wales)
all_val <- all[st_is_valid(all)]
all_inval <- all[!st_is_valid(all)]
all_inval <- st_buffer(all_inval, 0)
qtm(all_inval)

all <- st_transform(all_val, 4326)

st_write(all, "data/SAC.geojson", delete_dsn = TRUE)

zip::zip("data/SAC.geojson.zip", 
         files = "data/SAC.geojson", 
         include_directories = FALSE,
         mode = "cherry-pick")

pb_upload("data/SAC.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")

unlink("data/SAC.geojson")


