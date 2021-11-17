
zip::zip("data/carbon_full.geojson.zip", 
         files = "../../creds2/CarbonCalculator/data/carbon_full.geojson",
         include_directories = FALSE,
         mode = "cherry-pick")
zip::zip("data/carbon_general.geojson.zip", 
         files = "../../creds2/CarbonCalculator/data/carbon_general.geojson",
         include_directories = FALSE,
         mode = "cherry-pick")
zip::zip("data/carbon_super_general.geojson.zip", 
         files = "../../creds2/CarbonCalculator/data/carbon_super_general.geojson",
         include_directories = FALSE,
         mode = "cherry-pick")


pb_upload("data/carbon_full.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")

pb_upload("data/carbon_general.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")

pb_upload("data/carbon_super_general.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")
