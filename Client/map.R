if(!require(dplyr)) {
    install.packages("dplyr")
    library(dplyr)
}

if(!require(plotly)) {
    install.packages("plotly")
    library(plotly)
}

createWorldMap <- function(stations) {
    TMIN_map_data <- data.frame()
    TMAX_map_data <- data.frame()

    for (station in stations) {
        TMIN_measurements <- station$Measurements[station$Measurements$MeasurementType == "TMIN", ]
        TMAX_measurements <- station$Measurements[station$Measurements$MeasurementType == "TMAX", ]

        TMIN_station_map_data <- data.frame(
            lon = station$Informations$Lon,
            lat = station$Informations$Lat,
            station_ID = station$Informations$Station_ID,
            Temperature = TMIN_measurements$MeasurementValue,
            Date = paste0(TMIN_measurements$Year, "-", TMIN_measurements$Month)
        )

        TMAX_station_map_data <- data.frame(
            lon = station$Informations$Lon,
            lat = station$Informations$Lat,
            station_ID = station$Informations$Station_ID,
            Temperature = TMAX_measurements$MeasurementValue,
            Date = paste0(TMAX_measurements$Year, "-", TMAX_measurements$Month)
        )

        TMIN_map_data <- rbind(TMIN_map_data, TMIN_station_map_data)
        TMAX_map_data <- rbind(TMAX_map_data, TMAX_station_map_data)
    }

    TMIN_map <- plot_geo(locationmode = "country names")
    TMIN_map <- add_markers(
        data = TMIN_map_data,
        p = TMIN_map,
        x = ~lat,
        y = ~lon,
        color = ~Temperature,
        colors = "YlOrRd",
        hoverinfo = "text",
        text = ~paste("Station ID:", station_ID, "<br>Temperature:", Temperature),
        frame = ~Date,
        size = 2
    )
    TMIN_map <-layout(
        p = TMIN_map,
        title = paste("Minimum average monthly temperature"),
        geo = list(
            showframe = TRUE,
            showcoastlines = TRUE,
            projection = list(type = "natural earth")
        )
    )

    TMAX_map <- plot_geo(locationmode = "country names")
    TMAX_map <- add_markers(
        data = TMAX_map_data,
        p = TMAX_map,
        x = ~lat,
        y = ~lon,
        color = ~Temperature,
        colors = "YlOrRd",
        hoverinfo = "text",
        text = ~paste("Station ID:", station_ID, "<br>Temperature:", Temperature),
        frame = ~Date,
        size = 2
    )
    TMAX_map <-layout(
        p = TMAX_map,
        title = paste("Maximum average monthly temperature"),
        geo = list(
            showframe = TRUE,
            showcoastlines = TRUE,
            projection = list(type = "natural earth")
        )
    )

    return(list(
        TMIN = TMIN_map,
        TMAX = TMAX_map
    ))
}


