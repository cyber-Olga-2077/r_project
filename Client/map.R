

# Tworzenie pustego data frame
combined_data <- data.frame(lon = numeric(),
                            lat = numeric(),
                            temperature = numeric(),
                            station_ID = character())

# Pętla iterująca po danych stacji
for (i in seq_along(analysed_data)) {
  Forecast <- analysed_data[[i]]$Measurements$MeasurementValue
  lon <- analysed_data[[i]]$Informations$Lon
  lat <- analysed_data[[i]]$Informations$Lat
  month <- analysed_data[[i]]$Measurements$Month
  year <- analysed_data[[i]]$Measurements$Year
  
  # Dodawanie danych dla wszystkich stacji
  combined_data <- rbind(combined_data,
                         data.frame(lon = lon,
                                    lat = lat,
                                    temperature = Forecast,
                                    station_ID = analysed_data[[i]]$Informations$Station_ID))
}

createWorldMap <- function(lon, lat, station_ID, temperature) {
  # Tworzenie danych do mapy
  map_data <- data.frame(lon = rep(unlist(lon), lengths(temperature)),
                         lat = rep(unlist(lat), lengths(temperature)),
                         station_ID = rep(unlist(station_ID), lengths(temperature)),
                         temperature = unlist(temperature))
  
  # Rysowanie mapy świata
  map <- plot_geo(
    map_data,
    locationmode = "country names"
  ) %>%
    add_markers(
      x = ~lon,
      y = ~lat,
      color = ~temperature,
      colors = "RdBu",
      colorbar = list(title = "Temperature"),
      hoverinfo = "text",
      text = ~paste("Station ID:", station_ID, "<br>Temperature:", temperature)
    ) %>%
    layout(
      title = paste("Temperature world map for", selected_month, "/", selected_year),
      geo = list(
        showframe = FALSE,
        showcoastlines = TRUE,
        projection = list(type = "natural earth")
      )
    )
  
  return(map)
}


