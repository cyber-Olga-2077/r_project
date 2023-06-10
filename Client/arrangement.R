if(!require(dplyr)) {
    install.packages("dplyr")
    library(dplyr)
}

filter_table <- function(input_data){
    data <- filter(input_data, is.element(V3, c("TMIN", "TMAX")))

    colnames(data) <- c("WeatherStationID", "Date", "MeasurementType", "MeasurementValue", "MeasurementFlag", "QualityFlag", "SourceFlag", "ObservationTime")
    data <- filter(data, QualityFlag == "")

    return(data)
}

format_weather_station_dates <- function (data) {
    data$Date <- as.POSIXct(strptime(data$Date, format = "%Y%m%d"))
    data$Month <- format(data$Date, "%m")
    data$Year <- format(data$Date, "%Y")

    return(data)
}

aggregate_weather_data <- function (data) {
    data$MeasurementValue <- data$MeasurementValue / 10

    data <- aggregate(data$MeasurementValue, by = list(data$Year, data$Month, data$MeasurementType), FUN = mean)
    colnames(data) <- c("Year", "Month", "MeasurementType", "MeasurementValue")
    data <- arrange(data, Year, Month)

    TMAX_data <- data[data$MeasurementType == "TMAX",]
    TMIN_data <- data[data$MeasurementType == "TMIN",]

    months <- data.frame(Date = seq((as.Date(paste0(data$Year[1], "-", data$Month[1], "-01"))), (as.Date(paste0(data$Year[length(data$Year)], "-", data$Month[length(data$Month)], "-01"))), by = "month"))
    months$Month <- format(months$Date, "%m")
    months$Year <- format(months$Date, "%Y")

    TMAX_replacements <- data.frame(months$Month, months$Year)
    TMIN_replacements <- data.frame(months$Month, months$Year)

    TMAX_filled <- merge(TMAX_data, TMAX_replacements, by.x = c("Month", "Year"), by.y = c("months.Month", "months.Year"), all.x = T, all.y = T)
    TMAX_filled$MeasurementType <- "TMAX"

    TMIN_filled <- merge(TMIN_data, TMIN_replacements, by.x = c("Month", "Year"), by.y = c("months.Month", "months.Year"), all.x = T, all.y = T)
    TMIN_filled$MeasurementType <- "TMIN"


    return(rbind(TMAX_filled, TMIN_filled))
}