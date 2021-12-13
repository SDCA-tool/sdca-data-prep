library(zip)
library(piggyback)

file.copy("data/UK-dem-50m-4326-Int16.tif",
          "data/UKdem.tif")

zip::zip("data/UKdem.tif.zip", 
         files = "data/UKdem.tif",
         include_directories = FALSE,
         mode = "cherry-pick")

pb_upload("data/UKdem.tif.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")

unlink("data/UKdem.tif")
