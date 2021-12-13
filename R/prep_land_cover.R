library(zip)
library(piggyback)

file.copy("data/land_use_4326.tif",
          "data/landcover.tif")

zip::zip("data/landcover.tif.zip", 
         files = "data/landcover.tif",
         include_directories = FALSE,
         mode = "cherry-pick")

pb_upload("data/landcover.tif.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")

unlink("data/landcover.tif")
