#Set Working Directory, Load Config and Source Files
setwd("~/r_project/Client")
source(file = "config.R")
source(file = "arrangement.R")
source(file = "geolocation.R")
source(file = "forecasting.R")
source(file = "preparations.R")
source(file = "plots.R")
source(file = "map.R")
source(file = "saving.R")
source(file = "compressing.R")
source(file = "uploading.R")

config <- load_config()


source("../Common/parse_env.R")
env <- parse_env()
api_key <- env$value[env$key == "TOKEN"]

# Try to load data from file, if not available, download and prepare data
if (file.exists("analysed_data.rds")) {
    analysed_data <- readRDS("analysed_data.rds")
} else {
    preselected_data    <- preselect_data();
    prepared_data       <- download_and_prepare_data(preselected_data)
    best_forecast_model <- estimate_best_forecast_model(prepared_data)
    analysed_data       <- forecast_data(prepared_data, best_forecast_model)
    saveRDS(analysed_data, file = "analysed_data.rds")
}


# Try to load plots from file, if not available, create plots
if (file.exists("plots.rds")) {
    plots <- readRDS("plots.rds")
} else {
    plots <- create_plots(analysed_data)
    saveRDS(plots, file = "plots.rds")
}

# Try to load maps from file, if not available, create maps
if (file.exists("maps.rds")) {
    maps <- readRDS("maps.rds")
} else {
    maps <- createWorldMap(analysed_data)
    saveRDS(maps, file = "maps.rds")
}

# Save plots and maps to files
createDirectory()
saveYearlyPlots(plots$Historical$Yearly)
saveMonthlyPlots(plots$Forecasted$Monthly)
saveMaps(maps)

# Compress plots and maps
removeLibraryFiles()
compressedPlots <- compressPlots()
compressedStationList <- compressStationList(analysed_data)

# Send plots and maps to server
message("Sending plots to server...")
uploadDataToServer(config$POST_plots, compressedPlots)

message("Sending station list to server...")
uploadDataToServer(config$POST_station_list, compressedStationList)
