library(sf)
dir.create("data/flooding")
download.file(url = "https://environment.data.gov.uk/UserDownloads/interactive/14d8e927c20149589d6e068351e924a373092/EA_FloodMapForPlanningRiversAndSeaFloodZone2_GeoJSON_Full.zip",
              destfile = "data/flooding/floodzone2.zip")
download.file(url = "https://environment.data.gov.uk/UserDownloads/interactive/9b8c69809ce044b1bf9388c7d5bc028259864/EA_FloodMapForPlanningRiversAndSeaFloodZone3_GeoJSON_Full.zip",
              destfile = "data/flooding/floodzone3.zip")

dir.create("tmp")
unzip("data/flooding/floodzone2.zip",
      exdir = "tmp")
flood2 <- st_read("tmp")