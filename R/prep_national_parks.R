library(sf)
library(zip)
library(piggyback)

dir.create("tmp")

unzip("D:/OneDrive - University of Leeds/Data/National Parks/NationalParks Wales.zip",
      exdir = "tmp")
unzip("D:/OneDrive - University of Leeds/Data/National Parks/NE_NationalParksEngland_FGDB_Full.zip",
      exdir = "tmp")
unzip("D:/OneDrive - University of Leeds/Data/National Parks/SG_CairngormsNationalPark_2010.zip",
      exdir = "tmp")
unzip("D:/OneDrive - University of Leeds/Data/National Parks/SG_LochLomondTrossachsNationalPark_2002.zip",
      exdir = "tmp")

eng <- read_sf("tmp/data.gdb")
wales <- read_sf("tmp/NRW_NATIONAL_PARKPolygon.shp")
scot1 <- read_sf("tmp/SG_CairngormsNationalPark_2010.shp")
scot2 <- read_sf("tmp/SG_LochLomondTrossachsNationalPark_2002.shp")

eng <- st_geometry(eng)
wales <- st_geometry(wales)
scot1 <- st_geometry(scot1)
scot2 <- st_geometry(scot2)

eng <- st_transform(eng, 4326)
wales <- st_transform(wales, 4326)
scot1 <- st_transform(scot1, 4326)
scot2 <- st_transform(scot2, 4326)

all <- c(eng, wales)
scot <- st_cast(st_sfc(c(scot1, scot2)), "MULTIPOLYGON")

all <- c(all, scot)

all2 <- st_make_valid(all)

write_sf(all2, "data/nationalparks.geojson")

zip::zip("data/nationalparks.geojson.zip", 
         files = "data/nationalparks.geojson", 
         include_directories = FALSE,
         mode = "cherry-pick")
unlink("tmp", recursive = T)
unlink("data/nationalparks.geojson", recursive = T)


pb_upload("data/nationalparks.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")

