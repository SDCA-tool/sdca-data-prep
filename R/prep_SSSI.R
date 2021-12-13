# Prep AONB
library(sf)
library(tmap)
library(dplyr)
library(tidyr)
library(piggyback)
tmap_mode("view")

dir.create("tmp")

unzip("D:/OneDrive - University of Leeds/Data/SSSI/NE_SitesOfSpecialScientificInterestEngland_SHP_Full.zip",
      exdir = "tmp")

eng <- read_sf("tmp/data/Sites_of_Special_Scientific_Interest_England.shp")
unlink("tmp", recursive = TRUE)

unzip("D:/OneDrive - University of Leeds/Data/SSSI/SSSI_SCOTLAND_ESRI.zip",
      exdir = "tmp")
scot <- read_sf("tmp/SSSI_SCOTLAND.shp")
unlink("tmp", recursive = TRUE)

wales <- read_sf("D:/OneDrive - University of Leeds/Data/SSSI/SitesOfSpecialScientificInterestSSSI_wales.json")

eng <- eng$geometry
scot <- scot$geometry
wales <- wales$geometry
wales <- st_cast(wales, "POLYGON")

all <- c(eng, scot, wales)
all <- st_transform(all, 4326)

st_write(all, "data/SSSI.geojson", delete_dsn = TRUE)

zip::zip("data/SSSI.geojson.zip", 
         files = "data/SSSI.geojson", 
         include_directories = FALSE,
         mode = "cherry-pick")

pb_upload("data/SSSI.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")

unlink("data/SSSI.geojson")


