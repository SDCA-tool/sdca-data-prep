# Prep AONB
library(sf)
library(tmap)
library(dplyr)
library(tidyr)
library(piggyback)
tmap_mode("view")




eng <- read_sf("D:/OneDrive - University of Leeds/Data/RAMSAR/Ramsar__England_.geojson")
dir.create("tmp")
unzip("D:/OneDrive - University of Leeds/Data/RAMSAR/RAMSAR_SCOTLAND_ESRI.zip",
      exdir = "tmp")
scot <- read_sf("tmp/RAMSAR_SCOTLAND.shp")
unlink("tmp", recursive = TRUE)

unzip("D:/OneDrive - University of Leeds/Data/RAMSAR/Ramsar_wales.zip",
      exdir = "tmp")
wales <- read_sf("tmp/NRW_RAMSARPolygon.shp")
unlink("tmp", recursive = TRUE)

eng <- eng$geometry
scot <- scot$geometry
wales <- wales$geometry

eng <- st_cast(eng, "POLYGON")
wales <- st_cast(wales, "POLYGON")

eng <- st_transform(eng, 4326)
scot <- st_transform(scot, 4326)
wales <- st_transform(wales, 4326)

all <- c(eng, scot, wales)
all_val <- all[st_is_valid(all)]
all_inval <- all[!st_is_valid(all)]
#all_inval <- st_buffer(all_inval, 0)
#qtm(all_inval)

#all <- st_transform(all_val, 4326)
all <- all_val

st_write(all, "data/RAMSAR.geojson", delete_dsn = TRUE)

zip::zip("data/RAMSAR.geojson.zip", 
         files = "data/RAMSAR.geojson", 
         include_directories = FALSE,
         mode = "cherry-pick")

pb_upload("data/RAMSAR.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")

unlink("data/RAMSAR.geojson")


