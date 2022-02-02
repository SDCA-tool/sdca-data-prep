# prep_BGS
library(sf)
library(zip)
library(piggyback)


dir.create("tmp")
unzip("E:/Users/earmmor/OneDrive - University of Leeds/Data/British Geological Survey/digmap625_bedrock_arc.zip",
      exdir = "tmp")
bedrock <- st_read("tmp/625k_V5_BEDROCK_Geology_Polygons.shp")
unlink("tmp", recursive = TRUE)

dir.create("tmp")
unzip("E:/Users/earmmor/OneDrive - University of Leeds/Data/British Geological Survey/digmap625_superficial_arc.zip",
      exdir = "tmp")
superficial <- st_read("tmp/UK_625k_SUPERFICIAL_Geology_Polygons.shp")
unlink("tmp", recursive = TRUE)

bedrock <- bedrock[,"RCS_D"]
superficial <- superficial[,"RCS_D"]

bedrock_lookup <- unique(bedrock$RCS_D)
write.csv(bedrock_lookup, "bedrock_lookup.csv", row.names = FALSE)

superficial_lookup <- unique(superficial$ROCK_D)
write.csv(superficial_lookup, "superficial_lookup.csv", row.names = FALSE)

names(bedrock) = c("type","geometry")
names(superficial) = c("type","geometry")

bedrock <- st_transform(bedrock, 4326)
superficial <- st_transform(superficial, 4326)

write_sf(bedrock,"data/bedrock.geojson")
zip::zip("data/bedrock.geojson.zip", 
         files = "data/bedrock.geojson", 
         include_directories = FALSE,
         mode = "cherry-pick")
unlink("tmp", recursive = T)
unlink("data/bedrock.geojson", recursive = T)

pb_upload("data/bedrock.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")

write_sf(superficial,"data/superficial.geojson")
zip::zip("data/superficial.geojson.zip", 
         files = "data/superficial.geojson", 
         include_directories = FALSE,
         mode = "cherry-pick")
unlink("tmp", recursive = T)
unlink("data/superficial.geojson", recursive = T)

pb_upload("data/superficial.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")


plot(bedrock)