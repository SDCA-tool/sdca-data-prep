library(dplyr)

# Read in Sheets


path = "D:/University of Leeds/TEAM - Shared Digital Carbon Architecture - Documents/General/WP3 – Embodied carbon of infrastructure/Earthworks/Clean"

superficial_class <- readxl::read_excel(file.path(path,"Earthworks_Clean.xlsx"),
                                    sheet = "Superficial_Classification")
superficial_class = superficial_class[3:nrow(superficial_class),]
names(superficial_class) = c("rock_type",
                             "thickness",
                             "Description","type_0","type_1",
                              "type_2","type_3","type_6","type_7",
                              "type_8","type_9","cut_intensity")


bedrock_class <- readxl::read_excel(file.path(path,"Earthworks_Clean.xlsx"),
                                        sheet = "Bedrock_Classification")
bedrock_class = bedrock_class[3:nrow(bedrock_class),]
names(bedrock_class) = c("rock_type",
                             "Description","type_0","type_1",
                             "type_2","type_3","type_6","type_7",
                             "type_8","type_9","cut_intensity")

superficial_cut <- readxl::read_excel(file.path(path,"Earthworks_Clean.xlsx"),
                                    sheet = "Superficial_cut_angle")

bedrock_cut <- readxl::read_excel(file.path(path,"Earthworks_Clean.xlsx"),
                                    sheet = "Bedrock_cut_angle")

superficial_carbon <- readxl::read_excel(file.path(path,"Earthworks_Clean.xlsx"),
                                      sheet = "Superficial_CF")
superficial_carbon = superficial_carbon[2:nrow(superficial_carbon),]
names(superficial_carbon) = c("rock_type","cut","fill","processing")

bedrock_carbon <- readxl::read_excel(file.path(path,"Earthworks_Clean.xlsx"),
                                  sheet = "Bedrock_CF")
bedrock_carbon = bedrock_carbon[2:nrow(bedrock_carbon),]
names(bedrock_carbon) = c("rock_type","cut","fill","processing")

processing <- readxl::read_excel(file.path(path,"Earthworks_Clean.xlsx"),
                                 sheet = "Processing")

# Raster Looup tables

bedrock_lookup <- read.csv("bedrock_lookup.csv")
superficial_lookup <- read.csv("superficial_lookup.csv")

# Join togther

bedrock <- left_join(bedrock_class, bedrock_lookup, by = c("rock_type" = "type"))
bedrock <- left_join(bedrock, bedrock_cut, by = c("rock_type" = "Inuput Bedrock"))
bedrock <- left_join(bedrock, bedrock_carbon, by = c("rock_type" = "rock_type"))

superficial <- left_join(superficial_class, superficial_lookup, by = c("rock_type" = "type"))
superficial <- left_join(superficial, superficial_cut, by = c("rock_type" = "Input Superficial Deposit"))
superficial <- left_join(superficial, superficial_carbon, by = c("rock_type" = "rock_type"))

rm(bedrock_carbon, bedrock_class, bedrock_cut, bedrock_lookup)
rm(superficial_carbon, superficial_class, superficial_cut, superficial_lookup)

bedrock <- bedrock[,c("id","rock_type","type_0","type_1",
                      "type_2","type_3","type_6","type_7",
                      "type_8","type_9","cut_intensity",
                      "Slope angle (deg)","cut",
                      "fill","processing")]
names(bedrock) = c("id","rock_type","type_0","type_1",
                   "type_2","type_3","type_6","type_7",
                   "type_8","type_9","cut_intensity",
                   "angle","cut",
                   "fill","processing")
bedrock[3:10] <- lapply(bedrock[3:10], function(x){
  x <- as.numeric(x)
  x[is.na(x)] <- 0
  x
})

superficial <- superficial[,c("id","rock_type","thickness","type_0","type_1",
                      "type_2","type_3","type_6","type_7",
                      "type_8","type_9","cut_intensity",
                      "Slope angle (deg)","cut",
                      "fill","processing")]
names(superficial) = c("id","rock_type","thickness","type_0","type_1",
                   "type_2","type_3","type_6","type_7",
                   "type_8","type_9","cut_intensity",
                   "angle","cut",
                   "fill","processing")
superficial[4:11] <- lapply(superficial[3:10], function(x){
  x <- as.numeric(x)
  x[is.na(x)] <- 0
  x
})

write.csv(bedrock, "../sdca-data/package_files/bedrock.csv", row.names = FALSE, na = "", fileEncoding = "UTF-8")
write.csv(superficial, "../sdca-data/package_files/superficial.csv", row.names = FALSE, na = "", fileEncoding = "UTF-8")

