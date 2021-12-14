library(sf)
library(zip)
library(piggyback)


zip::zip("data/wards.geojson.zip", 
         files = "../../creds2/CarbonCalculator/data/bounds/wards.geojson",
         include_directories = FALSE,
         mode = "cherry-pick")

parish <- read_sf("../../creds2/CarbonCalculator/data/bounds/parish.geojson")
st_write(parish,"data/parishes.geojson")
zip::zip("data/parishes.geojson.zip", 
         files = "data/parishes.geojson",
         include_directories = FALSE,
         mode = "cherry-pick")
unlink("data/parishes.geojson")

zip::zip("data/constituencies.geojson.zip", 
         files = "../../creds2/CarbonCalculator/data/bounds/constituencies.geojson",
         include_directories = FALSE,
         mode = "cherry-pick")


pb_upload("data/wards.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")

pb_upload("data/parishes.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")

pb_upload("data/constituencies.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")
