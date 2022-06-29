fls = list.files("R", full.names = TRUE)
for(fl in fls){source(fl)}

args = readLines("tests/testthat/portishead_example_r_input.geojson")
args = paste(args, collapse = "")
dat = parse_json(args, FALSE)
dat$path_dem <- "tests/testthat/dem.tif"
dat$path_landcover <-"tests/testthat/landcover.tif"
dat$path_bedrock <- "tests/testthat/bedrock.tif"
dat$path_superficial <- "tests/testthat/superficial.tif"


foo = geojsonsf::sf_geojson(dat$user_input)


dat = geojson_api("../sdca-data-prep/tests/HSR_grade_penzance.geojson")
dat$path_dem <- "../sdca-data-prep/rasters/dem.tif"
dat$path_landcover <-"../sdca-data-prep/rasters/landcover.tif"
dat$path_bedrock <- "../sdca-data-prep/rasters/bedrock.tif"
dat$path_superficial <- "../sdca-data-prep/rasters/superficial.tif"


#Loop over everything
library(sf)
library(sdca)
interventions = read.csv("../sdca-data/data_tables/interventions.csv")
interventions = interventions[,c("infrastructure_type",
                                 "mode_class",
                                 "mode",
                                 "intervention_class",
                                 "intervention_name",
                                 "intervention")]
template = st_read("../sdca-data-prep/tests/one_km_cornwall.geojson")
assets = read.csv("../sdca-data/data_tables/assets.csv") 
assets_parameters = read.csv("../sdca-data/data_tables/assets_parameters.csv")
components = read.csv("../sdca-data/data_tables/components.csv")
carbon_factors = read.csv("../sdca-data/data_tables/carbon_factors.csv")

res <- list()
for(i in 1:nrow(interventions)){
  int_sub <- interventions[i,]
  message(i," ",int_sub$intervention)
  int_sub$geometry <- template$geometry
  int_sub <- st_as_sf(int_sub)
  st_write(int_sub,"data/tmp_geom.geojson")
  dat = geojson_api("data/tmp_geom.geojson", showinput = TRUE)
  dat$path_dem <- "../sdca-data-prep/rasters/dem.tif"
  dat$path_landcover <-"../sdca-data-prep/rasters/landcover.tif"
  dat$path_bedrock <- "../sdca-data-prep/rasters/bedrock.tif"
  dat$path_superficial <- "../sdca-data-prep/rasters/superficial.tif"
  
  # Local Tables
  dat$assets <- assets[assets$intervention %in% int_sub$intervention,]
  dat$assets_parameters <- assets_parameters[assets_parameters$asset %in% dat$assets$asset,]
  dat$components <- components[components$asset %in% dat$assets$asset,]
  dat$carbon_factors <- carbon_factors[carbon_factors$cf_name %in% dat$components$cf_name,]
  
  
  dat = try(process_results(dat, local = TRUE), silent = TRUE)
  unlink("data/tmp_geom.geojson")
  if("try-error" %in% class(dat)){
    message("failed for: ", int_sub$intervention)
  } else {
    dat = jsonlite::fromJSON(dat)
    dat$name = int_sub$intervention
    res[[i]] <- dat
  }

}


res_itemised <- lapply(res, function(x){x$itemised_emissions})
res_itemised <- dplyr::bind_rows(res_itemised)


res_pas2080 <- lapply(res, function(x){x$pas2080})
nms <- lapply(res, function(x){x$name})
nms[sapply(nms, is.null)] <- NA
nms <- unlist(nms)

names(res_pas2080) <- nms
res_pas2080 <- dplyr::bind_rows(res_pas2080, .id = "intervention")
res_pas2080 <- res_pas2080[,c("intervention","pas2080_code","emissions")]
res_pas2080 <- res_pas2080[res_pas2080$pas2080_code %in% c("A1-3","A4","A5","B2","B4"),]

res_pas2080 <- tidyr::pivot_wider(res_pas2080, id_cols = "intervention", names_from = "pas2080_code", values_from = "emissions")
write.csv(res_pas2080,"../sdca-data-prep/tests/intervention_summary_1km.csv", row.names = FALSE)
