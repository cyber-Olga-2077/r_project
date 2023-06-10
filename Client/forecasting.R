if(!require(dplyr)) {
    install.packages("dplyr")
    library(dplyr)
}

if(!require(forecast)) {
    install.packages("forecast")
    library(forecast)
}

if(!require(imputeTS)) {
    install.packages("imputeTS")
    library(imputeTS)
}


forecast_data <- function (stations, method = "") {
    message("")
    message("##################################################################")
    message("################# FORECASTING AND DECOMPOSITION ##################")
    message("##################################################################")
    message("")
    
    for (i in seq_along(stations)) {
        results <- forecast_station(i, stations, method)
        stations[[i]]$Timeseries <- results$Timeseries
        stations[[i]]$Forecast <- results$Forecast
        stations[[i]]$Decomposition <- results$Decomposition
        stations[[i]]$UsedForecastingMethod <- method
    }

    return(stations)
}

forecast_station <- function(index, stations, method = "", accuracyTest = FALSE) {
    station <- stations[[index]]
    
    measurements <- station$Measurements
    station_ID <- station$Informations$Station_ID

    message(paste0("Creating time series for highest temperatures from station ", station_ID, "..."))
    TMAX_measurements <- measurements[measurements$MeasurementType == "TMAX",]
    TMAX_arranged_measurements <- arrange(TMAX_measurements, Year, Month)
    if (accuracyTest) TMAX_arranged_measurements <- TMAX_arranged_measurements[1:(length(TMAX_arranged_measurements$MeasurementValue) - 120),]
    TMAX_time_series <- ts(TMAX_arranged_measurements$MeasurementValue, start = c(TMAX_arranged_measurements$Year[1], TMAX_arranged_measurements$Month[1]), frequency = 12)

    message(paste0("Imputing time series for highest temperatures from station ", station_ID, "..."))
    TMAX_imputed_time_series <- na_kalman(TMAX_time_series)

    message(paste0("Averaging yearly time series for lowest temperatures from statio ", station_ID, "..."))
    TMAX_imputed_yearly_series <- data.frame(Y=as.matrix(TMAX_imputed_time_series), Year=substr(time(TMAX_imputed_time_series), start = 0, stop = 4))
    TMAX_imputed_yearly_series <- aggregate(TMAX_imputed_yearly_series$Y, by = list(TMAX_imputed_yearly_series$Year), FUN = mean)
    colnames(TMAX_imputed_yearly_series) <- c("Year", "MeasurementValue")
    TMAX_imputed_yearly_series <- arrange(TMAX_imputed_yearly_series, Year)
    TMAX_imputed_yearly_series <- TMAX_imputed_yearly_series[2:nrow(TMAX_imputed_yearly_series)-1,]

    TMAX_imputed_yearly_series <- ts(TMAX_imputed_yearly_series$MeasurementValue, start = TMAX_imputed_yearly_series$Year[[1]], frequency = 1)

    message("------------------------------------------------------------------")

    message(paste0("Creating time series for lowest temperatures from station ", station_ID, "..."))
    TMIN_measurements <- measurements[measurements$MeasurementType == "TMIN",]
    TMIN_arranged_measurements <- arrange(TMIN_measurements, Year, Month)
    if (accuracyTest) TMIN_arranged_measurements <- TMIN_arranged_measurements[1:(length(TMIN_arranged_measurements$MeasurementValue) - 120),]
    TMIN_time_series <- ts(TMIN_arranged_measurements$MeasurementValue, start = c(TMIN_arranged_measurements$Year[1], TMIN_arranged_measurements$Month[1]), frequency = 12)

    message(paste0("Imputing time series for lowest temperatures from station ", station_ID, "..."))
    TMIN_imputed_time_series <- na_kalman(TMIN_time_series)

    message(paste0("Averaging yearly time series for lowest temperatures from statio ", station_ID, "..."))
    TMIN_imputed_yearly_series <- data.frame(Y=as.matrix(TMIN_imputed_time_series), Year=substr(time(TMIN_imputed_time_series), start = 0, stop = 4))
    TMIN_imputed_yearly_series <- aggregate(TMIN_imputed_yearly_series$Y, by = list(TMIN_imputed_yearly_series$Year), FUN = mean)
    colnames(TMIN_imputed_yearly_series) <- c("Year", "MeasurementValue")
    TMIN_imputed_yearly_series <- arrange(TMIN_imputed_yearly_series, Year)
    TMIN_imputed_yearly_series <- TMIN_imputed_yearly_series[2:nrow(TMIN_imputed_yearly_series)-1,]

    TMIN_imputed_yearly_series <- ts(TMIN_imputed_yearly_series$MeasurementValue, start = TMIN_imputed_yearly_series$Year[[1]], frequency = 1)

    message("------------------------------------------------------------------")

    if (method == "ARIMA" || method == "") {
        message(paste0("Forecasting next 10 year of highest temperatures from station ", station_ID, " using ARIMA..."))
        TMAX_arima_model <- auto.arima(TMAX_imputed_time_series)
        TMAX_arima_forecast <- forecast(TMAX_arima_model, h = 120)

        message(paste0("Forecasting next 10 year of lowest temperatures from station ", station_ID, " using ARIMA..."))
        TMIN_arima_model <- auto.arima(TMIN_imputed_time_series)
        TMIN_arima_forecast <- forecast(TMIN_arima_model, h = 120)
    }

    if (method == "TBATS" || method == "") {
        message(paste0("Forecasting next 10 year of highest temperatures from station ", station_ID, " using Trigonometric Exponential Smoothing..."))
        TMAX_tbats_model <- tbats(TMAX_imputed_time_series)
        TMAX_tbats_forecast <- forecast(TMAX_tbats_model, h = 120)

        message(paste0("Forecasting next 10 year of lowest temperatures from station ", station_ID, " using Trigonometric Exponential Smoothing..."))
        TMIN_tbats_model <- tbats(TMIN_imputed_time_series)
        TMIN_tbats_forecast <- forecast(TMIN_tbats_model, h = 120)
    }

    if (method == "HW" || method == "") {
        message(paste0("Forecasting next 10 year of highest temperatures from station ", station_ID, " using Holt Winters additive and multiplicative methods..."))
        TMAX_hw_forecast <- hw(TMAX_imputed_time_series, h = 120)

        message(paste0("Forecasting next 10 year of lowest temperatures from station ", station_ID, " using Holt Winters additive and multiplicative methods..."))
        TMIN_hw_forecast <- hw(TMIN_imputed_time_series, h = 120)
    }

    message("------------------------------------------------------------------")

    message(paste0("Creating seasonal decomposition for highest temperatures from station ", station_ID, "..."))
    TMAX_decomposed_time_series <- decompose(TMAX_imputed_time_series)

    message(paste0("Creating seasonal decomposition for lowest temperatures from station ", station_ID, "..."))
    TMIN_decomposed_time_series <- decompose(TMIN_imputed_time_series)

    message("")
    message("==================================================================")
    message("")

    result <- list(
        Timeseries = list(
            TMAX = list(
                Monthly = list(
                    Timeseries = TMAX_time_series,
                    ImputedTimeseries = TMAX_imputed_time_series
                ),
                Yearly = list(
                    ImputedTimeseries = TMAX_imputed_yearly_series
                )
            ),
            TMIN = list(
                Monthly = list(
                    Timeseries = TMIN_time_series,
                    ImputedTimeseries = TMIN_imputed_time_series
                ),
                Yearly = list(
                    ImputedTimeseries = TMIN_imputed_yearly_series
                )
            )
        ),
        Forecasts = list(
            TMAX = list(),
            TMIN = list()
        ),
        Decompositions = list(
            TMAX = TMAX_decomposed_time_series,
            TMIN = TMIN_decomposed_time_series
        )
    )

    if (method == "ARIMA" || method == "") {
        result$Forecasts$TMAX$ARIMA <- TMAX_arima_forecast
        result$Forecasts$TMIN$ARIMA <- TMIN_arima_forecast
    }

    if (method == "TBATS" || method == "") {
        result$Forecasts$TMAX$TBATS <- TMAX_tbats_forecast
        result$Forecasts$TMIN$TBATS <- TMIN_tbats_forecast
    }

    if (method == "HW" || method == "") {
        result$Forecasts$TMAX$HW <- TMAX_hw_forecast
        result$Forecasts$TMIN$HW <- TMIN_hw_forecast
    }
    
    return(result)
}

estimate_best_forecast_model <- function (stations) {
    message("Estimating best forecast model...")

    message("Searching for best weather station...")
    criterions <- sapply(stations, function(x) {
        len <- length(x$Measurements$MeasurementValue)
        NA_percentage <- sum(is.na(x$Measurements$MeasurementValue)) / length(x$Measurements$MeasurementValue) * 100

        return(c(len, NA_percentage, x$Informations$Station_ID))
    })

    criterions <- data.frame(t(criterions))
    colnames(criterions) <- c("Length", "NAs", "Station_ID")
    criterions <- arrange(criterions, Length)
    criterions <- criterions[1:trunc(length(criterions$Length)/2),]
    criterions <- arrange(criterions, NAs)
    criterions <- criterions[1,]
    best_station <- criterions$Station_ID
    index <- which(sapply(stations, function(x) x$Informations$Station_ID) == best_station)


    message("Testing all forecast models...")
    test_forecasts <- forecast_station(index = index, stations = stations, accuracyTest = TRUE)

    station <- stations[[index]]
    measurements <- station$Measurements
    station_ID <- station$Informations$Station_ID

    TMAX_measurements <- measurements[measurements$MeasurementType == "TMAX",]
    TMAX_arranged_measurements <- arrange(TMAX_measurements, Year, Month)
    TMAX_time_series <- ts(TMAX_arranged_measurements$MeasurementValue, start = c(TMAX_arranged_measurements$Year[1], TMAX_arranged_measurements$Month[1]), frequency = 12)
    TMAX_imputed_time_series <- na_kalman(TMAX_time_series)

    TMIN_measurements <- measurements[measurements$MeasurementType == "TMIN",]
    TMIN_arranged_measurements <- arrange(TMIN_measurements, Year, Month)
    TMIN_time_series <- ts(TMIN_arranged_measurements$MeasurementValue, start = c(TMIN_arranged_measurements$Year[1], TMIN_arranged_measurements$Month[1]), frequency = 12)
    TMIN_imputed_time_series <- na_kalman(TMIN_time_series)

    message("Calculating accuracies...")
    TMIN_accuracies <- list (
      ARIMA = accuracy(object = test_forecasts$Forecast$TMIN$ARIMA, x = TMIN_imputed_time_series),
      TBATS = accuracy(object = test_forecasts$Forecast$TMIN$TBATS, x = TMIN_imputed_time_series),
      HW    = accuracy(object = test_forecasts$Forecast$TMIN$HW,    x = TMIN_imputed_time_series)
    )

    TMAX_accuracies <- list (
      ARIMA = accuracy(object = test_forecasts$Forecast$TMAX$ARIMA, x = TMAX_imputed_time_series),
      TBATS = accuracy(object = test_forecasts$Forecast$TMAX$TBATS, x = TMAX_imputed_time_series),
      HW    = accuracy(object = test_forecasts$Forecast$TMAX$HW,    x = TMAX_imputed_time_series)
    )

    message("Extracting RMSE...")
    TMIN_RMSE <- sapply(TMIN_accuracies, function(x) x[[4]])
    TMAX_RMSE <- sapply(TMAX_accuracies, function(x) x[[4]])

    AVG_RMSE <- (TMIN_RMSE + TMAX_RMSE) / 2

    message("Extracting best model...")
    bestMethod <- names(AVG_RMSE)[which.min(AVG_RMSE)]
    message(paste0("Best forecast model is ", bestMethod, "."))

    return(bestMethod)
}