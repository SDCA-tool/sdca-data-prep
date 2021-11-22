library(sf)
library(zip)
library(piggyback)

file.copy("../../creds2/CarbonCalculator/data/transit_stop_frequency_v3.geojson",
          "data/transitstops.geojson")

zip::zip("data/transitstops.geojson.zip", 
         files = "data/transitstops.geojson",
         include_directories = FALSE,
         mode = "cherry-pick")

pb_upload("data/transitstops.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")

unlink("data/transitstops.geojson")
