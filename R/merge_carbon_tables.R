dir1 = "E:/Users/earmmor/University of Leeds/TEAM - Shared Digital Carbon Architecture - General"
dir2 = "D:/University of Leeds/TEAM - Shared Digital Carbon Architecture - Documents/General"
dir3 = "C:/Users/malco/University of Leeds/TEAM - Shared Digital Carbon Architecture - General"

if(dir.exists(dir1)){
  dir <- dir1
} else if(dir.exists(dir2)){
  dir <- dir2
} else if(dir.exists(dir3)){
  dir <- dir3
} else{
  stop("unknown dir")
}

library(readr)
library(readxl)
library(dplyr)

# Create a log file
log_con <- file.path(dir,"Data Tables/clean/data_merge_log.txt")
if(file.exists(log_con)){
  unlink(log_con)
}

cat(paste0("This file logs the merging of the data tables"), file = log_con)
cat(paste0("\nto make a summary table for each intervention"), file = log_con, append = TRUE, sep = "\n")
cat(paste0("It looks for possible errors and missing data."), file = log_con, append = TRUE, sep = "\n")


cat(paste0(Sys.time()," Starting data merge"), file = log_con, append = TRUE, sep = "\n")

interventions <- read.csv("../sdca-data/data_tables/interventions.csv")
assets <- read.csv("../sdca-data/data_tables/assets.csv")
components <- read.csv("../sdca-data/data_tables/components.csv")
carbon_factors <- read.csv("../sdca-data/data_tables/carbon_factors.csv")
assets_parameters <- read.csv("../sdca-data/data_tables/assets_parameters.csv")

assets <- assets[,c("intervention","asset","asset_unit","unit_type")]
components <- components[,c("asset","item","quantity","cf_name","input_unit","A5",
                            "replacements_during_lifetime","no_granular_data_A1_A3",
                            "no_granular_data_A4","no_granular_data_B2",
                            "no_granular_data_B4")]
carbon_factors <- carbon_factors[,c("cf_name","material_type","input_unit","carbon_factor","carbon_factor_units")]
res <- list()

for(i in seq(1, nrow(interventions))){
  interventions_sub <- interventions[i,]
  
  cat(paste0("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"), file = log_con, append = TRUE, sep = "\n")
  cat(paste0(Sys.time()," ",i,", building for ",interventions_sub$intervention), file = log_con, append = TRUE, sep = "\n")
  
  # Subset needed data
  assets_sub <- assets[assets$intervention == interventions_sub$intervention,]
  
  if(nrow(assets_sub) == 0){
    cat(paste0("\nNo assets found"), file = log_con, append = TRUE, sep = "\n")
    next
  } else {
    cat(paste0("\nThe following assets were found: "), file = log_con, append = TRUE, sep = "\n")
    capture.output( print(assets_sub, print.gap=3, width  = 500), file = log_con, append = TRUE)
  }
  
  
  
  components_sub <- components[components$asset %in% assets_sub$asset,]
  
  if(nrow(components_sub) == 0){
    cat(paste0("\nNo components found"), file = log_con, append = TRUE, sep = "\n")
    next
  } else {
    cat(paste0("\nThe following components were found: "), file = log_con, append = TRUE, sep = "\n")
    capture.output( print(components_sub, print.gap=3, width  = 500), file = log_con, append = TRUE)
  }
  
  
  carbon_factors_sub <- carbon_factors[carbon_factors$cf_name %in% components_sub$cf_name,]
  
  if(nrow(carbon_factors_sub) == 0){
    cat(paste0("\nNo carbon factors found"), file = log_con, append = TRUE, sep = "\n")
  } else {
    cat(paste0("\nfollowing carbon factors were found: "), file = log_con, append = TRUE, sep = "\n")
    capture.output( print(carbon_factors_sub, print.gap=3, width  = 500), file = log_con, append = TRUE)
  }
  
  combined <- left_join(assets_sub, components_sub, by = "asset")
  combined <- left_join(combined, carbon_factors_sub, by = "cf_name")
  
}






cat(paste0("\n",Sys.time()," Processing complete "), file = log_con, append = TRUE, sep = "\n")
