library(sf)
library(zip)
library(piggyback)

dir.create("tmp")

unzip("D:/OneDrive - University of Leeds/Data/Historic England/Battlefields.zip",
      exdir = "tmp")
unzip("D:/OneDrive - University of Leeds/Data/Historic England/Building Preservation Notices.zip",
      exdir = "tmp")
unzip("D:/OneDrive - University of Leeds/Data/Historic England/Conservation Areas.zip",
      exdir = "tmp")
unzip("D:/OneDrive - University of Leeds/Data/Historic England/Certificates of Immunity.zip",
      exdir = "tmp")
unzip("D:/OneDrive - University of Leeds/Data/Historic England/Listed Buildings.zip",
      exdir = "tmp")
unzip("D:/OneDrive - University of Leeds/Data/Historic England/Parks and Gardens.zip",
      exdir = "tmp")
unzip("D:/OneDrive - University of Leeds/Data/Historic England/Scheduled Monuments.zip",
      exdir = "tmp")
unzip("D:/OneDrive - University of Leeds/Data/Historic England/World Heritage Sites.zip",
      exdir = "tmp")


battlefields <- read_sf("tmp/Battlefields_20Aug2021.shp")
bpn <- read_sf("tmp/BuildingPreservationNotices_25Oct2021.shp")
conservationarea <- read_sf("tmp/20210922_Conservation_Areas_INSPIRE_dataset.shp")
listed <- read_sf("tmp/ListedBuildings_08Nov2021.shp")
park <- read_sf("tmp/ParksAndGardens_20Aug2021.shp")
monument <- read_sf("tmp/ScheduledMonuments_08Nov2021.shp")
worldheritage <- read_sf("tmp/WorldHeritageSites_20Aug2021.shp")

battlefields <- battlefields$geometry
conservationarea <- conservationarea$geometry
park <- park["Grade"]
monument <- monument$geometry
worldheritage <- worldheritage$geometry
listed <- listed["Grade"]

battlefields <- st_transform(battlefields, 4326)
conservationarea <- st_transform(conservationarea, 4326)
park <- st_transform(park, 4326)
monument <- st_transform(monument, 4326)
worldheritage <- st_transform(worldheritage, 4326)
listed <- st_transform(listed, 4326)

battlefields <- st_make_valid(battlefields)
conservationarea <- st_make_valid(conservationarea)
park <- st_make_valid(park)
monument <- st_make_valid(monument)
worldheritage <- st_make_valid(worldheritage)


write_sf(battlefields, "data/battlefields.geojson")
write_sf(conservationarea, "data/conservationareas.geojson")
write_sf(park, "data/parksandgardens.geojson")
write_sf(monument, "data/scheduledmonuments.geojson")
write_sf(worldheritage, "data/worldheritagesites.geojson")
write_sf(listed, "data/listedbuildings.geojson")

zip::zip("data/battlefields.geojson.zip", 
         files = "data/battlefields.geojson", 
         include_directories = FALSE,
         mode = "cherry-pick")
zip::zip("data/conservationareas.geojson.zip", 
         files = "data/conservationareas.geojson", 
         include_directories = FALSE,
         mode = "cherry-pick")
zip::zip("data/parksandgardens.geojson.zip", 
         files = "data/parksandgardens.geojson", 
         include_directories = FALSE,
         mode = "cherry-pick")
zip::zip("data/scheduledmonuments.geojson.zip", 
         files = "data/scheduledmonuments.geojson", 
         include_directories = FALSE,
         mode = "cherry-pick")
zip::zip("data/worldheritagesites.geojson.zip", 
         files = "data/worldheritagesites.geojson", 
         include_directories = FALSE,
         mode = "cherry-pick")
zip::zip("data/listedbuildings.geojson.zip", 
         files = "data/listedbuildings.geojson", 
         include_directories = FALSE,
         mode = "cherry-pick")


unlink("tmp", recursive = T)
unlink("data/battlefields.geojson", recursive = T)
unlink("data/conservationareas.geojson", recursive = T)
unlink("data/parksandgardens.geojson", recursive = T)
unlink("data/scheduledmonuments.geojson", recursive = T)
unlink("data/worldheritagesites.geojson", recursive = T)
unlink("data/listedbuildings.geojson", recursive = T)

pb_upload("data/battlefields.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")
pb_upload("data/conservationareas.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")
pb_upload("data/parksandgardens.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")
pb_upload("data/scheduledmonuments.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")
pb_upload("data/worldheritagesites.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")
pb_upload("data/listedbuildings.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")
