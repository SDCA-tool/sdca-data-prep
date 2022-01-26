# prep_BGS
library(sf)

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

bedrock_lookup <- unique(bedrock$RCS_D)
write.csv(bedrock_lookup, "bedrock_lookup.csv", row.names = FALSE)

superficial_lookup <- unique(superficial$ROCK_D)
write.csv(superficial_lookup, "superficial_lookup.csv", row.names = FALSE)


plot(bedrock)
