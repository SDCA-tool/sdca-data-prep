# Prep AONB
library(sf)
library(tmap)
library(dplyr)
library(tidyr)
library(piggyback)
tmap_mode("view")

sites = read.csv("D:/University of Leeds/TEAM - Shared Digital Carbon Architecture - Documents/General/WP3 – Embodied carbon of infrastructure/Production sites/production_sites.csv")
sites = st_as_sf(sites, coords = c("Longitude","Latitude"))

sites$Northing <- NULL
sites$Easting <- NULL

names(sites)[1] <- "id"
names(sites) <- gsub(".","_",names(sites), fixed = TRUE)

st_write(sites,"data/materialsites.geojson")

zip::zip("data/materialsites.geojson.zip", 
         files = "data/materialsites.geojson", 
         include_directories = FALSE,
         mode = "cherry-pick")

pb_upload("data/materialsites.geojson.zip", 
          repo = "SDCA-tool/sdca-data", 
          tag = "map_data")

unlink("data/materialsites.geojson", recursive = T)
