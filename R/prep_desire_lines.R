library(sf)
library(zip)
library(piggyback)

dl <- read_sf("../../ITSleeds/NTEM2OD/data/NTEM/NTEM_desire_lines.geojson")
#2090770 to 2083070
dl <- dl[dl$from != dl$to,]

st_precision(dl) <- 10000

write_sf(dl,"data/desire_lines.geojson")

zip::zip("data/desire_lines.geojson.zip", 
         files = "data/desire_lines.geojson",
         include_directories = FALSE,
         mode = "cherry-pick")

pb_upload("data/desire_lines.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")

unlink("data/desire_lines.geojson")
