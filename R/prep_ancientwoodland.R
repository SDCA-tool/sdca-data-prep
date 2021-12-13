# Prep AONB
library(sf)
library(tmap)
library(dplyr)
library(tidyr)
library(piggyback)
tmap_mode("view")


eng <- read_sf("D:/OneDrive - University of Leeds/Data/Ancient Woodland/Ancient_Woodland_(England).geojson")
wales <- read_sf("D:/OneDrive - University of Leeds/Data/Ancient Woodland/AncientWoodlandInventory2021-WFS-wales.json")

eng <- eng$geometry
wales <- wales$geometry
wales <- st_transform(wales, 4326)

all <- c(eng, wales)
all_val <- all[st_is_valid(all)]
all_inval <- all[!st_is_valid(all)]
all_inval <- st_make_valid(all_inval)
qtm(all_inval)

all <- c(all_val, all_inval)

st_write(all, "data/ancientwoodland.geojson", delete_dsn = TRUE)

zip::zip("data/ancientwoodland.geojson.zip", 
         files = "data/ancientwoodland.geojson", 
         include_directories = FALSE,
         mode = "cherry-pick")

pb_upload("data/ancientwoodland.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")

unlink("data/ancientwoodland.geojson")


