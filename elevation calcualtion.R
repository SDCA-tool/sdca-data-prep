library(raster)
library(sf)
library(stars)
library(tmap)
tmap_mode("view")

#dem <- read_stars("D:/OneDrive - University of Leeds/Data/opentripplanner/graphs/great-britain-NTEM/UK-dem-50m-4326.tif")
dem <- read_stars("D:/GitHub/SDCA-tool/sdca-data-prep/data/UK-dem-50m-4326-Int16.tif")



# line <- matrix(c(-1.7679598046120508, 53.3644133826852, -1.924790128647207,  53.64932645315051 ), 
#                ncol = 2, byrow = TRUE)
# line <- st_sfc(st_linestring(line), crs = 4326)

line <- read_sf("D:/OneDrive - University of Leeds/Documents/DFT Carbon Infrastructure/examples.gpkg")

extract_elevations <- function(line, dem){
  line_split <- st_segmentize(line, dfMaxLength = 50)
  line_split <- st_cast(line_split, "POINT")

  heights <- st_extract(dem, at = line_split)
  names(heights) <- c("elevation","geometry")
  heights$step <- seq(0, nrow(heights) - 1)
  gradient <- (heights$elevation[nrow(heights)] - heights$elevation[1])/(nrow(heights))
  heights$road <- heights$step * gradient + heights$elevation[1]
  heights$difference <- heights$elevation - heights$road
  coords <- st_coordinates(heights)
  heights <- st_drop_geometry(heights)
  heights <- cbind(heights, coords)
  return(heights)
}

bench::mark(extract_elevations(line, dem))

r1 <- extract_elevations(line, dem)



plot(heights$ele, type = "l", col = "black", ylim = c(-220,610))
lines(heights$smooth, col = "blue")
lines(heights$diff, col = "red")
