library(sf)
library(zip)
library(piggyback)

dir.create("tmp")
#download.file("http://maps.communities.gov.uk/geoserver/dclg_inspire/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=dclg_inspire%3AEngland_Green_Belt_2019-20_WGS84&outputFormat=SHAPE-ZIP",
#              destfile = "tmp/greenbelt.zip")
unzip("D:/OneDrive - University of Leeds/Data/Greenbelt/England_Green_Belt_2019-20_WGS84.zip", exdir = "tmp")

gb <- read_sf("tmp/England_Green_Belt_2019-20_WGS84.shp")
gb <- gb$geometry

summary(st_is_valid(gb))
#gb <- st_make_valid(gb)

write_sf(gb,"data/greenbelt.geojson")
zip::zip("data/greenbelt.geojson.zip", 
    files = "data/greenbelt.geojson", 
    include_directories = FALSE,
    mode = "cherry-pick")
unlink("tmp", recursive = T)
unlink("data/greenbelt.geojson", recursive = T)

#pb_new_release("SDCA-tool/sdca-data", "map_data")

pb_upload("data/greenbelt.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")
