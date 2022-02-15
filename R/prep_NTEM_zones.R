# prep_BGS
library(sf)
library(zip)
library(piggyback)
library(dplyr)


ntem <- read_sf("../../ITSLeeds/NTEM2OD/data/NTEM_bounds.gpkg")
ntem <- st_transform(ntem, 4326)

flow <- readRDS("../../ITSLeeds/NTEM2OD/data/NTEM/NTEM_flows_mode.Rds")
flow_origins = flow %>% 
  group_by(from) %>%
  summarise(cycle = sum(cycle, na.rm = TRUE),
            drive = sum(drive, na.rm = TRUE),
            passenger = sum(passenger, na.rm = TRUE),
            walk = sum(walk, na.rm = TRUE),
            rail = sum(rail, na.rm = TRUE),
            bus = sum(bus, na.rm = TRUE))

ntem = left_join(ntem, flow_origins, by = c("Zone_Code" = "from"))


st_write(ntem, "data/ntem.geojson", delete_dsn = TRUE)

zip::zip("data/ntem.geojson.zip", 
         files = "data/ntem.geojson", 
         include_directories = FALSE,
         mode = "cherry-pick")

pb_upload("data/ntem.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")

unlink("data/ntem.geojson")
