library(raster)
library(sf)
library(stars)

dem <- read_stars("D:/OneDrive - University of Leeds/Data/opentripplanner/graphs/great-britain-NTEM/UK-dem-50m-4326.tif")

line <- matrix(c(-1.7679598046120508, 53.3644133826852, -1.924790128647207,  53.64932645315051 ), 
               ncol = 2, byrow = TRUE)
line <- st_sfc(st_linestring(line), crs = 4326)


extract_elevations <- function(line, dem){
  line_split <- st_segmentize(line, dfMaxLength = 50)
  line_split <- st_cast(line_split, "POINT")
  
  heights <- st_extract(dem, at = line_split)
  names(heights) <- c("ele","geometry")
  heights$step <- seq(0, nrow(heights) - 1)
  gradient <- (heights$ele[nrow(heights)] - heights$ele[1])/(nrow(heights))
  heights$smooth <- heights$step * gradient + heights$ele[1]
  heights$diff <- heights$ele - heights$smooth
  return(heights$diff)
}

bench::mark(extract_elevations(line, dem))

plot(heights$ele, type = "l", col = "black", ylim = c(-220,610))
lines(heights$smooth, col = "blue")
lines(heights$diff, col = "red")
