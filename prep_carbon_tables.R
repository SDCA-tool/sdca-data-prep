dir = "E:/Users/earmmor/University of Leeds/TEAM - Shared Digital Carbon Architecture - General"

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

cat(paste0("\n",Sys.time()," Merged all sheets into single table"), file = log_con, append = TRUE)
cat(paste0("\n Column names are "), file = log_con, append = TRUE)
cat(paste0("\n",names(asset_components)), file = log_con, append = TRUE)



# Carbon Factors
path = file.path(dir,"Data Tables/Examples for Malcolm 250122/carbon_factors_library.csv")
cat(paste0("\n",Sys.time()," reading ",path), file = log_con, append = TRUE, sep = "\n")

carbon_factors = read_csv(path)

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

write.csv(interventions, "../sdca-data/data_tables/interventions.csv", row.names = FALSE, na = "")
write.csv(intervention_assets, "../sdca-data/data_tables/intervention_assets.csv", row.names = FALSE, na = "")
write.csv(asset_components, "../sdca-data/data_tables/asset_components.csv", row.names = FALSE, na = "")
write.csv(carbon_factors, "../sdca-data/data_tables/carbon_factors.csv", row.names = FALSE, na = "")

cat(paste0("\n",Sys.time()," Processing complete "), file = log_con, append = TRUE, sep = "\n")