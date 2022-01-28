dir = "E:/Users/earmmor/University of Leeds/TEAM - Shared Digital Carbon Architecture - General"
dir = "D:/University of Leeds/TEAM - Shared Digital Carbon Architecture - Documents/General"

library(readr)
library(readxl)
library(dplyr)

# Create a log file
log_con <- "data_import_log.txt"
if(file.exists(log_con)){
  unlink(log_con)
}
cat(paste0(Sys.time()," Starting data import"), file = log_con)


# Intervention Types
path = file.path(dir,"Data Tables/Examples for Malcolm 250122/interventions_tabulated.xlsx")
cat(paste0("\n",Sys.time()," reading ",path), file = log_con, append = TRUE, sep = "\n")
interventions = read_excel(path)
cat(paste0("\n",Sys.time()," rows =  ",nrow(interventions)," cols = ",ncol(interventions)), file = log_con, append = TRUE, sep = "\n")
interventions$infrastructure_type <- "transport"

interventions = interventions[,c("infrastructure_type","mode_class","mode",
                                 "intervention_class","intervention",
                                  "intervention_description","geometry",
                                 "include","interface",
                                  "user_entered_parameters","elevation_unit",
                                 "elevation_default")]

interventions$include <- ifelse(interventions$include == "y", "TRUE", "FALSE")



#intervention assets

path = file.path(dir,"Data Tables/Examples for Malcolm 250122/High_speed_rail_intervention_assets_list.xlsx")
cat(paste0("\n",Sys.time()," reading ",path), file = log_con, append = TRUE, sep = "\n")
sheets = excel_sheets(path)
cat(paste0("\n Sheet found: ",sheets), file = log_con, append = TRUE)

#Check for matches
log_message = paste0("\n",Sys.time()," The following  tabs in intervention_assets_list are not in interventions_tabulated: \n",
                     paste(sheets[!sheets %in% interventions$intervention], collapse = ", "))
message(log_message)
cat(log_message, file = log_con, append = TRUE)
log_message = paste0("\n",Sys.time()," The following  interventions in interventions_tabulated are not tabs in intervention_assets_list : \n",
        paste(interventions$intervention[!interventions$intervention %in% sheets], collapse = ", "))

message(log_message)
cat(log_message, file = log_con, append = TRUE)


intervention_assets <- list()
for(i in 1:length(sheets)){
  sub = read_excel(path, sheet = sheets[i], col_types = "text")
  sub = sub[!is.na(sub$include),]
  sub$intervention = sheets[i]
  sub$diameter_default = round(as.numeric(sub$diameter_default),5)
  sub$include = ifelse(sub$include == "y", "TRUE", "FALSE")
  intervention_assets[[i]] = sub
}
cat(paste0("\n",Sys.time()," Imported all sheets"), file = log_con, append = TRUE)

intervention_assets = bind_rows(intervention_assets)
intervention_assets$Notes = NULL

cat(paste0("\n",Sys.time()," Merged all sheets into single table"), file = log_con, append = TRUE)
cat(paste0("\n Column names are "), file = log_con, append = TRUE)
cat(paste0("\n",names(intervention_assets)), file = log_con, append = TRUE)

intervention_assets = intervention_assets[,c("intervention", "asset","include","asset_class",
                                             "asset_unit","unit_type","asset_parameters",
                                             "user_entered_parameters","tool_extracted_parameters",
                                             "tool_calculated_parameters", "area_unit",
                                             "area_default","diameter_unit","diameter_default",
                                             "length_unit","length_default",
                                             "number_unit","number_default","span_unit",
                                             "span_default","volume_unit",
                                             "volume_default","width_unit","width_default")]

cat(paste0("\n",Sys.time()," Creating parameters table"), file = log_con, append = TRUE)

intervention_assets_parameters = intervention_assets[,c("asset",
                                                        "area_unit","area_default",
                                                        "diameter_unit","diameter_default",
                                                       "length_unit","length_default",
                                                       "number_unit","number_default",
                                                       "span_unit","span_default",
                                                       "volume_unit","volume_default",
                                                       "width_unit","width_default")]#
                                                   
intervention_assets_parameters[] <- lapply(intervention_assets_parameters, as.character)

foo = tidyr::pivot_longer(intervention_assets_parameters[,c("asset",
                                                            "area_unit",
                                                            "diameter_unit",
                                                            "length_unit",
                                                            "number_unit",
                                                            "span_unit",
                                                            "volume_unit",
                                                            "width_unit")],
  cols = c(tidyr::ends_with("_unit"),),
  names_to = c("parameter"),
  values_to = "unit"
)
foo$parameter <- gsub("_unit","",foo$parameter)
foo2 = tidyr::pivot_longer(intervention_assets_parameters[,c("asset",
                                                            "area_default",
                                                            "diameter_default",
                                                            "length_default",
                                                            "number_default",
                                                            "span_default",
                                                            "volume_default",
                                                            "width_default")],
                          cols = c(tidyr::ends_with("_default"),),
                          names_to = c("parameter"),
                          values_to = "default"
)
foo2$parameter <- gsub("_default","",foo2$parameter)
foo$default = foo2$default
intervention_assets_parameters <- foo[!is.na(foo$unit),]
intervention_assets_parameters$default <- as.numeric(intervention_assets_parameters$default)


intervention_assets <- intervention_assets[,c("intervention", "asset","include","asset_class",
                                              "asset_unit","unit_type","asset_parameters",
                                              "user_entered_parameters","tool_extracted_parameters",
                                              "tool_calculated_parameters")]



# Asset Components
path = file.path(dir,"Data Tables/Examples for Malcolm 250122/example_asset.xlsx")
cat(paste0("\n",Sys.time()," reading ",path), file = log_con, append = TRUE, sep = "\n")

sheets = excel_sheets(path)
cat(paste0("\n Sheet found: ",sheets), file = log_con, append = TRUE)

#TODO: Fix limit to approved sheet only
cat(paste0("\n",Sys.time()," Manually limted to following sheets "), file = log_con, append = TRUE)
sheets = c("Viaduct","Embankment","Overbridge")
cat(paste0("\n",sheets), file = log_con, append = TRUE)

asset_components <- list()
for(i in 1:length(sheets)){
  sub = read_excel(path, sheet = sheets[i], col_types = "text")
  sub = sub[!is.na(sub$item),]
  sub$intervention_asset = sheets[i]
  sub$A5 = round(as.numeric(sub$A5),5)
  sub$quantity = round(as.numeric(sub$quantity),5)
  asset_components[[i]] = sub
}
cat(paste0("\n",Sys.time()," Imported all sheets"), file = log_con, append = TRUE)

asset_components = bind_rows(asset_components)
asset_components = asset_components[,c("intervention_asset",names(asset_components)[names(asset_components) != "intervention_asset"])]
asset_components$assets_sample_size <- NULL


cat(paste0("\n",Sys.time()," Merged all sheets into single table"), file = log_con, append = TRUE)
cat(paste0("\n Column names are "), file = log_con, append = TRUE)
cat(paste0("\n",names(asset_components)), file = log_con, append = TRUE)

asset_components$input_unit[asset_components$cf_name == "no_granular_data"] = "no_granular_data"
asset_components$input_unit[asset_components$input_unit == "metres"] = "m"

#Standerdise to SI units
for(i in 1:nrow(asset_components)){
  sub_unit = asset_components$input_unit[i]
  if(sub_unit == "kg"){
    # Do nothing
  } else if (sub_unit == "tonnes") {
    asset_components$quantity[i] = asset_components$quantity[i] * 1000
    asset_components$A5[i] = asset_components$A5[i] * 1000
    asset_components$input_unit[i] = "kg"
  } else {
    if(!sub_unit %in% c("m","m2","m3","no_granular_data")){
      stop("Unknown input_unit:  ",sub_unit)
    }
  }
  
}

# Standardise intervention_assets and asset_components to SI units

intervention_assets_sub = intervention_assets[,c("asset","asset_unit")]
intervention_assets_sub = unique(intervention_assets_sub)
asset_components = left_join(asset_components, intervention_assets_sub, by = c("intervention_asset" = "asset"))

for(i in 1:nrow(asset_components)){
  sub_unit = asset_components$asset_unit[i]
  if (sub_unit == "km") {
    asset_components$quantity[i] = asset_components$quantity[i] / 1000
    asset_components$A5[i] = asset_components$A5[i] / 1000
    asset_components$input_unit[i] = "asset_unit"
  } else {
    if(!sub_unit %in% c("m","number")){
      stop("Unknown asset_unit:  ",sub_unit)
    }
  }
  
}

intervention_assets$asset_unit[intervention_assets$asset_unit == "km"] = "m"
asset_components$asset_unit = NULL


# Carbon Factors
path = file.path(dir,"Data Tables/Examples for Malcolm 250122/carbon_factors_library.csv")
cat(paste0("\n",Sys.time()," reading ",path), file = log_con, append = TRUE, sep = "\n")

carbon_factors = read_csv(path)

if(any(duplicated(carbon_factors$cf_name))){
  warning("Duplicated carbon factor names")
  dups <- carbon_factors$cf_name[duplicated(carbon_factors$cf_name)]
  cat(paste0("\n Duplicated carbon factor names found"), file = log_con, append = TRUE)
  cat(paste0("\n",dups), file = log_con, append = TRUE)
  
  cat(paste0("\n De-duplicating"), file = log_con, append = TRUE)
  
  carbon_factors_notdup = carbon_factors[!carbon_factors$cf_name %in% dups, ]
  carbon_factors_dup = carbon_factors[carbon_factors$cf_name %in% dups, ]
  carbon_factors_dup = carbon_factors_dup %>%
    group_by(cf_name) %>%
    group_split()
  carbon_factors_res = list()
  for(i in seq_len(length(carbon_factors_dup))){
    sub = carbon_factors_dup[[i]]
    
    # Select Based on methodology
    if(all(grepl("Defra",sub$methodology))){
      if(all(grepl("Scope",sub$methodology))){
        if(any(grepl("All Scope",sub$methodology))){
          sub = sub[grepl("All Scope",sub$methodology),]
        } else {
          sub = sub[grepl("Scope 3",sub$methodology),]
        }
        
      }
      if(all(grepl(" RF",sub$methodology))){
        sub = sub[grepl("with RF",sub$methodology),]
      }
      if(all(grepl("Waste",sub$methodology))){
        if(any(grepl("Open-loop",sub$methodology))){
          sub = sub[grepl("Open-loop",sub$methodology),]
        }
        if(any(grepl("Landfill",sub$methodology))){
          sub = sub[grepl("Landfill",sub$methodology),]
        }
        if(any(grepl("Closed-loop",sub$methodology))){
          sub = sub[grepl("Closed-loop",sub$methodology),]
        }
      }
      
    } 
    
    if(nrow(sub) == 1){carbon_factors_res[[i]] <- sub; next}
    
    if(all(grepl("Bath",sub$methodology))){
      if(length(unique(sub$methodology)) > 1){
        sub = sub[sub$methodology == "Bath ICE - 3", ]
      }
    }
    
    if(nrow(sub) == 1){carbon_factors_res[[i]] <- sub; next}
    
    if(all(grepl("EMEP/EEA",sub$methodology))){
      if(length(unique(sub$methodology)) > 1){
        sub = sub[grepl("Non-Hand Held",sub$methodology), ]
      }
    }
    
    if(nrow(sub) == 1){carbon_factors_res[[i]] <- sub; next}
    
    
    if(length(unique(sub$methodology)) > 1){
      if(any(grepl("Plastics Europe EPD",sub$methodology))){
        sub <- sub[grepl("Plastics Europe EPD",sub$methodology),]
      }
    }
    
    if(nrow(sub) == 1){carbon_factors_res[[i]] <- sub; next}
    
    # Select by Location
    if(length(unique(sub$source_id)) > 1){
      if(any(sub$source_id == "UK")){
        sub <- sub[sub$source_id == "UK",]
      } else if(any(grepl("Europe",sub$source_id))){
        sub <- sub[grepl("Europe",sub$source_id),]
        if(nrow(sub) > 1){
          sub <- sub[sub$source_id == "Europe",]
        }
      } else if (any(grepl("Global",sub$source_id))) {
        sub <- sub[grepl("Global",sub$source_id),]
      }
    }
    
    if(nrow(sub) == 1){carbon_factors_res[[i]] <- sub; next}
    
    # Select by Units
    if(length(unique(sub$input_unit)) > 1){
      if("tonne" %in% sub$input_unit){
        sub <- sub[sub$input_unit  == "tonne",]
      } else if("litre" %in% sub$input_unit){
        sub <- sub[sub$input_unit  == "litre",]
      } else if("kg" %in% sub$input_unit){
        sub <- sub[sub$input_unit  == "kg",]
      } else if("km" %in% sub$input_unit){
        sub <- sub[sub$input_unit  == "km",]
      } else if("tkm" %in% sub$input_unit){
        sub <- sub[sub$input_unit  == "tkm",]
      } else if("pkm" %in% sub$input_unit){
        sub <- sub[sub$input_unit  == "pkm",]
      } else if("m3" %in% sub$input_unit){
        sub <- sub[sub$input_unit  == "m3",]
      }
    }
    
    if(nrow(sub) == 1){carbon_factors_res[[i]] <- sub; next}
    
    
    stop("muliple rows got though for ",i)
  }
  carbon_factors_res = bind_rows(carbon_factors_res)
  summary(duplicated(carbon_factors_res$cf_name))
  
  carbon_factors = rbind(carbon_factors_notdup, carbon_factors_res)
  carbon_factors = carbon_factors[,c("cf_name","material_type","carbon_factor","carbon_factor_units","input_unit",
                                     "category")]
  cat(paste0("\n",Sys.time()," removed duplicated carbon factors "), file = log_con, append = TRUE, sep = "\n")
}

# Change Gypsum to its own carbon factor type
carbon_factors$material_type[carbon_factors$cf_name == "Plaster (Gypsum) - General"] = "Gypsum"



#DO checks
interventions_sub = interventions[,c("mode","intervention_class","intervention"), drop = FALSE,]
intervention_assets_sub = intervention_assets[,c("intervention","asset")]
asset_components_sub = asset_components[,c("intervention_asset","cf_name")]
carbon_factors_sub = carbon_factors[,c("cf_name","carbon_factor")]

interventions_summary = left_join(interventions_sub, intervention_assets_sub, by = "intervention")
interventions_summary = left_join(interventions_summary, asset_components_sub, by = c("asset" = "intervention_asset"))
interventions_summary = left_join(interventions_summary, carbon_factors_sub, by = "cf_name")

interventions_summary = interventions_summary %>%
  group_by(mode,intervention_class,intervention) %>%
  summarise(no_asset = length(unique(asset[!is.na(asset)])),
            no_components = length(unique(cf_name[!is.na(cf_name)])),
            no_carbon_factor = length(carbon_factor[!is.na(carbon_factor)]))

interventions_summary <- interventions_summary[order(interventions_summary$no_carbon_factor, decreasing = TRUE),]
write.csv(interventions_summary, "data_import_summary.csv", row.names = FALSE, na = "")


# Write out tables
cat(paste0("\n",Sys.time()," saving outputs "), file = log_con, append = TRUE, sep = "\n")

write.csv(interventions, "../sdca-data/data_tables/interventions.csv", row.names = FALSE, na = "", fileEncoding = "UTF-8")
write.csv(intervention_assets, "../sdca-data/data_tables/intervention_assets.csv", row.names = FALSE, na = "", fileEncoding = "UTF-8")
write.csv(asset_components, "../sdca-data/data_tables/asset_components.csv", row.names = FALSE, na = "", fileEncoding = "UTF-8")
write.csv(carbon_factors, "../sdca-data/data_tables/carbon_factors.csv", row.names = FALSE, na = "", fileEncoding = "UTF-8")
write.csv(intervention_assets_parameters, "../sdca-data/data_tables/intervention_assets_parameters.csv", row.names = FALSE, na = "", fileEncoding = "UTF-8")



cat(paste0("\n",Sys.time()," Processing complete "), file = log_con, append = TRUE, sep = "\n")
