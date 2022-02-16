# prep the mode shift table for the package
library(readxl)

#dir = "C:/Users/malco/University of Leeds/TEAM - Shared Digital Carbon Architecture - General"
dir = "D:/University of Leeds/TEAM - Shared Digital Carbon Architecture - Documents/General"

path = file.path(dir,"WP4 – In use emissions of transport infrastructure and induced demand/Mode Shift/mode shift assumptions.xlsx")

modeshift = read_excel(path)
modeshift = modeshift[,1:9]

names(modeshift) = c("mode","intervention_class","travel_mode",
                     "modeshift_low","modeshift_average","modeshift_high",
                     "induceddemand_low","induceddemand_average","induceddemand_high")

# Match names with intervention table
modeshift$mode[modeshift$mode == "Cycling"] = "Bicycle"
modeshift$mode[modeshift$mode == "High Speed Rail"] = "High speed rail"
modeshift$mode[modeshift$mode == "Heavy Rail"] = "Rail"

modeshift$intervention_class[modeshift$intervention_class == "New"] = "New construction"

modeshift$travel_mode[modeshift$travel_mode == "car driver"] = "drive"
modeshift$travel_mode[modeshift$travel_mode == "car passenger"] = "passenger"

# Replace NA with 0
modeshift[4:9] <- lapply(modeshift[4:9], function(x){
  x[is.na(x)] <- 0
  x
})

# Tempoary fix: Scale from 0-1
modeshift[4:9] <- lapply(modeshift[4:9], function(x){
  x = ifelse(x > 1, x/100, x)
  x
})

modeshift$modeshift_average <- ifelse(modeshift$modeshift_average == 0,
                                      (modeshift$modeshift_low +modeshift$modeshift_high)/2,
                                      modeshift$modeshift_average)

modeshift$induceddemand_average <- ifelse(modeshift$induceddemand_average == 0,
                                      (modeshift$induceddemand_low +modeshift$induceddemand_high)/2,
                                      modeshift$induceddemand_average)


write.csv(modeshift, "../sdca-data/package_files/mode_shifts.csv", 
          row.names = FALSE, fileEncoding = "UTF-8")



