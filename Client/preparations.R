if(!require(dplyr)) {
    install.packages("dplyr")
    library(dplyr)
}

if(!require(httr)) {
    install.packages("httr")
    library(httr)
}

preselect_data <- function () {
    message("")
    message("##################################################################")
    message("####################### DATA PRESELECTION ########################")
    message("##################################################################")
    message("")

    message("Locating weather stations inventory data...")
    if (is.null(config$GET_weather_stations_inventory)) stop("Weather stations inventory data could not be located.")

    message("Downloading weather stations inventory data...")
    result <- httr::GET(url = config$GET_weather_stations_inventory, add_headers(Accept = "text/plain"))
    if (result$status_code != 200) stop("Weather stations inventory data download failed.")

    message("Reading weather stations inventory data...")
    weather_stations_inventory <- content(result, as = "text", type = "text/plain", encoding = "UTF-8")
    weather_stations_inventory <- read.csv(text = weather_stations_inventory, header = FALSE, sep = "")

    message("Filtering weather stations inventory data...")
    colnames(weather_stations_inventory) <- c("Station_ID", "Lon", "Lat", "Item", "Start_Date", "End_Date")
    weather_stations_inventory <- filter(weather_stations_inventory, grepl("TMAX", Item))
    weather_stations_inventory <- filter(weather_stations_inventory, grepl(format(Sys.Date(), "%Y"), End_Date))

    message("Calculating geographical locations of weather stations...")
    coords <- weather_stations_inventory[,c("Lat", "Lon")]
    weather_stations_inventory <- cbind(weather_stations_inventory, Region = coords_to_continent(coords))
    weather_stations_inventory <- arrange(weather_stations_inventory, Region, Start_Date)

    message("Selecting weather stations with most data for analysis...")
    to_analyse <- do.call(rbind, lapply(split(weather_stations_inventory, weather_stations_inventory$Region), function(x) x[1:5, c("Station_ID", "Lon", "Lat", "Region")]))
}

download_weather_station_data <- function (id) {
    if (is.null(config$GET_weather_stations_directory)) stop("Weather station data could not be located.")

    result <- httr::GET(url = paste0(config$GET_weather_stations_directory, id, ".csv.gz"), add_headers(Accept = "application/gzip"))

    if (result$status_code != 200) stop("<easurements download failed.")

    weather_station_data <- content(result, as = "raw", type = "application/gzip", encoding = "UTF-8")
    writeBin(object  = weather_station_data, con = "weather_station_data.csv.gz")
    weather_station_data <- read.csv(file = "weather_station_data.csv.gz", header = FALSE, sep = ",")
    file.remove("weather_station_data.csv.gz")

    message(paste0("Measurements from station ", id, " loadaed."))
    return(filter_table(weather_station_data))
}

download_and_prepare_data <- function (station_informations) {
    message("")
    message("##################################################################")
    message("################ DOWNLOADING AND DATA PREPARATION ################")
    message("##################################################################")
    message("")

    stations <- list()
    for (i in seq_len(nrow(station_informations))) {
        message(paste0("Downloading data for station ", station_informations$Station_ID[i], "..."))
        weather_station_data <- download_weather_station_data(station_informations$Station_ID[i])

        message(paste0("Formatting data for station ", station_informations$Station_ID[i], "..."))
        formatted_weather_station_data <- format_weather_station_dates(weather_station_data)

        message(paste0("Aggregating data for station ", station_informations$Station_ID[i], "..."))
        aggregated_weather_data <- aggregate_weather_data(formatted_weather_station_data)

        message(paste0("Data for station ", station_informations$Station_ID[i], " prepared."))
        stations[[i]] <- list(Informations = as.list(station_informations[i,]), Measurements = aggregated_weather_data)

        message("")
        message("==================================================================")
        message("")
    }

    return (stations)
}
