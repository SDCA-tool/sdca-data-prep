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
library(tidyr)

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
res_headline <- list()
res_mass <- list()
res_itemised <- list()

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
    capture.output( print(carbon_factors_sub, print.gap=3, width = 500), file = log_con, append = TRUE)
  }
  
  combined <- left_join(assets_sub, components_sub, by = "asset")
  combined <- left_join(combined, carbon_factors_sub, by = "cf_name")
  
  # Check for miss matched carbon factor input units
  cfu_check = combined[,c("cf_name","input_unit.x","input_unit.y")]
  cfu_check = cfu_check[cfu_check$cf_name != "no_granular_data",]
  cfu_check = cfu_check[cfu_check$input_unit.x != cfu_check$input_unit.y,]
  
  if(nrow(cfu_check) > 0){
    cat(paste0("\nERROR miss-matched units found for carbon factors: "), file = log_con, append = TRUE, sep = "\n")
    capture.output( print(cfu_check, print.gap=3, width  = 500), file = log_con, append = TRUE)
  }
  
  # check for non mass quantities
  mass_check = combined[,c("item","cf_name","quantity","input_unit.x")]
  mass_check = mass_check[mass_check$cf_name != "no_granular_data",]
  mass_check = mass_check[mass_check$input_unit.x != "kg",]
  
  if(nrow(cfu_check) > 0){
    cat(paste0("\nERROR non kilogramme quantities, don't know how to cacualte A4 emissions correctly: "), file = log_con, append = TRUE, sep = "\n")
    capture.output( print(mass_check, print.gap=3, width  = 500), file = log_con, append = TRUE)
  }
  
  # Do the carbon calculation for 1km of infrastructure
  
  # Steps 
  # 1 - Calculate quantity of materials required and emission (A1-3)
  # 2 - Summarise amount of material types required for transport (A4)
  # 3 - Calculate emissions from contribution process (A5)
  # 4 - Calculate emissions from replacements over lifetime (B4)
  
  if(interventions_sub$geometry == "line"){
    combined$quantity_total <- ifelse(combined$input_unit.x == "number", combined$quantity, combined$quantity * 1000)
  } else{
    combined$quantity_total <- combined$quantity
  }
  
  combined$emissions_total <- combined$quantity_total * combined$carbon_factor
  
  #A1-3 Emissions & A5 Emissions
  A1_3_emissions = sum(combined$emissions_total, combined$no_granular_data_A1_A3 * combined$quantity_total, na.rm = TRUE)
  A5_emissions = sum(combined$A5, na.rm = TRUE)
  
  #A4 Emissions
  combined$distance_km = ifelse(combined$cf_name == "no_granular_data",0,50)
  
  # Emission factors laden and unladen lorry
  # 0.00010749 tCO2e/t.km
  # 0.0000874 tCO2e/t.km
  combined$A4 = (combined$distance_km * combined$quantity_total / 1000 * 0.00010749 +
                   combined$distance_km * 0.0000874) * 1000
  
  A4_emissions = sum(combined$A4, combined$no_granular_data_A4 * combined$quantity_total, na.rm = TRUE)
  
  # Mass Summary
  mass_summary = combined[combined$cf_name != "no_granular_data",]
  mass_summary = mass_summary[,c("material_type","quantity_total")]
  
  know_materials <- c("Aluminium",
                      "Asphalt and Bitumen",
                      "Brick and Blockwork",
                      "Cement",
                      "Concrete",
                      "Glass",
                      "Gypsum",
                      "Inert",
                      "Insulation",
                      "Steel",
                      "Waste",
                      "Other")
  
  mass_summary$material_type[!mass_summary$material_type %in% know_materials] <- "Other"
  
  mass_summary = group_by(mass_summary, material_type) %>%
    summarise(mass_kg = sum(quantity_total, na.rm = TRUE))
  
  mass_summary$intervention = interventions_sub$intervention
  mass_summary$material_type = paste0("materials_kg_",gsub(" ","_",mass_summary$material_type))
  
  mass_summary <- pivot_wider(mass_summary, names_from = "material_type", values_from = "mass_kg")
  
  #B2 emissions
  B2_emissions = sum(combined$no_granular_data_B2 * combined$quantity_total, na.rm = TRUE)
  
  
  #B4 Assume same as construction * replacements
  combined$B4 = combined$A4 * combined$replacements_during_lifetime
  
  B4_emissions = sum(combined$B4, combined$no_granular_data_B4 * combined$quantity_total, na.rm = TRUE)
  
  # Make Detailed Emission Table
  combined = combined[,c("intervention","asset","item",
                         "quantity_total","input_unit.x",
                         "emissions_total","A4",
                         "A5","B4")]
  names(combined) = c("intervention","asset","item",
                      "quantity","quantity_units",
                      "A1_3","A4",
                      "A5","B4")
  combined = combined[order(combined$A1_3, decreasing = TRUE),]
  
  headline = data.frame(A1_3_emissions_tonnes = round(A1_3_emissions/1000,1),
                        A4_emissions_tonnes = round(A4_emissions/1000,1),
                        A5_emissions_tonnes = round(A5_emissions/1000,1),
                        B2_emissions_tonnes = round(B2_emissions/1000,1),
                        B4_emissions_tonnes = round(B4_emissions/1000,1),
                        stringsAsFactors = FALSE)
  
  cat(paste0("\n################"), file = log_con, append = TRUE, sep = "\n")
  cat(paste0("\nTotal emissions for 1km of infrastrucutre are ",format(round(rowSums(headline), 1), nsmall=1, big.mark=",")," (tonnes CO2e): "), file = log_con, append = TRUE, sep = "\n")
  cat(paste0("\nEmissions estimate for 1km of infrastrucutre are (tonnes CO2e): "), file = log_con, append = TRUE, sep = "\n")
  capture.output( print(headline, print.gap=3, width  = 500), file = log_con, append = TRUE)
  cat(paste0("\nItemised results are (kg CO2e): "), file = log_con, append = TRUE, sep = "\n")
  capture.output( print(combined, print.gap=3, width  = 500), file = log_con, append = TRUE)
  
  
  headline$intervention = interventions_sub$intervention
  res_headline[[i]] <- headline
  res_itemised[[i]] <- combined
  res_mass[[i]] = mass_summary
}


res_headline <- bind_rows(res_headline)
res_itemised <- bind_rows(res_itemised)
res_mass <- bind_rows(res_mass)
res_mass$mass_kg <- NULL

res_final <- left_join(interventions, res_headline, by = "intervention")
res_final <- left_join(res_final, res_mass, by = "intervention")
res_final$total_emissions_tonnes <- round(rowSums(res_final[,c("A1_3_emissions_tonnes",
                                                         "A4_emissions_tonnes",
                                                         "A5_emissions_tonnes",
                                                         "B2_emissions_tonnes",
                                                         "B4_emissions_tonnes")]))
res_final <- res_final[order(res_final$total_emissions_tonnes, decreasing = TRUE),]

write.csv(res_final, file.path(dir,"Data Tables/clean/linked/interventions_summary.csv"), row.names = FALSE, na = "", fileEncoding = "UTF-8")
write.csv(res_itemised, file.path(dir,"Data Tables/clean/linked/itemised_summary.csv"), row.names = FALSE, na = "", fileEncoding = "UTF-8")


cat(paste0("\n",Sys.time()," Processing complete "), file = log_con, append = TRUE, sep = "\n")
