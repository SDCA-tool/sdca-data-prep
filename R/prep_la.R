library(sf)
library(tmap)
library(dplyr)
library(tidyr)
tmap_mode("view")

dir.create("tmp")
unzip("../../saferactive/saferactive/data/bdline_gpkg_gb.zip",
      exdir = "tmp")

la_lower <- st_read("tmp/data/bdline_gb.gpkg", layer = "district_borough_unitary")
unlink("tmp", recursive = TRUE)


la_lower <- la_lower$geom

la_lower <- st_transform(la_lower, 4326)
st_write(la_lower, "data/la.geojson", delete_dsn = TRUE)


zip::zip("data/la.geojson.zip", 
         files = "data/la.geojson", 
         include_directories = FALSE,
         mode = "cherry-pick")

pb_upload("data/la.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")

unlink("data/la.geojson")
