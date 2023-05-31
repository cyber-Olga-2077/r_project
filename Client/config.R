load_config <- function() {
    setwd("~/r_project/Client")

    Config <- read.delim("config.txt", sep = "", header = FALSE)

    GET_weather_stations_inventory <- Config[Config$V1 == "GET_weather_stations_inventory",]$V2
    GET_weather_stations_directory <- Config[Config$V1 == "GET_weather_stations_directory",]$V2

    return (
        list (
            GET_weather_stations_inventory = GET_weather_stations_inventory,
            GET_weather_stations_directory = GET_weather_stations_directory
        )
    )
}