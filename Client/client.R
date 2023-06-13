#Set Working Directory, Load Config and Source Files
setwd("~/r_project/Client")
source(file = "config.R")
source(file = "arrangement.R")
source(file = "geolocation.R")
source(file = "forecasting.R")
source(file = "preparations.R")
source(file = "plots.R")
source(file = "map.R")

config <- load_config()


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


# Print Yearly Plots
print(plots$Historical$Yearly$TMAX)
print(plots$Historical$Yearly$TMIN)


# Print Monthly Plots
for (month in seq(1, length(plots$Forecasted$Monthly))) {
    print(plots$Forecasted$Monthly[[month]]$TMAX)
    print(plots$Forecasted$Monthly[[month]]$TMIN)
}

# Print Maps
print(maps$TMAX)
print(maps$TMIN)
