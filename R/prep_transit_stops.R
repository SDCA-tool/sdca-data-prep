library(sf)
library(zip)
library(piggyback)

stops <- read_sf("../../creds2/CarbonCalculator/data/transit_stop_frequency_v3.geojson")
write_sf(stops,"data/publictransport.geojson")

zip::zip("data/publictransport.geojson.zip", 
         files = "data/publictransport.geojson",
         include_directories = FALSE,
         mode = "cherry-pick")

pb_upload("data/publictransport.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")

unlink("data/publictransport.geojson")
