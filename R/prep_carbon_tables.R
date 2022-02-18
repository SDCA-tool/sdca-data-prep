#dir = "E:/Users/earmmor/University of Leeds/TEAM - Shared Digital Carbon Architecture - General"
dir = "D:/University of Leeds/TEAM - Shared Digital Carbon Architecture - Documents/General"
#dir = "C:/Users/malco/University of Leeds/TEAM - Shared Digital Carbon Architecture - General"

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
path = file.path(dir,"Data Tables/clean/interventions.xlsx")
cat(paste0("\n",Sys.time()," reading ",path), file = log_con, append = TRUE, sep = "\n")
interventions = read_excel(path)
cat(paste0("\n",Sys.time()," rows =  ",nrow(interventions)," cols = ",ncol(interventions)), file = log_con, append = TRUE, sep = "\n")
interventions$infrastructure_type <- "transport"

interventions = interventions[,c("infrastructure_type","mode_class","mode",
                                 "intervention_class","ID","intervention",
                                  "intervention_description","geometry",
                                 "include","interface",
                                  "user_entered_parameters","elevation_unit",
                                 "elevation_default")]

names(interventions) = c("infrastructure_type","mode_class","mode",
                         "intervention_class","intervention","intervention_name",
                         "intervention_description","geometry",
                         "include","interface",
                         "user_entered_parameters","elevation_unit",
                         "elevation_default")

interventions$include <- ifelse(interventions$include == "y", TRUE, FALSE)

interventions <- interventions[interventions$include,]


#assets

path = file.path(dir,"Data Tables/clean/interventions_to_assets.xlsx")
cat(paste0("\n",Sys.time()," reading ",path), file = log_con, append = TRUE, sep = "\n")
sheets = excel_sheets(path)
cat(paste0("\n Sheet found: ",sheets), file = log_con, append = TRUE)

#Check for matches
log_message = paste0("\n",Sys.time()," The following  tabs in interventions_to_assets are not in interventions: \n",
                     paste(sheets[!sheets %in% interventions$intervention], collapse = ", "))
message(log_message)
cat(log_message, file = log_con, append = TRUE)
log_message = paste0("\n",Sys.time()," The following  interventions in interventions are not tabs in interventions_to_assets : \n",
        paste(interventions$intervention[!interventions$intervention %in% sheets], collapse = ", "))

message(log_message)
cat(log_message, file = log_con, append = TRUE)


assets <- list()
sub_names = c("asset_id","asset","include",
              "asset_class","asset_unit","unit_type",
              "asset_parameters","user_entered_parameters","tool_extracted_parameters",
              "tool_calculated_parameters", "area_unit","area_default",
              "diameter_unit","diameter_default","length_unit",
              "length_default","number_unit","number_default",
              "span_unit","span_default","volume_unit",
              "volume_default","width_unit","width_default")

for(i in 1:length(sheets)){
  sub = read_excel(path, sheet = sheets[i], col_types = "text")
  if(!identical(names(sub), sub_names)){
    message("Wrong colums in ",sheets[i]," sheet no: ",i)
    cat(paste0("\n",Sys.time()," Wrong column names in ",sheets[i]), file = log_con, append = TRUE)
    cat(paste0("\n missing: ",paste(sub_names[!sub_names %in% names(sub)], collapse = ", ")), file = log_con, append = TRUE)
  } 
  if(!"include" %in% names(sub)){
    sub$include <- "y"
    sub <- sub[,sub_names]
  }
  
  sub = sub[!is.na(sub$asset_id),]
  sub$intervention = sheets[i]
  sub$diameter_default = round(as.numeric(sub$diameter_default),5)
  sub$include = ifelse(sub$include == "y", TRUE, FALSE)
  assets[[i]] = sub

}
cat(paste0("\n",Sys.time()," Imported all sheets"), file = log_con, append = TRUE)

assets = bind_rows(assets)
assets$Notes = NULL
assets <- assets[assets$include,]

names(assets)[1:2] <- c("asset","asset_name")
assets <- assets[,c("intervention",names(assets)[names(assets) != "intervention"])]

cat(paste0("\n",Sys.time()," Merged all sheets into single table"), file = log_con, append = TRUE)
cat(paste0("\n Column names are "), file = log_con, append = TRUE)
cat(paste0("\n",names(assets)), file = log_con, append = TRUE)

cat(paste0("\n",Sys.time()," Creating parameters table"), file = log_con, append = TRUE)

assets_parameters = assets[,c("asset",
                              "area_unit","area_default",
                              "diameter_unit","diameter_default",
                             "length_unit","length_default",
                             "number_unit","number_default",
                             "span_unit","span_default",
                             "volume_unit","volume_default",
                             "width_unit","width_default")]#
                                                   
assets_parameters[] <- lapply(assets_parameters, as.character)

iap = tidyr::pivot_longer(assets_parameters[,c("asset",
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
iap$parameter <- gsub("_unit","",iap$parameter)
iap2 = tidyr::pivot_longer(assets_parameters[,c("asset",
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
iap2$parameter <- gsub("_default","",iap2$parameter)
iap$default = iap2$default
assets_parameters <- iap[!is.na(iap$unit),]
assets_parameters$default <- as.numeric(assets_parameters$default)

assets_parameters <- unique(assets_parameters)


assets <- assets[,c("intervention", "asset", "asset_name","include","asset_class",
                                              "asset_unit","unit_type","asset_parameters",
                                              "user_entered_parameters","tool_extracted_parameters",
                                              "tool_calculated_parameters")]



# Asset Components
path = file.path(dir,"Data Tables/clean/assets.xlsx")
cat(paste0("\n",Sys.time()," reading ",path), file = log_con, append = TRUE, sep = "\n")

sheets = excel_sheets(path)
cat(paste0("\n Sheet found: ",sheets), file = log_con, append = TRUE)

# TODO: Manual filtering
sheets = sheets[!sheets %in% c("Template")]

components <- list()
for(i in 1:length(sheets)){
  sub = read_excel(path, sheet = sheets[i], col_types = "text")
  sub = sub[!is.na(sub$item),]
  sub = sub[!is.na(sub$cf_name),]
  sub$asset = sheets[i]
  sub$A5 = round(as.numeric(sub$A5),5)
  sub$quantity = round(as.numeric(sub$quantity),5)
  components[[i]] = sub
}
cat(paste0("\n",Sys.time()," Imported all sheets"), file = log_con, append = TRUE)

components = bind_rows(components)
components = components[,c("asset",names(components)[names(components) != "asset"])]
components$assets_sample_size <- NULL

names(components) <- gsub("-","_",names(components))

cat(paste0("\n",Sys.time()," Merged all sheets into single table"), file = log_con, append = TRUE)
cat(paste0("\n Column names are "), file = log_con, append = TRUE)
cat(paste0("\n",names(components)), file = log_con, append = TRUE)

#components$input_unit[components$cf_name == "no_granular_data"] = "no_granular_data"
components$input_unit[components$input_unit == "metres"] = "m"
components$input_unit[components$input_unit == "length"] = "km"
components$input_unit[components$input_unit == "area (m2)"] = "m2"
components$input_unit[components$input_unit == "1"] = "number"
components$input_unit[is.na(components$input_unit)] = "number"

# Standardise assets and components to SI units
components$no_granular_data_A1_A3 = as.numeric(components$no_granular_data_A1_A3)
components$no_granular_data_A4 = as.numeric(components$no_granular_data_A4)
components$no_granular_data_B2 = as.numeric(components$no_granular_data_B2)
components$no_granular_data_B4 = as.numeric(components$no_granular_data_B4)

#Standerdise to SI units
for(i in 1:nrow(components)){
  sub_unit = components$input_unit[i]
  if(sub_unit == "kg"){
    # Do nothing
  } else if (sub_unit == "tonnes") {
    components$quantity[i] = components$quantity[i] * 1000
    components$A5[i] = components$A5[i] * 1000
    components$no_granular_data_A1_A3[i] = components$no_granular_data_A1_A3[i] * 1000
    components$no_granular_data_A4[i] = components$no_granular_data_A4[i] * 1000
    components$no_granular_data_B2[i] = components$no_granular_data_B2[i] * 1000
    components$no_granular_data_B4[i] = components$no_granular_data_B4[i] * 1000
    components$input_unit[i] = "kg"
  
  } else if (sub_unit == "km") {
    #components$quantity[i] = components$quantity[i]
    components$A5[i] = components$A5[i] / 1000
    components$no_granular_data_A1_A3[i] = components$no_granular_data_A1_A3[i] / 1000
    components$no_granular_data_A4[i] = components$no_granular_data_A4[i] / 1000
    components$no_granular_data_B2[i] = components$no_granular_data_B2[i] / 1000
    components$no_granular_data_B4[i] = components$no_granular_data_B4[i] / 1000
    components$input_unit[i] = "m"
    
  } else {
    if(!sub_unit %in% c("m","m2","m3","no_granular_data", "l","kwh","number","average depth (m)")){
      stop("Unknown input_unit:  ",sub_unit)
    }
  }
  
}

assets_sub = assets[,c("asset","asset_unit")]
assets_sub = unique(assets_sub)
components = left_join(components, assets_sub, by = c("asset" = "asset"))

for(i in 1:nrow(components)){
  sub_unit = components$asset_unit[i]
  if(!is.na(sub_unit)){
    if (sub_unit == "km") {
      components$quantity[i] = components$quantity[i] / 1000
      components$A5[i] = components$A5[i] / 1000
      components$no_granular_data_A1_A3[i] = components$no_granular_data_A1_A3[i] / 1000
      components$no_granular_data_A4[i] = components$no_granular_data_A4[i] / 1000
      components$no_granular_data_B2[i] = components$no_granular_data_B2[i] / 1000
      components$no_granular_data_B4[i] = components$no_granular_data_B4[i] / 1000
      components$input_unit[i] = "asset_unit"
    } else if(sub_unit == "km2"){
      components$quantity[i] = components$quantity[i] / 1e6
      components$A5[i] = components$A5[i] / 1e6
      components$no_granular_data_A1_A3[i] = components$no_granular_data_A1_A3[i] / 1e6
      components$no_granular_data_A4[i] = components$no_granular_data_A4[i] / 1e6
      components$no_granular_data_B2[i] = components$no_granular_data_B2[i] / 1e6
      components$no_granular_data_B4[i] = components$no_granular_data_B4[i] / 1e6
      components$input_unit[i] = "asset_unit"
    } else {
      if(!sub_unit %in% c("m","number")){
        stop("Unknown asset_unit:  ",sub_unit)
      }
    }
  }
}

assets$asset_unit[assets$asset_unit == "km"] = "m"
assets$asset_unit[assets$asset_unit == "km2"] = "m2"
components$asset_unit = NULL


# Carbon Factors
path = file.path(dir,"Data Tables/clean/carbon_factors_library.csv")
cat(paste0("\n",Sys.time()," reading ",path), file = log_con, append = TRUE, sep = "\n")

carbon_factors = read_csv(path)

if(any(duplicated(carbon_factors$cf_name))){
  warning("Duplicated carbon factor names")
  dups <- carbon_factors$cf_name[duplicated(carbon_factors$cf_name)]
  cat(paste0("\n Duplicated carbon factor names found"), file = log_con, append = TRUE)
  #cat(paste0("\n",dups), file = log_con, append = TRUE)
  
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

# Force IDs to lower case
interventions$intervention <- tolower(interventions$intervention)
assets$intervention <- tolower(assets$intervention)
assets$asset <- tolower(assets$asset)
assets_parameters$asset <- tolower(assets_parameters$asset)
components$asset <- tolower(components$asset)



#DO checks
interventions_sub = interventions[,c("mode","intervention_class","intervention"), drop = FALSE,]
assets_sub = assets[,c("intervention","asset")]
components_sub = components[,c("asset","cf_name")]
carbon_factors_sub = carbon_factors[,c("cf_name","carbon_factor")]

interventions_summary = left_join(interventions_sub, assets_sub, by = "intervention")
interventions_summary = left_join(interventions_summary, components_sub, by = "asset")
interventions_summary = left_join(interventions_summary, carbon_factors_sub, by = "cf_name")

interventions_summary = interventions_summary %>%
  group_by(mode,intervention_class,intervention) %>%
  summarise(no_asset = length(unique(asset[!is.na(asset)])),
            no_components = length(unique(cf_name[!is.na(cf_name)])),
            no_carbon_factor = length(carbon_factor[!is.na(carbon_factor)]))

interventions_summary <- interventions_summary[order(interventions_summary$no_carbon_factor, decreasing = TRUE),]
write.csv(interventions_summary, "data_import_summary.csv", row.names = FALSE, na = "")

# Pairwise Checks

summary(components$cf_name %in% carbon_factors$cf_name)

missing_cf = components$cf_name[!components$cf_name %in% carbon_factors$cf_name]
missing_cf = missing_cf[missing_cf != "no_granular_data"]
missing_cf = unique(missing_cf)

missing_components = assets$asset[!assets$asset %in% components$asset]
missing_components = unique(missing_components)

missing_assets1 = components$asset[!components$asset %in% assets$asset]
missing_assets1 = unique(missing_assets1)

missing_interventions = assets$intervention[!assets$intervention %in% interventions$intervention]
missing_interventions = unique(missing_interventions)

missing_assets2 = interventions$intervention[!interventions$intervention %in% assets$intervention]
missing_assets2 = unique(missing_assets2)

cat(paste0("\n"," ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n\n\n"), file = log_con, append = TRUE, sep = "\n")
cat(paste0("\n"," Summary of Missing Data"), file = log_con, append = TRUE, sep = "\n")
cat(paste0("\n"," Missing carbon factors"), file = log_con, append = TRUE, sep = "\n")
cat(paste0("\n",missing_cf), file = log_con, append = TRUE)

cat(paste0("\n"," Asssets which don't have any components"), file = log_con, append = TRUE, sep = "\n")
cat(paste0("\n",missing_components), file = log_con, append = TRUE)

cat(paste0("\n"," Assets that have components but are not listed in the asset table"), file = log_con, append = TRUE, sep = "\n")
cat(paste0("\n",missing_assets1), file = log_con, append = TRUE)

cat(paste0("\n"," Interventions that have assets but are not listed in the intervention table"), file = log_con, append = TRUE, sep = "\n")
cat(paste0("\n",missing_interventions), file = log_con, append = TRUE)

cat(paste0("\n"," Interventions that have no assets"), file = log_con, append = TRUE, sep = "\n")
cat(paste0("\n",missing_assets2), file = log_con, append = TRUE)



# Remove Scientific notation
components$quantity <- format(components$quantity, scientific = FALSE, digits = 5, trim = TRUE)
components$A5 <- format(components$A5, scientific = FALSE, digits = 5, trim = TRUE)
carbon_factors$carbon_factor <- format(carbon_factors$carbon_factor, scientific = FALSE, digits = 5, trim = TRUE)

components$quantity[grepl("NA",components$quantity)] <- NA
components$A5[grepl("NA",components$A5)] <- NA
carbon_factors$carbon_factor[grepl("NA",carbon_factors$carbon_factor)] <- NA

# components$quantity <- trimws(components$quantity)
# components$A5 <- trimws(components$A5)
# carbon_factors$carbon_factor <- trimws(carbon_factors$carbon_factor)

# Write out tables
cat(paste0("\n",Sys.time()," saving outputs "), file = log_con, append = TRUE, sep = "\n")

write.csv(interventions, "../sdca-data/data_tables/interventions.csv", row.names = FALSE, na = "", fileEncoding = "UTF-8")
write.csv(assets, "../sdca-data/data_tables/assets.csv", row.names = FALSE, na = "", fileEncoding = "UTF-8")
write.csv(components, "../sdca-data/data_tables/components.csv", row.names = FALSE, na = "", fileEncoding = "UTF-8")
write.csv(carbon_factors, "../sdca-data/data_tables/carbon_factors.csv", row.names = FALSE, na = "", fileEncoding = "UTF-8")
write.csv(assets_parameters, "../sdca-data/data_tables/assets_parameters.csv", row.names = FALSE, na = "", fileEncoding = "UTF-8")



cat(paste0("\n",Sys.time()," Processing complete "), file = log_con, append = TRUE, sep = "\n")
