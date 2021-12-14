# Prep AONB
library(sf)
library(tmap)
library(dplyr)
library(tidyr)
library(piggyback)
tmap_mode("view")

dir.create("tmp")

unzip("D:/OneDrive - University of Leeds/Data/National Nature Reserves/NE_NationalNatureReservesEngland_SHP_Full.zip",
      exdir = "tmp")

eng <- read_sf("tmp/data/National_Nature_Reserves_England.shp")
unlink("tmp", recursive = TRUE)

unzip("D:/OneDrive - University of Leeds/Data/National Nature Reserves/NNR_SCOTLAND_ESRI.zip",
      exdir = "tmp")
scot <- read_sf("tmp/NNR_SCOTLAND.shp")
unlink("tmp", recursive = TRUE)

unzip("D:/OneDrive - University of Leeds/Data/National Nature Reserves/NationalNatureReservesNNR.zip",
      exdir = "tmp")
wales <- read_sf("tmp/NRW_NNRPolygon.shp")
unlink("tmp", recursive = TRUE)

unzip("D:/OneDrive - University of Leeds/Data/National Nature Reserves/NE_LocalNatureReservesEngland_SHP_Full.zip",
      exdir = "tmp")
local <- read_sf("tmp/data/Local_Nature_Reserves_England.shp")
unlink("tmp", recursive = TRUE)

eng <- eng$geometry
scot <- scot$geometry
wales <- wales$geometry
local <- local$geometry

scot <- st_cast(scot,"POLYGON")
wales <- st_cast(wales,"POLYGON")

eng <- st_transform(eng, 4326)
scot <- st_transform(scot, 4326)
local <- st_transform(local, 4326)
wales <- st_transform(wales, 4326)

all <- c(eng, scot, wales, local)
all_val <- all[st_is_valid(all)]
all_inval <- all[!st_is_valid(all)]
#all_inval <- st_buffer(all_inval, 0)
#qtm(all_inval)

#all <- st_transform(all_val, 4326)

st_write(all, "data/naturereserves.geojson", delete_dsn = TRUE)

zip::zip("data/naturereserves.geojson.zip", 
         files = "data/naturereserves.geojson", 
         include_directories = FALSE,
         mode = "cherry-pick")

pb_upload("data/naturereserves.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")

unlink("data/naturereserves.geojson")


