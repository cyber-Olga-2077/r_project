if(!require(dplyr)) {
    install.packages("dplyr")
    library(dplyr)
}

if(!require(plotly)) {
    install.packages("plotly")
    library(plotly)
}


createForecastPlot <- function (forecast, name) {
    known <- data.frame(MeasurementValue=as.matrix(forecast$x), Year=time(forecast$x))
    forecasted <- data.frame(MeasurementValue=as.matrix(forecast$mean), Year=time(forecast$mean))

    upper95 <- data.frame(MeasurementValue=as.matrix(forecast$upper[, 2]), Year = forecasted$Year)
    lower95 <- data.frame(MeasurementValue=as.matrix(forecast$lower[, 2]), Year = forecasted$Year)

    upper80 <- data.frame(MeasurementValue=as.matrix(forecast$upper[, 1]), Year = forecasted$Year)
    lower80 <- data.frame(MeasurementValue=as.matrix(forecast$lower[, 1]), Year = forecasted$Year)

    forecasted <- rows_insert(forecasted, known[nrow(known),], by = "Year")

    upper95 <- rows_insert(upper95, known[nrow(known),], by = "Year")
    lower95 <- rows_insert(lower95, known[nrow(known),], by = "Year")

    upper80 <- rows_insert(upper80, known[nrow(known),], by = "Year")
    lower80 <- rows_insert(lower80, known[nrow(known),], by = "Year")

    known <- arrange(known, Year)
    forecasted <- arrange(forecasted, Year)

    upper95 <- arrange(upper95, Year)
    lower95 <- arrange(lower95, Year)

    upper80 <- arrange(upper80, Year)
    lower80 <- arrange(lower80, Year)

    forecastPlot <- plot_ly()

    forecastPlot <- add_trace(p = forecastPlot, data = known, x = ~Year, y = ~MeasurementValue, type = 'scatter', mode = 'lines', name = "Known values", line = list(color = rgb(maxColorValue = 255, red = 200, green = 0, blue = 0)))
    forecastPlot <- add_trace(p = forecastPlot, data = forecasted, x = ~Year, y = ~MeasurementValue, type = 'scatter', mode = 'lines', name = "Forecasted values", line = list(color = rgb(maxColorValue = 255, red = 0, green = 0, blue = 200)))

    forecastPlot <- add_trace(p = forecastPlot, data = upper95, x = ~Year, y = ~MeasurementValue, type = 'scatter', mode = 'lines', legendgroup = "95", showlegend = FALSE, name = "95% confidence", line = list(color = rgb(maxColorValue = 255, red = 200, green = 200, blue = 200)))
    forecastPlot <- add_trace(p = forecastPlot, data = lower95, x = ~Year, y = ~MeasurementValue, type = 'scatter', mode = 'lines', legendgroup = "95", name = "95% confidence", fill = "tonexty", fillcolor = rgb(maxColorValue = 255, red = 200, green = 200, blue = 200, alpha = 127), line = list(color = rgb(maxColorValue = 255, red = 200, green = 200, blue = 200)))

    forecastPlot <- add_trace(p = forecastPlot, data = upper80, x = ~Year, y = ~MeasurementValue, type = 'scatter', mode = 'lines', legendgroup = "80", showlegend = FALSE, name = "80% confidence", line = list(color = rgb(maxColorValue = 255, red = 150, green = 150, blue = 150)))
    forecastPlot <- add_trace(p = forecastPlot, data = lower80, x = ~Year, y = ~MeasurementValue, type = 'scatter', mode = 'lines', legendgroup = "80", name = "80% confidence", fill = "tonexty", fillcolor = rgb(maxColorValue = 255, red = 150, green = 150, blue = 150, alpha = 127), line = list(color = rgb(maxColorValue = 255, red = 150, green = 150, blue = 150)))

    forecastPlot <- layout(forecastPlot, title = name, xaxis = list(title = "Year", rangeselector = list(rangeslider = list(type = "date"))), yaxis = list(title = "Temperature"))

    return(forecastPlot)
}

createYearlyPlots <- function (stations) {
    message("Creating yearly plots...")

    TMAX_YEARLY <- plot_ly()

    for (i in seq_len(length(stations))) {
        hue <- (trunc((i-1)/5)) * (1/7)

        data <- stations[[i]]$Timeseries$TMAX$Yearly$ImputedTimeseries
        data <- data.frame(MeasurementValue=as.matrix(data), Year=time(data))
        TMAX_YEARLY <- add_trace(p = TMAX_YEARLY, legendgroup = stations[[i]]$Informations$Region, data = data, x = ~Year, y = ~MeasurementValue, type = 'scatter', mode = 'lines', name = paste0(stations[[i]]$Informations$Station_ID, " - ", stations[[i]]$Informations$Region), color = hsv(h = hue, s = 1, v = 1, ))
    }

    TMAX_YEARLY <- layout(TMAX_YEARLY, title = "Yearly averages of maximum daily temperatures", xaxis = list(title = "Year"), yaxis = list(title = "Temperature"))

    TMIN_YEARLY <- plot_ly()

    for (i in seq_len(length(stations))) {
        hue <- (trunc((i-1)/5)) * (1/7)

        data <- stations[[i]]$Timeseries$TMIN$Yearly$ImputedTimeseries
        data <- data.frame(MeasurementValue=as.matrix(data), Year=time(data))
        TMIN_YEARLY <- add_trace(p = TMIN_YEARLY, legendgroup = stations[[i]]$Informations$Region, data = data, x = ~Year, y = ~MeasurementValue, type = 'scatter', mode = 'lines', name = paste0(stations[[i]]$Informations$Station_ID, " - ", stations[[i]]$Informations$Region), color = hsv(h = hue, s = 1, v = 1, ))
    }

    TMIN_YEARLY <- layout(TMIN_YEARLY, title = "Yearly averages of minimum daily temperatures", xaxis = list(title = "Year"), yaxis = list(title = "Temperature"))

    message("Yearly plots created.")
    message("------------------------------------------------------------------")

    return(list(TMAX = TMAX_YEARLY, TMIN = TMIN_YEARLY))
}

create_plots <- function (stations) {
    message("")
    message("##################################################################")
    message("########################## PLOTTTING #############################")
    message("##################################################################")
    message("")

    plots <- list(
        Historical = list(
            Yearly = createYearlyPlots(stations)
        ),
        Forecasted = list(
            Monthly = lapply(stations, function (station) {
                message(paste0("Creating monthly plots for ", station$Informations$Station_ID), "...")

                list(
                    Name = station$Informations$Station_ID,
                    TMAX = createForecastPlot(station$Forecast$TMAX[[station$UsedForecastingMethod]], name = paste0("Forecasted maximum average monthly temperature for ", station$Informations$Station_ID, " - ", station$Informations$Region)),
                    TMIN = createForecastPlot(station$Forecast$TMIN[[station$UsedForecastingMethod]], name = paste0("Forecasted minimum average monthly temperature for", station$Informations$Station_ID, " - ", station$Informations$Region))
                )
            })
        )
    )

    message("------------------------------------------------------------------")

    return(plots)
}