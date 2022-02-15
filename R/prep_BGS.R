# prep_BGS
library(sf)
library(zip)
library(piggyback)
library(dplyr)
library(tmap)
library(stars)
tmap_mode("view")


dir.create("tmp")
unzip("D:/OneDrive - University of Leeds/Data/British Geological Survey/digmap625_bedrock_arc.zip",
      exdir = "tmp")
bedrock <- st_read("tmp/625k_V5_BEDROCK_Geology_Polygons.shp")
unlink("tmp", recursive = TRUE)

dir.create("tmp")
unzip("D:/OneDrive - University of Leeds/Data/British Geological Survey/digmap625_superficial_arc.zip",
      exdir = "tmp")
superficial <- st_read("tmp/UK_625k_SUPERFICIAL_Geology_Polygons.shp")
unlink("tmp", recursive = TRUE)

bedrock <- bedrock[,"RCS_D"]
superficial <- superficial[,"ROCK_D"]

# bedrock_lookup <- unique(bedrock$RCS_D)
# write.csv(bedrock_lookup, "bedrock_lookup.csv", row.names = FALSE)
# 
# superficial_lookup <- unique(superficial$ROCK_D)
# write.csv(superficial_lookup, "superficial_lookup.csv", row.names = FALSE)

names(bedrock) = c("type","geometry")
names(superficial) = c("type","geometry")

bedrock <- st_transform(bedrock, 4326)
superficial <- st_transform(superficial, 4326)

bedrock_id <- unique(st_drop_geometry(bedrock))
bedrock_id$id = 1:nrow(bedrock_id)
write.csv(bedrock_id, "bedrock_lookup.csv", row.names = FALSE)

bedrock = left_join(bedrock, bedrock_id, by = "type")

superficial_id <- unique(st_drop_geometry(superficial))
superficial_id$id = 1:nrow(superficial_id)
write.csv(superficial_id, "superficial_lookup.csv", row.names = FALSE)

superficial = left_join(superficial, superficial_id, by = "type")
# Get DEM and rasterise
dir.create("tmp")
download.file(url = "https://github.com/SDCA-tool/sdca-data/releases/download/map_data/UKdem.tif.zip",
              destfile = "tmp/UKdem.tif.zip", mode = "wb")
unzip("tmp/UKdem.tif.zip",
      exdir = "tmp")
dem <- read_stars("tmp/UKdem.tif")
dem <- st_as_stars(dem)
dem[[1]][] <- 0


bedrock_raster = st_rasterize(bedrock["id"], dem)
write_stars(bedrock_raster, "data/bedrock.tif")

superficial_raster = st_rasterize(superficial["id"], dem)
write_stars(superficial_raster, "data/superficial.tif")


unlink("tmp", recursive = TRUE)

zip::zip("data/bedrock.tif.zip", 
         files = "data/bedrock.tif", 
         include_directories = FALSE,
         mode = "cherry-pick")
unlink("tmp", recursive = T)
unlink("data/bedrock.tif", recursive = T)

pb_upload("data/bedrock.tif.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")


zip::zip("data/superficial.tif.zip", 
         files = "data/superficial.tif", 
         include_directories = FALSE,
         mode = "cherry-pick")
unlink("tmp", recursive = T)
unlink("data/superficial.tif", recursive = T)

pb_upload("data/superficial.tif.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")



# 
# #Add in classification data
# 
# bedrock_slope <- readxl::read_excel("E:/Users/earmmor/University of Leeds/TEAM - Shared Digital Carbon Architecture - General/WP3 – Embodied carbon of infrastructure/Earthworks/Earthworks_Volumes.xlsx",
#                                     sheet = "Cut_angle_bedrock")
# 
# superficial_slope <- readxl::read_excel("E:/Users/earmmor/University of Leeds/TEAM - Shared Digital Carbon Architecture - General/WP3 – Embodied carbon of infrastructure/Earthworks/Earthworks_Volumes.xlsx",
#                                     sheet = "Cut_angle_superficial")
# 
# 
# bedrock <- left_join(bedrock, bedrock_slope, by = c("type" = "Input Bedrock"))
# superficial <- left_join(superficial, superficial_slope, by = c("type" = "Input Superficial Deposit"))
# 
# # Fill codes
# 
# bedrock_class <- readxl::read_excel("E:/Users/earmmor/University of Leeds/TEAM - Shared Digital Carbon Architecture - General/WP3 – Embodied carbon of infrastructure/Earthworks/Earthworks_Carbon_Factors_V1.xlsx",
#                                     sheet = "Bedrock_Classification")
# superficial_class <- readxl::read_excel("E:/Users/earmmor/University of Leeds/TEAM - Shared Digital Carbon Architecture - General/WP3 – Embodied carbon of infrastructure/Earthworks/Earthworks_Carbon_Factors_V1.xlsx",
#                                    sheet = "Superficial_Classification")
# names(bedrock_class) = c("Input Bedrock","Description","type_0","type_1",
#                          "type_2","type_3","type_6","type_7",
#                          "type_8","type_9","Cut Intensity")
# names(superficial_class) = c("Input Superficial Deposit","thickness","Description","type_0","type_1",
#                          "type_2","type_3","type_6","type_7",
#                          "type_8","type_9","Cut Intensity")
# bedrock_class = bedrock_class[3:nrow(bedrock_class),]
# superficial_class = superficial_class[3:nrow(superficial_class),]
# 
# bedrock_class[paste0("type_",c(0:3,6:9))] <- lapply(bedrock_class[paste0("type_",c(0:3,6:9))], function(x){
#   x = as.numeric(x)
#   x[is.na(x)] = 0
#   x
# })
# 
# superficial_class[paste0("type_",c(0:3,6:9))] <- lapply(superficial_class[paste0("type_",c(0:3,6:9))], function(x){
#   x = as.numeric(x)
#   x[is.na(x)] = 0
#   x
# })
# 
# bedrock <- left_join(bedrock, bedrock_class, by = c("type" = "Input Bedrock"))
# superficial <- left_join(superficial, superficial_class, by = c("type" = "Input Superficial Deposit"))
# 
# bedrock_loadfactor <- readxl::read_excel("E:/Users/earmmor/University of Leeds/TEAM - Shared Digital Carbon Architecture - General/WP3 – Embodied carbon of infrastructure/Earthworks/Earthworks_Carbon_Factors_V1.xlsx",
#                                     sheet = "bedrock_LF", skip = 1)
# superficial_loadfactor <- readxl::read_excel("E:/Users/earmmor/University of Leeds/TEAM - Shared Digital Carbon Architecture - General/WP3 – Embodied carbon of infrastructure/Earthworks/Earthworks_Carbon_Factors_V1.xlsx",
#                                         sheet = "superficial_LF", skip = 1)
# 
# 
# bedrock <- left_join(bedrock, bedrock_loadfactor, by = c("type" = "Input Bedrock"))
# superficial <- left_join(superficial, superficial_loadfactor, by = c("type" = "Input Superficial Deposit"))
# 
# bedrock_emissions <- readxl::read_excel("E:/Users/earmmor/University of Leeds/TEAM - Shared Digital Carbon Architecture - General/WP3 – Embodied carbon of infrastructure/Earthworks/Earthworks_Carbon_Factors_V1.xlsx",
#                                         sheet = "bedrock_CE", skip = 1)
# superficial_emissions <- readxl::read_excel("E:/Users/earmmor/University of Leeds/TEAM - Shared Digital Carbon Architecture - General/WP3 – Embodied carbon of infrastructure/Earthworks/Earthworks_Carbon_Factors_V1.xlsx",
#                                             sheet = "superficial_CE", skip = 1)
# 
# bedrock <- left_join(bedrock, bedrock_emissions, by = c("type" = "Input Bedrock"))
# superficial <- left_join(superficial, superficial_emissions, by = c("type" = "Input Superficial Deposit"))
# 
# bedrock <- st_make_valid(bedrock)
# bedrock$area <- as.numeric(st_area(bedrock))
# summary(bedrock$area)
# qtm(bedrock[bedrock$area == max(bedrock$area),])
# 
# # Split polyons into a grid
# ukgrid <- st_make_grid(bedrock, n = c(300,100))
# qtm(ukgrid, fill = NULL)
# ukgrid <- st_cast(ukgrid, "LINESTRING")
# 
# bedrock_big = bedrock[bedrock$area > 3e8,]
# bedrock_small = bedrock[bedrock$area <= 3e8,]
# bedrock_big = lwgeom::st_split(bedrock_big, ukgrid)
# bedrock_big = st_collection_extract(bedrock_big, "POLYGON")
# bedrock_big$id <- as.character(sample(1:nrow(bedrock_big)))
# qtm(bedrock_big, fill = "id")
# 
# foo$area2 <- as.numeric(st_area(foo))
# summary(bedrock$area)

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
plot(superficial)
